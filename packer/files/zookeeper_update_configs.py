#!/usr/bin/env python3

import sys
import json
from datetime import datetime
from argparse import ArgumentParser
from subprocess import check_output

# These values should be substitited on install stage
CONFIG_PATH = '__CONFIG_PATH__'
ID_FILE_PATH = '__ID_FILE_PATH__'

parser = ArgumentParser()
parser.add_argument('region', type=str)
parser.add_argument('zookeepers_num', type=int)

def fetch_zookeeper_instances(region):
    command = 'aws ec2 describe-instances --region {} --filters "Name=tag-key,Values=HasZookeeper"'.format(region)
    out = check_output(command, shell=True).decode('utf-8')

    instances = []
    for res in json.loads(out)['Reservations']:
        instances += res['Instances']
    
    return [inst for inst in instances if inst['State']['Name'] == 'running']

def fetch_instance_private_ip():
    command = 'ec2metadata --local-ipv4'
    out = check_output(command, shell=True).decode('utf-8').split('\n')
    return out[0]

def update_config(private_ips):
    conf = []
    for i, addr in enumerate(private_ips):
        conf.append('server.{}={}:2888:3888'.format(i + 1, addr))

    with open(CONFIG_PATH, 'a') as f:
        f.write('\n'.join(conf))

def update_zookeeper_id_file(zookeeper_id):
    with open(ID_FILE_PATH, 'w+') as f:
        f.write(str(zookeeper_id))

def instance_sort(inst):
    '''
    Sort by instance LaunchTime. Use InstanceId for secondary sort.
    '''

    launch_time = inst['LaunchTime']
    launch_time = datetime.strptime(launch_time, '%Y-%m-%dT%H:%M:%S.%fZ')
    return (int(launch_time.strftime('%s')), inst['InstanceId'])

if __name__ == '__main__':
    args = parser.parse_args()

    current_private_ip = fetch_instance_private_ip()  
    instances = fetch_zookeeper_instances(args.region)

    print('Current IP: {}'.format(current_private_ip))
    print('Fetched {} instances, {} required'.format(len(instances), args.zookeepers_num))

    if len(instances) != args.zookeepers_num:
        sys.exit(1)

    instances = sorted(instances, key=instance_sort)
    private_ips = [inst['PrivateIpAddress'] for inst in instances]
    
    zookeeper_id = private_ips.index(current_private_ip) + 1

    print('Current zookeeper ID: {}'.format(zookeeper_id))
    update_zookeeper_id_file(zookeeper_id)
    print('Saved ID to', ID_FILE_PATH)

    update_config(private_ips)
    print('Saved IPs to', CONFIG_PATH)