#!/bin/bash

# Get the directory where this script is located
SCRIPT_DIR=$(dirname "$0")
# Get the deploy directory (two levels up from scripts)
DEPLOY_DIR="$(cd "${SCRIPT_DIR}/../.." && pwd)"

set -o nounset
set -o errexit
set -o pipefail

# Check if instance data exists
if [[ ! -f "${DEPLOY_DIR}/aws-hypervisor/instance-data/aws-instance-id" ]]; then
    echo "Error: No instance found. Please run 'make deploy' first."
    exit 1
fi

echo "Cleaning OpenShift cluster (using 'clean' target)..."

# Check if inventory.ini exists in the openshift-clusters directory
if [[ ! -f "${DEPLOY_DIR}/openshift-clusters/inventory.ini" ]]; then
    echo "Error: inventory.ini not found in ${DEPLOY_DIR}/openshift-clusters/"
    echo "Please ensure the inventory file is properly configured."
    echo "You can run 'make inventory' to update it with current instance information."
    exit 1
fi

# Navigate to the openshift-clusters directory and run the clean playbook
echo "Running Ansible clean playbook..."
cd "${DEPLOY_DIR}/openshift-clusters"

# Run the clean playbook (uses default complete=false, which runs 'clean' target)
ansible-playbook clean.yml -i inventory.ini

if [[ $? -eq 0 ]]; then
    echo ""
    echo "✓ OpenShift cluster clean completed successfully!"
    echo "The cluster has been cleaned using the 'clean' target."
else
    echo "Error: OpenShift cluster clean failed!"
    echo "Check the Ansible logs for more details."
    exit 1
fi 