#!/usr/bin/env bash

rm -rf opt/kafka/bin/windows
rm opt/kafka/config/server.properties



# Create the kafka config file
tee opt/kafka/config/server.properties << END

broker.id=0
#listeners=PLAINTEXT://:9092
#advertised.listeners=PLAINTEXT://your.host.name:9092
log.dirs=/tmp/kafka-logs
num.network.threads=3
num.io.threads=8
num.partitions=1
socket.send.buffer.bytes=102400
socket.receive.buffer.bytes=102400
socket.request.max.bytes=104857600
num.recovery.threads.per.data.dir=1
offsets.topic.replication.factor=1
transaction.state.log.replication.factor=1
transaction.state.log.min.isr=1
#log.flush.interval.messages=10000
#log.flush.interval.ms=1000
#log.retention.bytes=1073741824
log.segment.bytes=1073741824
log.retention.hours=168
log.retention.check.interval.ms=300000
zookeeper.connect=localhost:2181
zookeeper.connection.timeout.ms=6000
group.initial.rebalance.delay.ms=0

END



tee opt/kafka/bin/run.sh << END
#!/usr/bin/env bash
set -e

export CFG_FILE="/opt/kafka/config/server.properties"
echo "Modifying config file \$CFG_FILE 1"
sed  -i  's/opt\/kafka/\/opt\/kafka/g' \$CFG_FILE
echo "Modifying config file \$CFG_FILE 2"
sed  -i  "s/broker.id=0/broker.id=\$KAFKA_BROKER_ID/g" \$CFG_FILE

echo "Modifying config file \$CFG_FILE for config dirs locations"
LOG_DIRS=\$(echo \$KAFKA_LOG_DIRS | sed 's/\//\\\\\\//g')
echo "Modifying config file \$CFG_FILE for log dirs \$LOG_DIRS"
sed  -i  "s/log.dirs=\/tmp\/kafka-logs/log.dirs=\$LOG_DIRS/g" \$CFG_FILE

if [ "x_\$KAFKA_CLUSTER_MODE" == "x_auto" ]
then
    export KAFKA_NUM_PARTITIONS=\$KAFKA_DEFAULT_REPLICATION
    export KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR=\$KAFKA_DEFAULT_REPLICATION
    export KAFKA_TRANSACTION_STATE_LOG_REPLICATION_FACTOR=\$KAFKA_DEFAULT_REPLICATION
    export KAFKA_TRANSACTION_STATE_LOG_MIN_ISR=2
    export KAFKA_GROUP_INITIAL_REBALANCE_DELAY_MS=3000
fi

if [ "x_\$KAFKA_CLUSTER_MODE" == "x_standalone" ]
then
    export KAFKA_NUM_PARTITIONS=1
    export KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR=1
    export KAFKA_TRANSACTION_STATE_LOG_REPLICATION_FACTOR=1
    export KAFKA_TRANSACTION_STATE_LOG_MIN_ISR=1
    export KAFKA_ZOOKEEPER_CONNECT=\$(hostname):2181
    export KAFKA_LISTENERS=PLAINTEXT://\$(hostname):9092
fi


if [ "x\$KAFKA_LISTENERS" != "x" ]
then
    LISTENERS=\$(echo \$KAFKA_LISTENERS | sed 's/\//\\\\\\//g')
    sed  -i  "s/#listeners=PLAINTEXT:\/\/:9092/listeners=\$LISTENERS/g" \$CFG_FILE
fi

if [ "x\$KAFKA_ADVERTISED_LISTENERS" != "x" ]
then
    A_LISTENERS=\$(echo \$KAFKA_ADVERTISED_LISTENERS | sed 's/\//\\\\\\//g')
    sed  -i  "s/#advertised.listeners=PLAINTEXT:\/\/your.host.name:9092/advertised.listeners=\$A_LISTENERS/g" \$CFG_FILE
fi

if [ "x\$KAFKA_PORT" != "x" ]
then
  echo "Modifying config file \$CFG_FILE for client port address \$KAFKA_PORT"
  sed  -i  "s/#listeners=PLAINTEXT:\/\/:9092/listeners=PLAINTEXT:\/\/:\$KAFKA_PORT/g" \$CFG_FILE
fi



sed  -i  "s/num.network.threads=3/num.network.threads=\$KAFKA_NUM_NETWORK_THREADS/g" \$CFG_FILE
sed  -i  "s/num.io.threads=8/num.io.threads=\$KAFKA_NUM_IO_THREADS/g" \$CFG_FILE
sed  -i  "s/num.partitions=1/num.partitions=\$KAFKA_NUM_PARTITIONS/g" \$CFG_FILE
sed  -i  "s/socket.send.buffer.bytes=102400/socket.send.buffer.bytes=\$KAFKA_SOCKET_SEND_BUFFER_BYTES/g" \$CFG_FILE
sed  -i  "s/socket.receive.buffer.bytes=102400/socket.receive.buffer.bytes=\$KAFKA_SOCKET_RECEIVE_BUFFER_BYTES/g" \$CFG_FILE
sed  -i  "s/socket.request.max.bytes=104857600/socket.request.max.bytes=\$KAFKA_SOCKET_REQUEST_MAX_BYTES/g" \$CFG_FILE

sed  -i  "s/num.recovery.threads.per.data.dir=1/num.recovery.threads.per.data.dir=\$KAFKA_NUM_RECOVERY_THREADS_PER_DATA_DIR/g" \$CFG_FILE
sed  -i  "s/offsets.topic.replication.factor=1/offsets.topic.replication.factor=\$KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR/g" \$CFG_FILE
sed  -i  "s/transaction.state.log.replication.factor=1/transaction.state.log.replication.factor=\$KAFKA_TRANSACTION_STATE_LOG_REPLICATION_FACTOR/g" \$CFG_FILE
sed  -i  "s/transaction.state.log.min.isr=1/transaction.state.log.min.isr=\$KAFKA_TRANSACTION_STATE_LOG_MIN_ISR/g" \$CFG_FILE

sed  -i  "s/log.retention.hours=168/log.retention.hours=\$KAFKA_LOG_RETENTION_HOURS/g" \$CFG_FILE
sed  -i  "s/log.retention.check.interval.ms=30000/log.retention.check.interval.ms=\$KAFKA_LOG_RETENTION_CHECK_INTERVAL_MS/g" \$CFG_FILE
sed  -i  "s/zookeeper.connect=localhost:2181/zookeeper.connect=\$KAFKA_ZOOKEEPER_CONNECT/g" \$CFG_FILE
sed  -i  "s/zookeeper.connection.timeout.ms=6000/zookeeper.connection.timeout.ms=\$KAFKA_ZOOKEEPER_CONNECTION_TIMEOUT/g" \$CFG_FILE
sed  -i  "s/group.initial.rebalance.delay.ms=0/group.initial.rebalance.delay.ms=\$KAFKA_GROUP_INITIAL_REBALANCE_DELAY_MS/g" \$CFG_FILE


if [ "x\$KAFKA_LOG_RETENTION_BYTES" != "x" ]
then
    sed  -i  "s/#log.retention.bytes=1073741824/log.retention.bytes=\$KAFKA_LOG_RETENTION_BYTES/g" \$CFG_FILE
fi


cat \$CFG_FILE


if [ "x_\$KAFKA_CLUSTER_MODE" == "x_standalone" ]
then
    /opt/kafka/bin/zookeeper-server-start.sh /opt/kafka/config/zookeeper.properties &
fi


/opt/kafka/bin/kafka-server-start.sh /opt/kafka/config/server.properties


END

chmod +x opt/kafka/bin/run.sh
