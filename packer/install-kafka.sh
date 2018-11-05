#!/bin/bash

export KAFKA_HOME=/opt/kafka
export KAFKA_CONFIG=/etc/kafka

sudo mkdir -p /{etc,opt,data}/kafka
sudo mkdir -p /var/{log,run}/kafka

sudo groupadd kafka
sudo useradd -g kafka -c 'Apache Kafka' -s /bin/bash kafka
curl -sL --retry 3 --insecure "https://archive.apache.org/dist/kafka/${KAFKA_VERSION}/kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz" | sudo tar xz --strip-components=1 -C ${KAFKA_HOME}
sudo find ${KAFKA_HOME}/{bin,config} -iname \*zookeeper\* -type f -delete
sudo cp ${KAFKA_HOME}/config/* ${KAFKA_CONFIG}

echo -e "export LOG_DIR=\"/var/log/kafka\"\nexport KAFKA_DEBUG=\"\"\nexport KAFKA_HEAP_OPTS=\"-Xmx\$(/usr/bin/awk '/MemTotal/{m=\$2*.65;print int(m)\"k\"}' /proc/meminfo) -Xms\$(/usr/bin/awk '/MemTotal/{m=\$2*.65;print int(m)\"k\"}' /proc/meminfo)\"" | sudo tee ${KAFKA_HOME}/bin/kafka-env.sh > /dev/null
sudo sed -i -r -e '/^base_dir/a if [ -f ${base_dir}/kafka-env.sh ]; then . ${base_dir}/kafka-env.sh; fi' ${KAFKA_HOME}/bin/kafka-server-start.sh
#sudo sed -i -r -e '/^log4j.rootLogger/i kafka.logs.dir=\\/var\\/log\\/kafka\\n' /srv/kafka/config/log4j.properties
sudo sed -i -r -e 's/# *delete.topic.enable/delete.topic.enable/;/^delete.topic.enable/s/=.*/=true/' ${KAFKA_CONFIG}/server.properties
sudo sed -i -r -e 's/# *listeners=/listeners=/;/^listeners=/s/=.*/=PLAINTEXT:\/\/0.0.0.0:9092/' ${KAFKA_CONFIG}/server.properties
sudo sed -i -r -e 's/# *advertised.listeners/advertised.listeners/;/^advertised.listeners/s/=.*/=PLAINTEXT:\/\/localhost:9092/' ${KAFKA_CONFIG}/server.properties
sudo sed -i -r -e 's/# *socket.send.buffer.bytes/socket.send.buffer.bytes/;/^socket.send.buffer.bytes/s/=.*/=33554432/' ${KAFKA_CONFIG}/server.properties
sudo sed -i -r -e 's/# *socket.receive.buffer.bytes/socket.receive.buffer.bytes/;/^socket.receive.buffer.bytes/s/=.*/=33554432/' ${KAFKA_CONFIG}/server.properties
sudo sed -i -r -e 's/# *log.dirs/log.dirs/;/^log.dirs/s/=.*/=\/data\/kafka/' ${KAFKA_CONFIG}/server.properties
sudo sed -i -r -e 's/# *group.id/group.id/;/^group.id/s/=.*/=kafka-mirror/' ${KAFKA_CONFIG}/consumer.properties
sudo sed -i -r -e '/^receive.buffer.bytes/{h;s/=.*/=33554432/};${x;/^$/{s//receive.buffer.bytes=33554432/;H};x}' ${KAFKA_CONFIG}/consumer.properties
sudo sed -i -r -e 's/# *compression.type/compression.type/;/^compression.type/s/=.*/=lz4/' ${KAFKA_CONFIG}/producer.properties
sudo chown -R kafka:kafka /opt/kafka /etc/kafka /data/kafka /var/log/kafka

sudo sed -i  -e "s~/srv/kafka/config~${KAFKA_CONFIG}~g" /tmp/kafka.service
sudo sed -i  -e "s~/srv/kafka~${KAFKA_HOME}~g" /tmp/kafka.service
sudo cp /tmp/kafka.service /lib/systemd/system/
sudo systemctl daemon-reload
sudo systemctl disable kafka.service

sudo cp /tmp/kafka_config /usr/local/bin/
sudo chown root:staff /usr/local/bin/kafka_config
sudo chmod 0755 /usr/local/bin/kafka_config
