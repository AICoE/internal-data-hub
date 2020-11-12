#!/bin/sh

set -ex
prefix=${PREFIX:-${1:-viaq/}}
version=${VERSION:-${2:-latest}}
docker build -t "${prefix}logstash:${version}" .
docker build -t "${prefix}logstash-6:${version}" -f Dockerfile.logstash6 .


if [ -n "${PUSH:-$3}" ]; then
    docker push "${prefix}logstash:${version}"
fi
