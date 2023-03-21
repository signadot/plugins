#!/usr/bin/env bash


set -e

kubectl -n signadot create secret generic rabbitmq-auth --from-file rabbitmq-auth


