.PHONY: help

help:                       ## Show this help
	@fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -e 's/\\$$//' | sed -e 's/##//'

start-containers:          ## Deploys application and mysql containers
	 docker-compose -f docker-compose.yml -f docker-compose.override.yml up --detach --force-recreate
	 # ./scripts/containers.sh wait_for_mysql_health

stop-containers:          ## Stops the DB containers
	 docker ps --format "{{.Names}}" | grep spring-kubernetes | xargs docker kill || true

connect-mysql:          ## Connect to mysql using root user
	docker exec -it spring-kubernetes_mysql_1 mysql -uroot -p
	#docker run -it --network spring-kubernetes_default --rm mysql mysql -hspring-kubernetes_mysql_1 -uexample-user -p
	 
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

test-all:                   ## Runs all tests
	 make test-unit test-contracts test-integration test-component

db-setup:                   ## Creates database tables
	 ./scripts/make_commands.sh db_setup

pre-push:                   ## This runs all the tests and if all pass, then gives message to push
	 ./scripts/pre-push.sh
