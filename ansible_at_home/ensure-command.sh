#!/bin/bash
# Ensure that a command is executed only once. 
# More exactly the command only executed if its checking command fails 
#
# parameters:
# $1 is the command to be executed to change state
# $2 is the command to check if the command was already run
#
# examples:
# $ ensure-command.sh 'mkdir /tmp/foo' 'test -d /tmp/foo'
# >>> changed # side effect creates the /tmp/foo directory
# $ ensure-command.sh 'mkdir /tmp/foo' 'test -d /tmp/foo'
# >>> unchanged # does nothing because the check command is a success

set -euo pipefail

state_command=${1:? "The first argument is the state changing command"}
check_command=${2:? "The second argument is the checking command"}

# do not execute $state_command if $check_command is a success
set +e
$check_command
exit_status=$?

if [[ $exit_status -eq 0 ]]; then
    echo 'unchanged'
    exit 0
fi

set -e

# execute state command
$state_command

# return error if state check fails after executing the state command
set +e
$check_command
exit_status=$?

if [[ ! $exit_status -eq 0 ]]; then
    log.sh "$state_command has not fulfilled the check_command: $check_command"
    exit 1
fi

set -e

log.sh "executed: $state_command"

echo 'changed'