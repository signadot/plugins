#!/usr/bin/env bash

set -e

rabbitmqctl add_user test 123
rabbitmqctl set_user_tags test administrator 
rabbitmqctl set_permissions -p / test ".*" ".*" ".*"
