#!/usr/bin/env bash

opt/kafka/bin/kafka-topics.sh --describe \
    --zookeeper localhost:2181 \
    --topic test-topic