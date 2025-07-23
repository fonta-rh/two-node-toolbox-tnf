#!/bin/bash

SCRIPT_DIR=$(dirname "$0")
source "${SCRIPT_DIR}/../init.sh"

instance_ip=$(cat ${SCRIPT_DIR}/../${SHARED_DIR}/public_address)
host=$(cat ${SCRIPT_DIR}/../${SHARED_DIR}/ssh_user)

ssh_host_ip="$host@$instance_ip"

ssh "$ssh_host_ip" "sudo subscription-manager unregister"

aws --region $REGION cloudformation delete-stack --stack-name "${STACK_NAME}"

echo "waiting for stack $STACK_NAME to be deleted"
aws --region $REGION cloudformation wait stack-delete-complete --stack-name "${STACK_NAME}" &
wait "$!"

rm -rf "${SCRIPT_DIR}/../${SHARED_DIR:?}/"*

echo "deleted stack ${STACK_NAME}" > "${SCRIPT_DIR}/../${SHARED_DIR}/.done"
