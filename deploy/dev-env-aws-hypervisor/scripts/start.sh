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

# Check and restart the proxy container for immediate proxy capabilities
echo "Checking proxy container status..."
set +e  # Allow commands to fail for proxy container checks
ssh -o ConnectTimeout=10 -o StrictHostKeyChecking=no "$(cat ${SHARED_DIR}/ssh_user)@${HOST_PUBLIC_IP}" << 'EOF'
    echo "Checking external-squid proxy container..."
    
    # Check if the container exists and get its status
    CONTAINER_STATUS=$(podman ps -a --filter name=external-squid --format "{{.Status}}" 2>/dev/null || echo "not found")
    
    if [[ "${CONTAINER_STATUS}" == "not found" ]]; then
        echo "Proxy container not found - may not be deployed yet"
    elif [[ "${CONTAINER_STATUS}" =~ ^Up ]]; then
        echo "Proxy container is already running: ${CONTAINER_STATUS}"
    else
        echo "Proxy container exists but not running: ${CONTAINER_STATUS}"
        echo "Attempting to restart proxy container..."
        podman restart external-squid && echo "Proxy container restarted successfully" || echo "Failed to restart proxy container"
    fi
    
    # Give a moment for the container to start
    sleep 5
    
    # Final status check
    FINAL_STATUS=$(podman ps --filter name=external-squid --format "{{.Status}}" 2>/dev/null || echo "not running")
    if [[ "${FINAL_STATUS}" =~ ^Up ]]; then
        echo "Proxy container is now running and ready for use"
    else
        echo "Warning: Proxy container may not be running properly"
    fi
EOF
set -e  # Re-enable exit on error

echo "Instance started successfully!"
echo ""
echo "IMPORTANT: OpenShift cluster recovery options:"
echo ""
echo "If you previously shutdown your cluster:"
echo "  - Start up the cluster: make startup-cluster"
echo ""
echo "If you need to deploy a new cluster:"
echo "  - Clean and redeploy: make redeploy-cluster"
echo "  - For manual deployment: cd ../ipi-baremetalds-virt && follow README" 