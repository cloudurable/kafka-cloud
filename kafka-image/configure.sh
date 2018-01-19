#!/usr/bin/env bash

rm -rf opt/kafka/bin/windows
rm opt/kafka/config/server.properties

cp -r templates opt/

mv opt/templates/bin/run.sh opt/kafka/bin/run.sh






