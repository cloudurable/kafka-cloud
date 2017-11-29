#!/usr/bin/env bash

opt/kafka/bin/kafka-console-producer.sh \
    --broker-list kafka0:9092 \
    --topic test-topic