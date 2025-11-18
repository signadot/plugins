#!/bin/bash
# exit when any command fails
set -e

echo "Provisioning a MariaDB server"
echo "Sandbox id: ${SIGNADOT_SANDBOX_ID}"
echo "Resource name: ${SIGNADOT_RESOURCE_NAME}"
echo "DB name: ${DBNAME}"

# Install bitnami helm chart repo
helm repo add bitnami https://charts.bitnami.com/bitnami

# Deploy a temporary DB for this Sandbox
export NAMESPACE=signadot
RELEASE_NAME="signadot-${SIGNADOT_RESOURCE_NAME,,}-${SIGNADOT_SANDBOX_ID}"
echo "Installing Helm release: ${RELEASE_NAME}"
helm -n ${NAMESPACE} install "${RELEASE_NAME}" bitnami/mariadb \
--version 11.5.0 --wait --timeout 5m0s \
--set fullnameOverride="${RELEASE_NAME}-mariadb" \
--set primary.persistence.enabled=false \
--set serviceAccount.create=false \
--set auth.database="${DBNAME}" \
--set global.imageRegistry=docker.io \
--set global.repository=bitnamilegacy

# Get the generated password, based on instructions from the Helm chart.
MYSQL_ROOT_PASSWORD=$(kubectl -n ${NAMESPACE} get secret "${RELEASE_NAME}-mariadb" -o jsonpath="{.data.mariadb-root-password}" | base64 -d)

# Populate the outputs
DBHOST="${RELEASE_NAME}-mariadb.${NAMESPACE}.svc"
echo -n "${DBHOST}" > /tmp/host
echo -n 3306 > /tmp/port
echo -n "${MYSQL_ROOT_PASSWORD}" > /tmp/root-password