#!/bin/bash

SCRIPT_DIR=$(dirname "$0")
source "${SCRIPT_DIR}/../instance.env"

set -o nounset
set -o errexit
set -o pipefail

# Paths
INVENTORY_DIR="${SCRIPT_DIR}/../../openshift-clusters"
INVENTORY_FILE="${INVENTORY_DIR}/inventory.ini"
INVENTORY_TEMPLATE="${INVENTORY_DIR}/inventory.ini.sample"

# Check if instance data exists
if [[ ! -f "${SCRIPT_DIR}/../${SHARED_DIR}/public_address" ]]; then
    echo "Error: No public address found. Please run 'make deploy' first."
    exit 1
fi

if [[ ! -f "${SCRIPT_DIR}/../${SHARED_DIR}/ssh_user" ]]; then
    echo "Error: No ssh user found. Please run 'make deploy' first."
    exit 1
fi

# Read instance data
PUBLIC_IP=$(cat "${SCRIPT_DIR}/../${SHARED_DIR}/public_address" | tr -d '\n')
SSH_USER=$(cat "${SCRIPT_DIR}/../${SHARED_DIR}/ssh_user" | tr -d '\n')

echo "Updating inventory with:"
echo "  User: ${SSH_USER}"
echo "  IP:   ${PUBLIC_IP}"

# Create the host entry
HOST_ENTRY="${SSH_USER}@${PUBLIC_IP} ansible_ssh_extra_args='-o ServerAliveInterval=30 -o ServerAliveCountMax=120'"

# Check if inventory file exists
if [[ -f "${INVENTORY_FILE}" ]]; then
    echo "Updating existing inventory file..."
    
    # Create a backup in the inventory-backup directory
    BACKUP_DIR="${INVENTORY_DIR}/inventory-backup"
    mkdir -p "${BACKUP_DIR}"
    cp "${INVENTORY_FILE}" "${BACKUP_DIR}/inventory.ini.backup.$(date +%s)"
    
    # Update the host entry in the [metal_machine] section
    # Use sed to replace the line after [metal_machine] that contains '@'
    sed -i '/^\[metal_machine\]$/,/^\[/ {
        /^[^[].*@.*/ c\
'"${HOST_ENTRY}"'
    }' "${INVENTORY_FILE}"
    
    echo "Updated existing inventory file: ${INVENTORY_FILE}"
else
    echo "Creating new inventory file from template..."
    
    # Check if template exists
    if [[ ! -f "${INVENTORY_TEMPLATE}" ]]; then
        echo "Error: Template file not found: ${INVENTORY_TEMPLATE}"
        exit 1
    fi
    
    # Copy template and replace placeholders
    cp "${INVENTORY_TEMPLATE}" "${INVENTORY_FILE}"
    
    # Replace template placeholders
    sed -i "s|<machine_user>@<machine_ip_address>|${HOST_ENTRY}|g" "${INVENTORY_FILE}"
    
    echo "Created new inventory file: ${INVENTORY_FILE}"
fi

echo "Inventory file updated successfully!"
echo ""
echo "Current inventory content:"
cat "${INVENTORY_FILE}" 