#!/usr/bin/env bash

./download.sh
./configure.sh
packer build -var 'docker-tag=latest' docker-packer.json
