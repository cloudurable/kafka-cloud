#!/usr/bin/env bash

opt/kafka/bin/kafka-topics.sh --create \
--bootstrap-server localhost:9092 \
--replication-factor 1 \
--partitions 9 \
--topic test-topic
