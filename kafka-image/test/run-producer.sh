#!/usr/bin/env bash

opt/kafka/bin/kafka-console-producer.sh \
    --broker-list localhost:9092 \
    --topic test-topic