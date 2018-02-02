#!/usr/bin/env bash

opt/kafka/bin/kafka-topics.sh --create \
--zookeeper kafka0:2181 \
--replication-factor 1 \
--partitions 9 \
--topic test-topic

