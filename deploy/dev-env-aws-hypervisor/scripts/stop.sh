#!/bin/bash

source ./instance.env

set -o nounset
set -o errexit
set -o pipefail

# Check if the instance exists and get its ID
if [[ ! -f "${SHARED_DIR}/aws-instance-id" ]]; then
    echo "Error: No instance found. Please run 'make deploy' first."
    exit 1
fi

INSTANCE_ID=$(cat "${SHARED_DIR}/aws-instance-id")
echo "Stopping instance ${INSTANCE_ID}..."

# Check current instance state
INSTANCE_STATE=$(aws --region "${REGION}" ec2 describe-instances --instance-ids "${INSTANCE_ID}" --query 'Reservations[0].Instances[0].State.Name' --output text)
echo "Current instance state: ${INSTANCE_STATE}"

case "${INSTANCE_STATE}" in
    "stopped")
        echo "Instance is already stopped."
        ;;
    "running")
        echo "Stopping instance..."
        aws --region "${REGION}" ec2 stop-instances --instance-ids "${INSTANCE_ID}"
        echo "Waiting for instance to stop..."
        aws --region "${REGION}" ec2 wait instance-stopped --instance-ids "${INSTANCE_ID}"
        echo "Instance stopped successfully."
        ;;
    "stopping")
        echo "Instance is already stopping. Waiting for it to stop completely..."
        aws --region "${REGION}" ec2 wait instance-stopped --instance-ids "${INSTANCE_ID}"
        echo "Instance stopped successfully."
        ;;
    "pending")
        echo "Instance is starting. Waiting for it to be running first..."
        aws --region "${REGION}" ec2 wait instance-running --instance-ids "${INSTANCE_ID}"
        echo "Now stopping instance..."
        aws --region "${REGION}" ec2 stop-instances --instance-ids "${INSTANCE_ID}"
        echo "Waiting for instance to stop..."
        aws --region "${REGION}" ec2 wait instance-stopped --instance-ids "${INSTANCE_ID}"
        echo "Instance stopped successfully."
        ;;
    *)
        echo "Error: Instance is in an unexpected state: ${INSTANCE_STATE}"
        exit 1
        ;;
esac

echo "Instance ${INSTANCE_ID} is now stopped."
echo "Note: The instance can be restarted with 'make start'." 