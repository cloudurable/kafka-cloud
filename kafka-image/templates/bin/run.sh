#!/bin/bash

set -e

if [ "x_${KAFKA_CLUSTER_MODE}" == "x_auto" ]
then
    export KAFKA_NUM_PARTITIONS=${KAFKA_DEFAULT_REPLICATION}
    export KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR=${KAFKA_DEFAULT_REPLICATION}
    export KAFKA_TRANSACTION_STATE_LOG_REPLICATION_FACTOR=${KAFKA_DEFAULT_REPLICATION}
    export KAFKA_TRANSACTION_STATE_LOG_MIN_ISR=2
    export KAFKA_GROUP_INITIAL_REBALANCE_DELAY_MS=3000
    export KAFKA_AUTO_CREATE_TOPICS_ENABLE=false
    export KAFKA_DELETE_TOPIC_ENABLE=false
fi

if [ "x_${KAFKA_CLUSTER_MODE}" == "x_standalone" ]
then
    export KAFKA_NUM_PARTITIONS=1
    export KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR=1
    export KAFKA_TRANSACTION_STATE_LOG_REPLICATION_FACTOR=1
    export KAFKA_TRANSACTION_STATE_LOG_MIN_ISR=1
    export KAFKA_ZOOKEEPER_CONNECT=$(hostname):2181
    export KAFKA_LISTENERS=PLAINTEXT://$(hostname):${KAFKA_PORT}
fi

# If KAFKA_ADVERTISED_LISTENERS is blank then set KAFKA_ADVERTISED_LISTENERS_TOTAL to commented out field
if [ "x_${KAFKA_ADVERTISED_LISTENERS}" == "x_" ]
then
        KAFKA_ADVERTISED_LISTENERS_TOTAL="#advertised="
fi

# If KAFKA_ADVERTISED_LISTENERS is NOT blank then set KAFKA_ADVERTISED_LISTENERS_TOTAL to advertised list

if [ "x_${KAFKA_ADVERTISED_LISTENERS}" != "x_" ]
then
        KAFKA_ADVERTISED_LISTENERS_TOTAL="advertised=${KAFKA_ADVERTISED_LISTENERS}"
fi

export KAFKA_LOG_RETENTION_BYTES_ALL="#log.retention.bytes=1073741824"

if [ "x${KAFKA_LOG_RETENTION_BYTES}" != "x" ]
then
    export KAFKA_LOG_RETENTION_BYTES_ALL="log.retention.bytes${KAFKA_LOG_RETENTION_BYTES}"
fi


if [ "x_${KAFKA_CLUSTER_MODE}" == "x_standalone" ]
then
    echo "Running ZooKeeper because we are in standalone mode"
    /opt/kafka/bin/zookeeper-server-start.sh /opt/kafka/config/zookeeper.properties &
fi

/opt/templates/bin/templater.sh /opt/templates/server_properties.template > /opt/kafka/config/server.properties

if [ "x_${KAFKA_DEBUG_MODE}" == "x_true" ]
then
    echo "SERVER PROPERTIES FILE CONTENTS START -----------"
    cat /opt/kafka/config/server.properties
    echo "SERVER PROPERTIES FILE CONTENTS STOP ------------"
    echo "ENV START ---------------------------------------"
    env
    echo "ENV STOP ----------------------------------------"

fi

/opt/kafka/bin/kafka-server-start.sh /opt/kafka/config/server.properties

