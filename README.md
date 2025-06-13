# TWO-NODE TOOLBOX
## Introduction
This repository contains tools to deploy testing or development two-node Openshift clusters.

## Creating a dev environment
These tools expect a valid RHEL hypervisor to host all necessary VMs to create and set up the cluster.
If you don't already have one available, the [dev-env-aws-hypervisor](deploy/dev-env-aws-hypervisor/) folder provides instructions and tools to automatically create this base host in AWS.

Once the hypervisor is setup, you can use the [TNA](deploy/tna-ipi-baremetalds-virt/) and TNF folders to create those specific clusters within that newly provisioned host, or on your own one. 

## Two-node available topologies
Tools for installing a Two-Node with Arbiter cluster can be found at [Two Node with Arbiter](deploy/tna-ipi-baremetalds-virt/). 
General documentation on these specific OpenShift topoliges can be found in the [docs](docs) folder.