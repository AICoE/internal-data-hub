#!/bin/sh

set -e
set -x
set -euo pipefail

info Begin Logstash startup script

BYTES_PER_MEG=$((1024*1024))
BYTES_PER_GIG=$((1024*${BYTES_PER_MEG}))

# the amount of RAM allocated should be half of available instance RAM.
# ref. https://www.elastic.co/guide/en/elasticsearch/guide/current/heap-sizing.html#_give_half_your_memory_to_lucene
regex='^([[:digit:]]+)([GgMm])i?$'
if [[ "$INSTANCE_RAM" =~ $regex ]]; then
    num=${BASH_REMATCH[1]}
    unit=${BASH_REMATCH[2]}
    if [[ $unit =~ [Gg] ]]; then
        ((num = num * ${BYTES_PER_GIG})) # enables math to work out for odd Gi
    elif [[ $unit =~ [Mm] ]]; then
        ((num = num * ${BYTES_PER_MEG})) # enables math to work out for odd Gi
    fi

    #determine max allowable memory
    info "Inspecting the maximum RAM available..."
    mem_file="/sys/fs/cgroup/memory/memory.limit_in_bytes"
    if [ -r "${mem_file}" ]; then
        max_mem="$(cat ${mem_file})"
        if [ ${max_mem} -lt ${num} ]; then
            ((num = ${max_mem}))
            warn "Setting the maximum allowable RAM to $(($num / BYTES_PER_MEG))m which is the largest amount available"
        fi
    else
        error "Unable to determine the maximum allowable RAM for this host in order to configure Logstash"
        exit 1
    fi

    num=$(($num/2/BYTES_PER_MEG))
    export LS_JAVA_OPTS="${LS_JAVA_OPTS:-} -Xms${num}m -Xmx${num}m"
    info "LS_JAVA_OPTS: '${LS_JAVA_OPTS}'"
else
    error "INSTANCE_RAM is invalid: $INSTANCE_RAM"
    exit 1
fi

export LS_JAVA_OPTS="${LS_JAVA_OPTS:-}"
info "LS_JAVA_OPTS: '${LS_JAVA_OPTS}'"

if [ "$DEBUG_LOGSTASH" = true ]; then
    LOGSTASH_ARGS="--config.debug --log.level trace"
else
    LOGSTASH_ARGS=""
fi

/usr/share/logstash/bin/logstash ${LOGSTASH_ARGS} --http.host "0.0.0.0" --log.format json --path.settings /etc/logstash/
