#!/bin/bash

export ZK_HOME=/opt/zookeeper
export ZK_CONFIG=/etc/zookeeper/zoo.cfg
export ZK_CONFIG_LOG4J=/etc/zookeeper/log4j.properties

sudo mkdir -p /{etc,opt,data}/zookeeper
sudo mkdir -p /var/{log,run}/zookeeper

sudo groupadd zookeeper
sudo useradd -g zookeeper -c 'Apache Zookeeper' -s /bin/bash zookeeper
curl -sL --retry 3 --insecure "https://archive.apache.org/dist/zookeeper/zookeeper-${ZOOKEEPER_VERSION}/zookeeper-${ZOOKEEPER_VERSION}.tar.gz" | sudo tar xz --strip-components=1 -C ${ZK_HOME}

sudo cp ${ZK_HOME}/conf/zoo_sample.cfg ${ZK_CONFIG}
sudo cp ${ZK_HOME}/conf/log4j.properties ${ZK_CONFIG_LOG4J}

sudo sed -i -r -e '/^dataDir/s/=.*/=\/data\/zookeeper/' ${ZK_CONFIG}
sudo sed -i -r -e '/^clientPort/s/=.*/=2181/' ${ZK_CONFIG}
sudo sed -i -r -e 's/# *maxClientCnxns/maxClientCnxns/;/^maxClientCnxns/s/=.*/=100/' ${ZK_CONFIG}
sudo sed -i -r -e 's/# *autopurge.snapRetainCount/autopurge.snapRetainCount/;/^autopurge.snapRetainCount/s/=.*/=50/' ${ZK_CONFIG}
sudo sed -i -r -e 's/# *autopurge.purgeInterval/autopurge.purgeInterval/;/^autopurge.purgeInterval/s/=.*/=3/' ${ZK_CONFIG}
sudo sed -i -r -e 's/# *log4j.appender.ROLLINGFILE.MaxFileSize/log4j.appender.ROLLINGFILE.MaxFileSize/;/^log4j.appender.ROLLINGFILE.MaxFileSize/s/=.*/=10MB/' ${ZK_CONFIG_LOG4J}
sudo sed -i -r -e 's/# *log4j.appender.ROLLINGFILE.MaxBackupIndex/log4j.appender.ROLLINGFILE.MaxBackupIndex/;/^log4j.appender.ROLLINGFILE.MaxBackupIndex/s/=.*/=10/' ${ZK_CONFIG_LOG4J}
echo "JVMFLAGS=\"\$JVMFLAGS -Xmx\$(/usr/bin/awk '/MemTotal/{m=\$2*.20;print int(m)\"k\"}' /proc/meminfo)\"" | sudo tee -a ${ZK_HOME}/conf/java.env > /dev/null
echo -e 'ZOO_LOG4J_PROP="INFO,ROLLINGFILE"\nZOO_LOG_DIR="/var/log/zookeeper"\nZOOPIDFILE="/var/run/zookeeper/zookeeper.pid"\nZOOCFGDIR="/etc/zookeeper"' | sudo tee -a ${ZK_HOME}/conf/zookeeper-env.sh > /dev/null
echo 1 | sudo tee /data/zookeeper/myid > /dev/null
sudo chown -R zookeeper:zookeeper ${ZK_HOME} /data/zookeeper /etc/zookeeper /opt/zookeeper /var/log/zookeeper /var/run/zookeeper

sudo chmod +x /tmp/zookeeper_update_configs.py
sudo sed -i -e "s~__CONFIG_PATH__~${ZK_CONFIG}~g" /tmp/zookeeper_update_configs.py
sudo sed -i -e "s~__ID_FILE_PATH__~/data/zookeeper/myid~g" /tmp/zookeeper_update_configs.py
sudo cp /tmp/zookeeper_update_configs.py ${ZK_HOME}

sudo cp /tmp/zookeeper.service /lib/systemd/system/
sudo systemctl daemon-reload
sudo systemctl disable zookeeper.service

sudo cp /tmp/zookeeper_config /usr/local/bin/
sudo chown root:staff /usr/local/bin/zookeeper_config
sudo chmod 0755 /usr/local/bin/zookeeper_config
