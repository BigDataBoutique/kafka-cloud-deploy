#!/bin/bash

if [ "${zookeeper}" == "true" ]; then
    zookeeper_config -E
    zookeeper_config -S
fi

if [ "${broker}" == "true" ]; then
    systemctl enable kafka.service
    systemctl start kafka.service
fi