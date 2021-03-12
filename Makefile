#
# Makefile for Ledger
#

.PHONY: help

help:                       ## Show this help
	@fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -e 's/\\$$//' | sed -e 's/##//'

jetty-start: 		    ## Starts jetty in the background
	./scripts/make_commands.sh jetty_start

jetty-stop: 		    ## Stops any running jetty instance
	./scripts/make_commands.sh jetty_stop


jetty-compile-start:        ## Compiles the code and starts the jetty server
	./scripts/make_commands.sh jetty_compile_and_start

test-unit:                  ## Runs unit tests (mvn test)
	./scripts/make_commands.sh test_unit

test-integration:           ## Runs integration tests (mvn test)
	./scripts/make_commands.sh test_integration

test-contracts:	 	    ## Runs contract test (mvn pact:verify)
	./scripts/make_commands.sh test_contracts

test-component:	 	    ## Runs component tests assuming application is running on localhost:8080
	./scripts/make_commands.sh test_component

test-component-ci:	    ## Runs component tests assuming application is running on localhost:8080
	./scripts/make_commands.sh test_component_ci

test-all:                   ## Runs all tests
	 make test-unit test-contracts test-integration test-component

db-setup:                   ## Creates database tables
	 ./scripts/make_commands.sh db_setup

db-setup-ci:                ## Creates database tables to run in Jenkins
	 ./scripts/make_commands.sh db_setup_ci

db-setup-componenttest:                   ## Creates database tables to run in Jenkins
	 ./scripts/make_commands.sh db_setup_componenttest

db-setup-componenttest-ci:                   ## Creates database tables to run in Jenkins
	 ./scripts/make_commands.sh db_setup_componenttest_ci

deploy-containers:          ## Deploys application and oracle containers
	 ./scripts/make_commands.sh start_containers


pre-push:                   ## This runs all the tests and if all pass, then gives message to push
	 ./scripts/pre-push.sh
