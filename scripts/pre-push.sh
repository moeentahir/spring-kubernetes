#!/bin/bash


function clean_submodule() {
    git submodule foreach --recursive git checkout .
    git submodule update
}

function verify_uncommitted_changes() {
  changes_count=$(git status --short | wc -l)
  if [[ "$changes_count" -gt 0 ]]
  then
    echo "You have uncommitted changes. Please commit or stash them first."
    exit 1
  fi
}

function  run_tests() {
  message="\n--------------------------------------------------------------"
  message+="\nTest \t\t\t\t\t\tResult"
  message+="\n--------------------------------------------------------------"
  test_result="PASS"
  overall_result=0
  operations=(test_unit start_containers db_setup test_integration db_setup_componenttest_ci test_component test_contracts)

  for operation in ${operations[@]}; do
    echo "********************* Running ${operation//_/-} **********************"
    ./scripts/src/make_commands.sh "$operation"

    if [[ "$?" -ne 0 ]] ; then
      test_result="FAIL"
      message+="\n$operation \t\t\t\t\t $test_result"
      overall_result=1
      break
    fi
    message+="\n$operation \t\t\t\t\t $test_result"
  done

  echo -e "$message"

  if [[ "$overall_result" -ne 0 ]]
  then
    exit 1
  else
    banner -w 30 PUSH
    exit 0
  fi
}

function main() {
  clean_submodule
  verify_uncommitted_changes
  run_tests
}

main
