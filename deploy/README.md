# Deploy

This directory contains deployment tools and scripts for setting up EC2 instances and OpenShift clusters for development purposes.

## Prerequisites

### AWS CLI
You will need to have the AWS CLI configured and the `AWS_PROFILE` environment variable set.

For getting and configuring the CLI: https://docs.aws.amazon.com/cli/

You can check if you have the AWS CLI properly configured by running:

```bash
$ aws configure list
      Name                    Value             Type    Location
      ----                    -----             ----    --------
   profile            openshift-dev              env    ['AWS_PROFILE', 'AWS_DEFAULT_PROFILE']
access_key     ****************4SU3 shared-credentials-file    
secret_key     ****************z0DF shared-credentials-file    
    region                us-east-2      config-file    ~/.aws/config
```

### Dependencies
The following programs must be present in your local environment:
- make
- aws
- jq
- rsync
- golang

Also:
- .ssh/config file must exist

#### Extra dependencies
For automatic Redfish Pacemaker configuration on 4.19, you also need:
- Python3 kubernetes library (https://pypi.org/project/kubernetes/)

Additionally, if you're using Mac OS, you might not have `timeout`, so you might also need to install coreutils, for example via brew:
`brew install coreutils`

## Configuration

Before deployment, configure your environment by setting up the `aws-hypervisor/instance.env` file. Copy `aws-hypervisor/instance.env.template` to `aws-hypervisor/instance.env` and set all variables to valid values for your user.

## Available Commands

To see all available commands, run:
```bash
$ make help
```

### Quick Start
```bash
# Create, initialize, and update inventory for a new EC2 instance
$ make deploy
```

This will create the instance, initialize it, and update the inventory in one command, placing you in a login shell for the EC2 instance.

### Basic Instance Operations
```bash
# Create new EC2 instance
$ make create

# Initialize deployed instance  
$ make init

# Update inventory.ini with current instance IP
$ make inventory

# SSH into the EC2 instance
$ make ssh

# Get instance info
$ make info

# Start a stopped instance
$ make start

# Stop a running instance (with cluster management options)
$ make stop

# Completely destroy the instance
$ make destroy
```

### OpenShift Cluster Management

When running OpenShift clusters on the instance (using dev-scripts), you have several options for managing cluster lifecycle:

**Quick deployment commands:**
- `make fencing-ipi` and `make arbiter-ipi` provide non-interactive deployment for specific topologies
- These commands automatically call the underlying setup.yml playbook with the appropriate configuration
- Useful for automation and when you know exactly which topology you want to deploy

#### Option 1: Graceful Cluster Shutdown/Startup (Not recommended due to speed)
```bash
# Gracefully shutdown the cluster VMs before stopping the instance
$ make shutdown-cluster

# Stop the instance (cluster VMs are preserved in shutdown state)
$ make stop

# Start the instance again
$ make start

# Start up the cluster VMs and proxy container
$ make startup-cluster
```

#### Option 2: Redeploy Cluster (Clean and Rebuild)
```bash
# Redeploy the cluster (clean existing and rebuild)
$ make redeploy-cluster

# Quick deployment for specific topologies (non-interactive)
$ make fencing-ipi    # Deploy fencing topology
$ make arbiter-ipi    # Deploy arbiter topology
```

This option:
- Automatically cleans up the existing cluster
- Supports interactive mode selection (arbiter or fencing)
- Intelligently detects cluster topology changes
- For same topology: Uses make redeploy (fast, preserves cached data)
- For topology changes: Uses make realclean + full installation (slower but clean)
- Integrates with Ansible playbooks for orchestration

**When to use redeploy:**
- When you want to refresh the cluster with the latest changes
- After updating dev-scripts configuration
- When the cluster is in an inconsistent state
- For testing deployment changes
- When switching between cluster modes (arbiter ↔ fencing)

#### Option 3: Delete Cluster and Clean Server
```bash
# Delete the cluster and clean the server using Ansible
$ cd openshift-clusters && ansible-playbook clean.yml -i inventory.ini

# Stop the instance
$ make stop

# When restarted, you'll need to redeploy the cluster from scratch
$ make start
```

#### Option 4: Forcible Stop (Cluster Lost)
```bash
# Force stop the instance (cluster will be lost)
$ make stop
# Choose option 4 when prompted

# When restarted, you'll need to redeploy the cluster
$ make start
```

## Cluster Management Details

**Important: "Clean" operations delete the cluster completely. All cluster data, configurations, and workloads will be permanently lost.**

**Shutdown/Startup Workflow:**
- `make shutdown-cluster`: Gracefully shuts down all cluster VMs and saves VM list
- `make stop`: Stops the EC2 instance safely (cluster VMs already shut down)
- `make start`: Restarts the EC2 instance and checks proxy container status
- `make startup-cluster`: Restarts cluster VMs using saved VM list and ensures proxy availability

**Benefits:**
- Preserves cluster state and data
- Faster cluster recovery (no rebuild needed)
- Maintains cluster certificates and configuration
- Handles proxy container lifecycle automatically

**Limitations:**
- Requires proper shutdown sequence to preserve VM list
- May need cluster health checks after startup
- Some cluster components might need time to stabilize

**Redeploy Integration:**
- Integrates with `openshift-clusters` Ansible playbooks
- Supports both arbiter and fencing cluster modes
- Tracks cluster state to detect configuration changes
- Same topology: Fast redeploy preserves cached data
- Topology changes: Complete rebuild (realclean + full install) ensures clean state

**When to Use Each Method:**
- **Shutdown/Startup**: For temporary shutdowns, preserving work, cost savings
- **Redeploy**: For changing configurations, updating deployments, switching cluster modes
- **Delete and Clean**: For planned maintenance, manual control over cleanup
- **Forcible Stop**: For emergency stops, when cluster is corrupted

## Interactive Stop Script

When running `make stop` on an instance with a running OpenShift cluster, you'll be presented with options:

1. **Shutdown the cluster VMs**: Runs `make shutdown-cluster` first (recommended)
2. **Delete cluster and clean server**: Runs Ansible cleanup playbook
3. **Continue with forcible stop**: Stops instance immediately (cluster lost)

The script automatically detects:
- OpenShift dev-scripts installations
- Running cluster VMs
- Cluster state and provides appropriate options

## Instance Recovery Options

After restarting an instance with `make start`, you'll see guidance for:

**If you previously shutdown your cluster:**
```bash
# Start up the existing cluster
$ make startup-cluster
```

**If you need to create or redeploy a cluster:**
```bash
# Option 1: Automated redeploy with mode selection
$ make redeploy-cluster

# Option 2: Manual Ansible approach
$ cd openshift-clusters
$ ansible-playbook clean.yml -i inventory.ini
$ ansible-playbook setup.yml -i inventory.ini
```

## Troubleshooting Cluster Management

If cluster startup fails:
```bash
# Check cluster status manually
$ make ssh
$ cd ~/openshift-metal3/dev-scripts
$ oc --kubeconfig=ocp/<cluster-name>/auth/kubeconfig get nodes

# If cluster is unrecoverable, clean and redeploy
$ make redeploy-cluster
```

If VMs don't start properly:
```bash
# Check VM states manually
$ make ssh
$ sudo virsh list --all
$ sudo virsh domstate <vm-name>

# Manually start VMs if needed
$ sudo virsh start <vm-name>
```

If proxy container issues occur:
```bash
# Check proxy container status
$ make ssh
$ podman ps --filter name=external-squid

# Restart proxy if needed
$ podman restart external-squid
```

## Advanced Features

**Cluster State Tracking:**
- State saved in `aws-hypervisor/instance-data/cluster-vm-state.json`
- Tracks deployment mode (arbiter/fencing)
- Detects configuration changes for intelligent cleanup

**VM Infrastructure Management:**
- Automatic detection of VM configuration changes
- Safe cleanup when switching between cluster types
- Preservation of VM infrastructure when possible

**Proxy Container Management:**
- Automatic proxy container lifecycle management
- Integration with cluster startup/shutdown workflows
- Status checking and recovery capabilities 