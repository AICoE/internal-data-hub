#!/bin/sh

set -e
set -x

DEBUG_RSYSLOG=${DEBUG_RSYSLOG:-false}

if [ "$DEBUG_RSYSLOG" = true ]; then
    RSYSLOG_ARGS="-d -n -iNONE"
else
    RSYSLOG_ARGS="-n -iNONE"
fi

/usr/sbin/rsyslogd ${RSYSLOG_ARGS}

