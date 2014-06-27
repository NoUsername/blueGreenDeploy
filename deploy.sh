#!/bin/bash
set -e

DEFAULT_DIR=$(PWD)

NGINXCONF="C:/nginx/conf/backend.conf"
NGINX_RELOAD_SCRIPT="cd C:/nginx; ./nginx.exe -s reload;"
SERVICE_START_SECS=5

if [ -f "deploy-conf.local" ]; then
  source deploy-conf.local
fi

mkdir -p green
mkdir -p blue

if [ "$#" -lt "1" ]; then
  echo "argument missing"
  exit 1
fi

BACKEND="blue"
PORT="8081"

if [ "$1" == "green" ]; then
  BACKEND="green"
  PORT="8082"
fi

function buildService {
  go build server.go
}

function deployService {
  cd $DEFAULT_DIR
  cp -f server.exe $BACKEND
  cd $BACKEND
  # note here could be 
  bash -c "./server.exe -port ${PORT} -message 'SERVER hello from ${BACKEND} backend'" &
  cd $DEFAULT_DIR
}

function checkServiceOk {
  echo "giving service some time to start"
  sleep $SERVICE_START_SECS
  echo "checking service"
  curl -q --connect-timeout 10 --max-time 10 http://localhost:${PORT}/
  if [ "$?" != "0" ]; then
    echo "ERROR: service does not seem to be deployed correctly"
    exit 1
  fi
  echo -e "\nservice seems ok"
}

function updateNginxConfig {
  echo "activating new backend"
  echo "set \$activeBackend ${BACKEND};" > $NGINXCONF

  echo "running $NGINX_RELOAD_SCRIPT"
  bash -c "$NGINX_RELOAD_SCRIPT"
  cd $DEFAULT_DIR
}

buildService

deployService

checkServiceOk

updateNginxConfig
