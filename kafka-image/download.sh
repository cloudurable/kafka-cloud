#!/usr/bin/env bash

# http://apache.spinellicreations.com/kafka/1.0.0/kafka_2.12-1.0.0.tgz

set -e
export MIRROR=http://apache.spinellicreations.com
export VERSION=1.0.0
export SCALA_VERSION=2.12
export KAFKA_DIST="kafka_$SCALA_VERSION-$VERSION"

mkdir -p opt


if [ ! -d "opt/kafka" ]; then
  curl "$MIRROR/kafka/$VERSION/$KAFKA_DIST.tgz" \
    --output kafka.tgz
  tar -xvzf kafka.tgz
  mv "$KAFKA_DIST" opt/kafka
  rm kafka.tgz
else
  echo "kafka src already downloaded"
fi
