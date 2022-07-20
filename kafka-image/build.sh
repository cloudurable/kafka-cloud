#!/usr/bin/env bash

./download.sh
./configure.sh
packer build -var 'docker-tag=0.8' docker-packer.json
