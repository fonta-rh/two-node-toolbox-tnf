# TWO-NODE TOOLBOX
## Introduction
This repository contains tools to deploy testing or development two-node Openshift clusters.

## Creating a dev environment
These tools expect a valid RHEL hypervisor to host all necessary VMs to create and set up the cluster.
If you don't already have one available, the [dev-env-aws-hypervisor](deploy/dev-env-aws-hypervisor/README.md) folder provides instructions and tools to automatically create this base host in AWS.

Once the hypervisor is setup, you can use the [deployment tools](deploy/ipi-baremetalds-virt/README.md) to create specific OpenShift clusters within that newly provisioned host, or on your own one. 

## Two-node available topologies
[Two-Node with Arbiter](docs/arbiter/README.md) and [Two-Node with Fencing](docs/fencing/README.md) topologies are available. You can read more on them in the [docs](docs) folder.