#!/bin/bash

set -eu -o pipefail

ROOT_DIR=$(git rev-parse --show-toplevel)
JETTY_OUTPUT=$(mktemp)
TIMEOUT_SECONDS=500

function it_wasnt_me() {
	local jetty_run
	# pgrep is not helping much in this case, we want 'jetty:run'
	# shellcheck disable=SC2009
	jetty_run="$(ps -ef|grep -c "jetty:run")"
	if [[ "$jetty_run" -gt 1 ]]; then
		echo " Jetty is already running" && return 3
	fi
}

function jetty_start() {
	it_wasnt_me
	echo -n "Starting Jetty "
	pushd "${ROOT_DIR}/led-server-ws"
	mvn jetty:run > "$JETTY_OUTPUT" &
	popd
	wait_for_jetty_startup
}

function jetty_stop() {
	pushd "${ROOT_DIR}/led-server-ws"
	echo -n "Stopping Jetty ..."
	mvn jetty:stop > "$JETTY_OUTPUT" &
	echo -n " done"
	popd
}

function is_jetty_up() {
	if grep -q "Started Jetty Server" "$JETTY_OUTPUT"
	then echo 1
	else echo 0
	fi
}

function wait_for_jetty_startup() {
	local time_elapsed=0
	while true; do
		local jetty_started
		jetty_started="$(is_jetty_up "$JETTY_OUTPUT")"
		if [ "$jetty_started" == "0" ]
		then
			((time_elapsed+=1))
			[ $time_elapsed -gt "$TIMEOUT_SECONDS" ] \
				&& echo "Timeout of $TIMEOUT_SECONDS exceeded, giving up." \
				&& return 2
			echo -n "."
			sleep 1
		else
			echo " done."
			return 0
		fi
	done
}

function test_unit() {
    ./ci/pipeline/test/clean_install_and_unit_test.sh
}

function test_component(){
  echo "==============Running component tests===================="
  pushd "${ROOT_DIR}/led-server-component-test"
  mvn clean test -Dtest-component=component
  popd
  echo "==============Finished running component tests===================="
}

function test_component_ci(){
  echo "==============Running component tests===================="
  pushd "${ROOT_DIR}/led-server-component-test"
  mvn -Dled.server.deployment.host="$LEDGER_PORT_8080_TCP_ADDR" -Dtest-component=component clean test
  popd
  echo "==============Finished running component tests===================="
}

function test_integration() {
	pushd "${ROOT_DIR}/led-server-repository"
	mvn clean test -Dintegration-test-dao=dao -Pjacoco
	popd "$ROOT_DIR"
}

function test_contracts() {
  ./ci-test/test/producer.sh
#exit 0
}


function db_setup(){
  ./scripts/src/containers.sh wait_for_oracle_health
	pushd "${ROOT_DIR}/led-db-dist"
	mvn -Dflyway=true -Pdev flyway:clean flyway:migrate
	popd
}

function db_setup_ci(){
  ./scripts/src/containers.sh wait_for_oracle_health
	pushd "${ROOT_DIR}/led-db-dist"
	mvn -Dflyway=true -Pci flyway:clean flyway:migrate
	popd
}

function db_setup_componenttest_ci(){
  ./scripts/src/containers.sh wait_for_oracle_health
	pushd "${ROOT_DIR}/led-db-dist"
	mvn -Pci -Dflyway=true flyway:clean flyway:migrate
	mvn verify -Pci -Punpack -Pflyway-component-test flyway:migrate
	popd
}

function db_setup_componenttest(){
  ./scripts/src/containers.sh wait_for_oracle_health
	pushd "${ROOT_DIR}/led-db-dist"
	mvn -Pdev -Dflyway=true flyway:clean flyway:migrate
	mvn verify -Pdev -Punpack -Pflyway-component-test flyway:migrate
	popd
}

function jetty_compile_and_start() {
	mvn clean install
	jetty_start
}

function start_containers() {
  ./scripts/src/containers.sh start
}

"$@"
