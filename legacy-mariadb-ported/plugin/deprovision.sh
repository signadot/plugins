#!/bin/bash
# exit when any command fails
set -e

/signadot/plugin/bin/deprovision ${SIGNADOT_SANDBOX_ID} ${SIGNADOT_RESOURCE_NAME}