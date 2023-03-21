#!/bin/sh

set -e

RABBIT_SECRET_DIR="${RABBIT_SECRET_DIR:-/rabbitmq-auth}"

echo "Deprovisioning vhost with rabbitmq"
echo "Sandbox id: ${SIGNADOT_SANDBOX_ID}"
echo "Resource name: ${SIGNADOT_RESOURCE_NAME}"

# Get values passed to us as "params" in the Sandbox's "resources" section.
# Get the values provided to the plugin for secret access to 
RABBIT_SVC_NS=$(cat "${RABBIT_SECRET_DIR}/svc-namespace")
RABBIT_SVC_NAME=$(cat "${RABBIT_SECRET_DIR}/svc-name")
RABBIT_USERNAME=$(cat "${RABBIT_SECRET_DIR}/username")
RABBIT_PASSWORD=$(cat "${RABBIT_SECRET_DIR}/password")


HOSTNAME=${RABBIT_SVC_NAME}.${RABBIT_SVC_NS}.svc
#HOSTNAME=localhost

# Choose a queue name that's unique to this resource in this sandbox.
VHOST_NAME="/sd-${SIGNADOT_RESOURCE_NAME}-${SIGNADOT_SANDBOX_ID}"
HOSTNAME=${RABBIT_SVC_NAME}.${RABBIT_SVC_NS}.svc

for user in $RABBIT_USERS; do
	echo "deleting permissions for ${user}"
	rabbitmqadmin --host=${HOSTNAME} \
		--port=15672 \
		--username=${RABBIT_USERNAME} \
		--password=${RABBIT_PASSWORD} \
		delete permission vhost=${VHOST_NAME} user=${user}
done

rabbitmqadmin --host=${HOSTNAME} \
	--port=15672 \
	--username=${RABBIT_USERNAME} \
	--password=${RABBIT_PASSWORD} \
	delete vhost name=${VHOST_NAME}
