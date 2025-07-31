# Helpers

Utilities for installing RPM packages on OpenShift cluster nodes using rpm-ostree.

## Description

This directory contains scripts and playbooks for patching OpenShift cluster nodes with RPM packages, specifically designed for resource agent updates. The tools use rpm-ostree's override functionality to replace packages on immutable CoreOS nodes.

## Requirements

### For resource-agents-patch.sh
- `oc` CLI tool (logged into OpenShift cluster)
- `jq` for JSON processing
- SSH access to cluster nodes

### For resource-agents-patch.yml
- Ansible
- Inventory file containing OpenShift cluster nodes (separate from hypervisor deployment inventory, see `inventory_ocp_hosts.sample`)
- SSH access configured for `core` user

## Usage

### Shell Script

```bash
./resource-agents-patch.sh /path/to/package.rpm
```

**Process:**
1. Validates required tools and RPM file
2. Discovers all node IPs via OpenShift API
3. Copies RPM to each node using SCP
4. Installs package with `rpm-ostree override replace`
5. Provides manual reboot commands

### Ansible Playbook

```bash
ansible-playbook -i inventory_ocp_hosts resource-agents-patch.yml -e rpm_full_path=/path/to/package.rpm
```

**Note**: The inventory file should list the OpenShift cluster nodes (VMs), not the hypervisor host. Copy `inventory_ocp_hosts.sample` to `inventory_ocp_hosts` and update with your cluster node IPs.

**Process:**
1. Validates RPM file existence
2. Copies RPM to all nodes
3. Installs using rpm-ostree override
4. Reboots nodes one at a time
5. Verifies etcd health after reboot

## Notes

- Both tools use `rpm-ostree override replace` which is appropriate for updating existing packages
- Node reboots are required to activate rpm-ostree changes
- The Ansible playbook handles rebooting automatically; the shell script requires manual intervention
- Plan reboots carefully to maintain cluster availability
- Monitor cluster health during the patching process 