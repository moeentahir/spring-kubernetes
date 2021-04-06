#!/bin/bash

set -eu -o pipefail

ROOT_DIR=$(git rev-parse --show-toplevel)

function set_env() {
  GOSU_UID="$(id -u)" && export GOSU_UID
  GOSU_GID="$(id -g)" && export GOSU_GID
}

function unset_env() {
  unset GOSU_UID && unset GOSU_GID
}

function package_led_in_jetty_image() {
  pushd "${ROOT_DIR}/spring-kubernetes-dist"
  mvn package -Dpackaging=true -Pdocker
  popd
}

function is_mysql_up() {
  DOCKER_STATUS="$(mktemp)"
  docker ps > "$DOCKER_STATUS"
  if grep -q "healthy" "$DOCKER_STATUS"
  then echo 1
  else echo 0
  fi
}

function wait_for_mysql_health() {
  echo -n "===> Waiting for containers to be up (db & jetty):"

  while true; do
	local mysql_is_up
	mysql_is_up="$(is_mysql_up)"
	if [ "$mysql_is_up" == "0" ]
	then
	  echo -n "." && sleep 1
	else
	  echo " done." && return 0
	fi
  done

}

function health(){
  chmod -R +x ci/*
  ci/pipeline/ping/health.sh "curl -s 'http://localhost:8080/led/actuator/health' | jq -r '.status'" "UP" 10
}

function start_containers() {

  set_env
  docker-compose -f docker-compose.yml -f docker-compose.override.yml up --detach --force-recreate
  unset_env

}

function stop_containers() {
  docker ps --format "{{.Names}}" | grep spring-kubernetes | xargs docker kill || true

}

function start() {
  stop_containers
  start_containers
  health
}

"$@"
