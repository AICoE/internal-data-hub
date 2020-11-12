#!/bin/bash

set -ex
set -o nounset

yum -y install https://artifacts.elastic.co/downloads/logstash/logstash-${LOGSTASH_VER}.rpm

/usr/share/logstash/bin/logstash-plugin install logstash-filter-translate
/usr/share/logstash/bin/logstash-plugin install logstash-output-kafka
/usr/share/logstash/bin/logstash-plugin install logstash-input-lumberjack
