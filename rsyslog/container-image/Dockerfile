FROM centos:centos7
MAINTAINER The ViaQ Community <community@TBA>

EXPOSE 10514

ENV SYSLOG_LISTEN_PORT=10514 \
    ES_HOST=bitscout-elasticsearch \
    ES_PORT=9200

ADD rsyslog.repo /etc/yum.repos.d/

RUN yum update -y && \
    yum install -y rsyslog \
    rsyslog-elasticsearch \
#	rsyslog-imptcp \
#	rsyslog-imrelp \
	rsyslog-mmjsonparse \
#	rsyslog-omrelp \
#	rsyslog-omstdout \
    rsyslog-mmsnmptrapd \
	rsyslog-kafka && \
    yum clean all && \
	rm /etc/rsyslog.d/listen.conf

VOLUME /data

RUN mkdir /tmp/rsyslog

ADD rsyslog.conf /etc/

ADD run.sh /usr/sbin/
WORKDIR /var/lib/rsyslog
RUN chgrp -R 0 /var/lib/rsyslog \
    && chmod -R g+rwX /var/lib/rsyslog

CMD /usr/sbin/run.sh
