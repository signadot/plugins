#!/usr/bin/env bash

set -e

echo "Provisioning a vhost with rabbitmq"
echo "Sandbox id: ${SIGNADOT_SANDBOX_ID}"
echo "Resource name: ${SIGNADOT_RESOURCE_NAME}"

#
# Get values passed to us as "params" in the Sandbox's "resources" section.
# defaults can help debugging.
#
RABBIT_REF_VHOST="${RABBIT_REF_VHOST:-/}"
RABBIT_USERS="${RABBIT_USERS:-test}"

#
# Get the values provided to the plugin for secret access to 
# setup rabbitmq vhosts
#
RABBIT_SECRET_DIR="${RABBIT_SECRET_DIR:-/rabbitmq-auth}"
RABBIT_SVC_NS=$(cat "${RABBIT_SECRET_DIR}/svc-namespace")
RABBIT_SVC_NAME=$(cat "${RABBIT_SECRET_DIR}/svc-name")
RABBIT_USERNAME=$(cat "${RABBIT_SECRET_DIR}/username")
RABBIT_PASSWORD=$(cat "${RABBIT_SECRET_DIR}/password")

#
# install jq
#
curl  -L https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64 -o /bin/jq
chmod +x /bin/jq


HOSTNAME=${RABBIT_SVC_NAME}.${RABBIT_SVC_NS}.svc
# uncomment to test on localhost with port-forwarding
#HOSTNAME=localhost

# Choose a vhost name that is unique to this sandbox.
VHOST_NAME="/sd-${SIGNADOT_RESOURCE_NAME}-${SIGNADOT_SANDBOX_ID}"
echo "Creating vhost: ${VHOST_NAME}"

#
# create vhost
#
rabbitmqadmin --host=${HOSTNAME} \
	--port=15672 \
	--username=${RABBIT_USERNAME} \
	--password=${RABBIT_PASSWORD} \
	declare vhost name=$VHOST_NAME


#
# clone users' access from reference vhost to new vhost
#
COMMON_ARGS="-f raw_json --host=${HOSTNAME} --port=15672 --username=${RABBIT_USERNAME} --password=${RABBIT_PASSWORD}"

for user in $RABBIT_USERS; do
	r=$(rabbitmqadmin ${COMMON_ARGS} list permissions | jq -r '.[] | select(.vhost=="'"${RABBIT_REF_VHOST}"'" and .user=="'"${user}"'") | .read')
	w=$(rabbitmqadmin ${COMMON_ARGS} list permissions | jq -r '.[] | select(.vhost=="'"${RABBIT_REF_VHOST}"'" and .user=="'"${user}"'") | .write')
	c=$(rabbitmqadmin ${COMMON_ARGS} list permissions | jq -r '.[] | select(.vhost=="'"${RABBIT_REF_VHOST}"'" and .user=="'"${user}"'") | .configure')
	rabbitmqadmin --host=${HOSTNAME} \
		--port=15672 \
		--username=${RABBIT_USERNAME} \
		--password=${RABBIT_PASSWORD} \
		declare permission vhost=${VHOST_NAME} user=${user} \
		"read=$r" "write=$w" "configure=$c"
	echo "configured user ${user} read=$r write=$w configure=$c"
done

# 
# store the output
#
echo ${VHOST_NAME} > /tmp/vhost-name
echo "done"
