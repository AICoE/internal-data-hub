# Logstash docker image
ViaQ Logstash docker container - implements the aggregator/formatter

## Environmental variables:
`ES_HOST` must be FQDN of ElasticSearch server.
`ES_PORT` must be the port on which the ElasticSearch server is listening.
`LISTEN_PORT` the port this logstash instance is listening for.

## External Logstash config
In order to add own Logstash configuration file please add the configuration files to a local directory and map in to `config` OpenShift ConfigMap.

## Running:
* Specify the environmental variables
* execute `run-container.sh`
