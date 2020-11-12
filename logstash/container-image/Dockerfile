FROM quay.io/app-sre/centos:centos7
MAINTAINER The ViaQ Community <community@TBA>


ENV HOME=/opt/app-root/ \
    PATH=/opt/app-root/src/bin:/opt/app-root/bin:$PATH \
    JAVA_HOME=/usr/lib/jvm/jre

RUN rpmkeys --import file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7 && \
    rpmkeys --import https://packages.elastic.co/GPG-KEY-elasticsearch

ADD logstash.repo /etc/yum.repos.d/logstash.repo

RUN yum update -y --setopt=tsflags=nodocs \
    && \
    yum install -y --setopt=tsflags=nodocs java-1.8.0-openjdk-headless \
    && \
    yum -y autoremove \
    && \
    yum clean all

VOLUME /etc/logstash/conf.d

RUN  mkdir -p /etc/logstash/conf.d/ \
     && \
     mkdir -p ${HOME} \
     && \
     chmod 775 ${HOME}

WORKDIR ${HOME}
ADD run.sh /usr/bin/
ADD install.sh ${HOME}

RUN ${HOME}/install.sh

ADD logstash.yml log4j2.properties /etc/logstash/

USER 1001

CMD /usr/bin/run.sh
