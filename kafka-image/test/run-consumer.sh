#!/usr/bin/env bash

opt/kafka/bin/kafka-console-consumer.sh \
    --bootstrap-server kafka0:9092 \
    --from-beginning \
    --topic test-topic