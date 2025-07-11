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
echo "Starting instance ${INSTANCE_ID}..."

# Check current instance state
INSTANCE_STATE=$(aws --region "${REGION}" ec2 describe-instances --instance-ids "${INSTANCE_ID}" --query 'Reservations[0].Instances[0].State.Name' --output text)
echo "Current instance state: ${INSTANCE_STATE}"

case "${INSTANCE_STATE}" in
    "running")
        echo "Instance is already running."
        ;;
    "stopped")
        echo "Starting instance..."
        aws --region "${REGION}" ec2 start-instances --instance-ids "${INSTANCE_ID}"
        echo "Waiting for instance to start..."
        aws --region "${REGION}" ec2 wait instance-running --instance-ids "${INSTANCE_ID}"
        echo "Waiting for instance to be ready..."
        aws --region "${REGION}" ec2 wait instance-status-ok --instance-ids "${INSTANCE_ID}"
        ;;
    "stopping")
        echo "Instance is currently stopping. Waiting for it to stop completely..."
        aws --region "${REGION}" ec2 wait instance-stopped --instance-ids "${INSTANCE_ID}"
        echo "Now starting instance..."
        aws --region "${REGION}" ec2 start-instances --instance-ids "${INSTANCE_ID}"
        echo "Waiting for instance to start..."
        aws --region "${REGION}" ec2 wait instance-running --instance-ids "${INSTANCE_ID}"
        echo "Waiting for instance to be ready..."
        aws --region "${REGION}" ec2 wait instance-status-ok --instance-ids "${INSTANCE_ID}"
        ;;
    "pending")
        echo "Instance is already starting. Waiting for it to be ready..."
        aws --region "${REGION}" ec2 wait instance-running --instance-ids "${INSTANCE_ID}"
        aws --region "${REGION}" ec2 wait instance-status-ok --instance-ids "${INSTANCE_ID}"
        ;;
    *)
        echo "Error: Instance is in an unexpected state: ${INSTANCE_STATE}"
        exit 1
        ;;
esac

# Get the current public IP (it may have changed)
HOST_PUBLIC_IP=$(aws --region "${REGION}" ec2 describe-instances --instance-ids "${INSTANCE_ID}" --query 'Reservations[0].Instances[0].PublicIpAddress' --output text)
HOST_PRIVATE_IP=$(aws --region "${REGION}" ec2 describe-instances --instance-ids "${INSTANCE_ID}" --query 'Reservations[0].Instances[0].PrivateIpAddress' --output text)

echo "${HOST_PUBLIC_IP}" > "${SHARED_DIR}/public_address"
echo "${HOST_PRIVATE_IP}" > "${SHARED_DIR}/private_address"

echo "Instance ${INSTANCE_ID} is now running."
echo "Public IP: ${HOST_PUBLIC_IP}"
echo "Private IP: ${HOST_PRIVATE_IP}"

# Update SSH config
echo "Updating SSH config for aws-hypervisor..."
go run main.go -k aws-hypervisor -h "$HOST_PUBLIC_IP"

echo "Instance started successfully!"
echo ""
echo "IMPORTANT: OpenShift cluster recovery options:"
echo ""
echo "If you previously suspended your cluster:"
echo "1. Resume the suspended cluster: make resume-cluster"
echo ""
echo "If you previously deleted the cluster or need to create a new one:"
echo "1. Clean any remaining state: cd ../ipi-baremetalds-virt && ansible-playbook clean.yml -i inventory.ini"
echo "2. Deploy a new cluster: ansible-playbook setup.yml -i inventory.ini"
echo ""
echo "For a fresh deployment, use the two-node-toolbox deployment tools:"
echo "1. Navigate to the deployment directory: cd ../ipi-baremetalds-virt"
echo "2. Follow the deployment guide in the two-node-toolbox repository" 