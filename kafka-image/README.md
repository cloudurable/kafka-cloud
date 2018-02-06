
# What is Apache Kafka?

Apache Kafka provides ...


## Run

Run the 9th server / broker in a cluster.

```sh
docker run  -d \
    -e KAFKA_BROKER_ID=9  \
    -e KAFKA_CLUSTER_MODE=auto \
    -e KAFKA_ZOOKEEPER_CONNECT=zk0.cloudurable.com::2181,zk1.cloudurable.com::2181,zk2.cloudurable.com::2181 \
    cloudurable/kafka-image
```


Run standalone for testing.

```sh
docker run  -d  -e KAFKA_CLUSTER_MODE=standalone \
      --restart always --net=host \
      cloudurable/kafka-image
```

Debug mode

```
docker run  -d  -e KAFKA_CLUSTER_MODE=standalone \
        -e KAFKA_DEBUG_MODE=true \
      --restart always --net=host \
      cloudurable/kafka-image
```

## Environment Variables


```sh
      "changes": [
          "ENV KAFKA_CLUSTER_MODE standalone",
          "ENV KAFKA_DEFAULT_REPLICATION 3",
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
    image: "cloudurable/zookeeper-image:0.3"
    restart: always
    ports:
     - "2181:2181"
    environment:
     - ENSEMBLE=zookeeper0,zookeeper1,zookeeper2
     - MY_ID=1
  zookeeper1:
    image: "cloudurable/zookeeper-image:0.3"
    restart: always
    ports:
     - "2182:2181"
    environment:
     - ENSEMBLE=zookeeper0,zookeeper1,zookeeper2
     - MY_ID=2
  zookeeper2:
    image: "cloudurable/zookeeper-image:0.3"
    restart: always
    ports:
     - "2183:2181"
    environment:
     - ENSEMBLE=zookeeper0,zookeeper1,zookeeper2
     - MY_ID=3
  kafka0:
    image: "cloudurable/kafka-image"
    restart: always
    depends_on:
      - zookeeper0
      - zookeeper1
      - zookeeper2
    ports:
     - "9092:9092"
    links:
     - zookeeper0
     - zookeeper1
     - zookeeper2
    environment:
     - KAFKA_ZOOKEEPER_CONNECT=zookeeper0:2181,zookeeper1:2181,zookeeper2:2181
     - KAFKA_BROKER_ID=1
     - KAFKA_CLUSTER_MODE=auto
     - KAFKA_LISTENERS=PLAINTEXT://kafka0:9092
     - KAFKA_DEFAULT_REPLICATION=1
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
packer build docker-packer.json
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

## Push another tag
```
$ docker tag 1d447fd81ff8  cloudurable/kafka-image:0.5
$ docker push  cloudurable/kafka-image:0.5
```