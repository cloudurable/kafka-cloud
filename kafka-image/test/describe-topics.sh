#!/usr/bin/env bash

opt/kafka/bin/kafka-topics.sh --describe \
    --bootstrap-server kafka0:9092 \
    --topic test-topic
