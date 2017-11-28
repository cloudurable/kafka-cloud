#!/bin/bash
set -e
yum update -y
yum install -y java
yum install -y nc
yum install -y net-tools

yum clean all
rm -rf /var/cache/yum
