#!/usr/bin/env bash
docker ps -a | grep cloudurable/kafka-image | awk '{ print $1}' \
  | xargs docker stop

docker ps -a | grep cloudurable/kafka-image | awk '{ print $1}' \
  | xargs docker rm

docker images | grep cloudurable/kafka-image | awk '{ print $3}' \
    | xargs docker rmi -f

docker images | grep none | awk '{ print $3}' \
        | xargs docker rmi -f
