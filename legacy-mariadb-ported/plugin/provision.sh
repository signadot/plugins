#!/bin/bash
# exit when any command fails
set -e

mkdir -p /signadot/plugin/output
/signadot/plugin/bin/provision ${SIGNADOT_SANDBOX_ID} ${SIGNADOT_RESOURCE_NAME}