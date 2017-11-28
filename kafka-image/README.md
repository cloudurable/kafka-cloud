
# What is Apache Kafka?

Apache Kafka provides ...


# How to use this image

## Run
```sh
docker run --name kafka \
  -p 2181:2181 \
  --restart always \
  -e ENSEMBLE=zoo1,hostzoo2,zookeeper3 \ TBD
  cloudurable/kafka-image:0.1 \
  /opt/zookeeper/bin/run.sh
```


## Environment Variables


```sh
      "changes": [
          "ENV KAFKA_BROKER_ID 1",
          "ENV KAFKA_LOG_DIRS /opt/kafka/data",
          "ENV KAFKA_PORT 9092",
          "ENV KAFKA_LISTENERS ''",
          "ENV KAFKA_ADVERTISED_LISTENERS ''",
          "ENV KAFKA_NUM_NETWORK_THREADS 3",
          "ENV KAFKA_NUM_IO_THREADS 8",
          "ENV KAFKA_NUM_PARTITIONS 1",
          "ENV KAFKA_SOCKET_SEND_BUFFER_BYTES 102400",
          "ENV KAFKA_SOCKET_RECEIVE_BUFFER_BYTES 102400",
          "ENV KAFKA_SOCKET_REQUEST_MAX_BYTES 104857600",
          "ENV KAFKA_NUM_RECOVERY_THREADS_PER_DATA_DIR 1",
          "ENV KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR 1",
          "ENV KAFKA_TRANSACTION_STATE_LOG_REPLICATION_FACTOR 1",
          "ENV KAFKA_TRANSACTION_STATE_LOG_MIN_ISR 1",
          "ENV KAFKA_LOG_RETENTION_HOURS 168",
          "ENV KAFKA_LOG_RETENTION_CHECK_INTERVAL_MS 300000",
          "ENV KAFKA_ZOOKEEPER_CONNECT localhost:2181",
          "ENV KAFKA_ZOOKEEPER_CONNECTION_TIMEOUT 6000",
          "ENV KAFKA_GROUP_INITIAL_REBALANCE_DELAY_MS 3000",
          "ENV KAFKA_LOG_RETENTION_BYTES ''",
          "ENTRYPOINT /opt/kafka/bin/run.sh"

        ]
```


## Example Docker Compose file to run an Ensemble of ZooKeeper servers (cluster)

```yaml
version: '3'
services:
  zookeeper0:
    image: "cloudurable/zookeeper-image:0.2"
    restart: always
    ports:
     - "2181:2181"
    environment:
     - ENSEMBLE=zookeeper0,zookeeper1,zookeeper2
     - MY_ID=1
  zookeeper1:
    image: "cloudurable/zookeeper-image:0.2"
    restart: always
    environment:
     - ENSEMBLE=zookeeper0,zookeeper1,zookeeper2
     - MY_ID=2
  zookeeper2:
    image: "cloudurable/zookeeper-image:0.2"
    restart: always
    environment:
     - ENSEMBLE=zookeeper0,zookeeper1,zookeeper2
     - MY_ID=3
```


This above starts Zookeeper in [replicated mode](http://zookeeper.apache.org/doc/current/zookeeperStarted.html#sc_RunningReplicatedZooKeeper). Run `docker-compose up`\ and wait for it to initialize completely. Ports `2181, 2888 and 3888` will be exposed.





## Configuration


The Kafka config gets generated based on the environment variables that you specify by
`/opt/kafka/bin/run.sh` using sed to edit the Kafka config file.


Kafka configuration is located in `/opt/kafka/conf/server.properties`.

To change the config, mount a new config file as a volume:

```
	$ docker run --name node0-zookeeper --restart always \
      -d -v $(pwd)/kafka.cfg:/opt/kafka/conf/server.properties \
      cloudurable/kafka-image
```



# Dev Notes



## Build base image
```sh
packer build base-java-packer.json
```

We build a base image which installs Java, updates the OS, etc.
This is time consuming. We try to do it once.

## Run packer
```sh
packer build packer.json
```

## Snoop around
```sh
docker run -it cloudurable/zookeeper-image:latest
## We added an entrypoint so now you have to do this
docker run -it --entrypoint "/bin/bash"  cloudurable/kafka-image

```

## Clean docker

```sh
docker ps -a | grep cloudurable/kafka-image | awk '{ print $1}' \
  | xargs docker rm

docker images | grep cloudurable/kafka-image | awk '{ print $3}' \
    | xargs docker rmi -f
```