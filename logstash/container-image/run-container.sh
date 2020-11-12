CONTAINER_NAME=logstash-normalizer

# Remove container with the same name if it is already running
# ./conf.d is local directory mounted directly into the container (analogue of configmaps),
# Do not modify configs in ./conf.d/ modify them in ./data/ instead
if [ "$1" != "--no-cleanup" ]; then
  docker stop ${CONTAINER_NAME} || true
  docker rm ${CONTAINER_NAME} || true
  rm ./conf.d/*
fi

if [ "$DEBUG" = true ]; then
  ENV_DEBUG="-e DEBUG_LOGSTASH=true"
  LOG=""
else
  ENV_DEBUG="-e DEBUG_LOGSTASH=false"
  LOG=""
fi

ES_HOST=${ES_HOST:-elasticsearch}
ES_PORT=${ES_PORT:-80}
LOGSTASH_PREFIX=${LOGSTASH_PREFIX:-viaq-openshift-v2016.05.16.1}
NORMALIZER_NAME=${NORMALIZER_NAME:-logstash-container}
NORMALIZER_HOSTNAME=${NORMALIZER_HOSTNAME:-my-centos}
LISTEN_PORT=${LISTEN_PORT:-9999}
CONF_DIR=${PWD}/conf.d
CONTAINER_IMAGE=${PREFIX:-${1:-viaq/}}logstash

cp ./data/* ./conf.d/

docker run -p ${LISTEN_PORT}:${LISTEN_PORT}/tcp \
           -v ${CONF_DIR}:/etc/logstash/conf.d \
           -e ES_HOST=${ES_HOST} \
           -e ES_PORT=${ES_PORT} \
           -e LOGSTASH_PREFIX=${LOGSTASH_PREFIX} \
           -e NORMALIZER_NAME=${NORMALIZER_NAME} \
           -e NORMALIZER_HOSTNAME=${NORMALIZER_HOSTNAME} \
           -e LISTEN_PORT=${LISTEN_PORT} \
            ${ENV_DEBUG} --name ${CONTAINER_NAME} ${CONTAINER_IMAGE}
