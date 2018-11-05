#!/bin/bash

if [ "${zookeeper}" == "true" ]; then

    until /opt/zookeeper/zookeeper_update_configs.py ${region} ${zookeeper_count};
    do
        sleep 5
    done

    zookeeper_config -E
    zookeeper_config -S
fi

if [ "${broker}" == "true" ]; then

    while : ; do    
        ZOOKEEPER_IP=`aws ec2 describe-instances --region ${region} --filters "Name=tag-key,Values=HasZookeeper" |
            jq -r ".Reservations[].Instances[].PrivateIpAddress" |
            grep -v null |
            shuf |
            head -n 1`
        if [ ! -z "$ZOOKEEPER_IP" ]; then
            break
        fi
        sleep 5
    done

    PRIVATE_IP=`ec2metadata --local-ipv4`

    kafka_config -z $ZOOKEEPER_IP
    kafka_config -a $PRIVATE_IP
    kafka_config -E
    kafka_config -S
fi