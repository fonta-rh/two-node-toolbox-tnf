# Two Node with Fencing (TNF)

> Note to deploy a TNF cluster for development please see the [dev deployment guide](../../deploy/tnf-ipi-baremetalds-virt/README.md).

Traditionally, achieving High Availability for the control plane in OpenShift Container Platform requires a minimum of three full control plane (master) nodes to maintain etcd quorum. The **two-node with fencing** configuration introduces a two-node topology that allows for HA with a reduced footprint and potentially lower hardware costs. Clustering is provided via a fencing mechanism based on [RHEL HA](https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/8/html/configuring_and_managing_high_availability_clusters/assembly_overview-of-high-availability-configuring-and-managing-high-availability-clusters#con_pacemaker-overview-overview-of-high-availability).

## What is Fencing?

In a two-node cluster, when one of the nodes reboots or crashes, etcd quorum is lost. The cluster will enter a degraded, read-only state: no new actions can be taken. This will prevent modifications to the cluster state. Additionally, if the nodes lose connectivity to each other, a [split brain](https://en.wikipedia.org/wiki/Split-brain_(computing)) situation will occur. 

**The fencing mechanism** will attempt to restore the etcd cluster to a working state, resuming normal operation. This will be done using **Pacemaker** (resource and recovery through agents) and **Corosync** (networking and messaging).

### Pacemaker and node failures
In order to be able to restore the quorum after an issue with one of the nodes, Pacemaker needs **control of** three critical OpenShift components: **CRI-O, Kubelet and etcd**
- CRI-O and Kubelet are needed to preserve the ordering of services at startup during recovery operations. 
- etcd management is necessary to maintain quorum

Pacemaker can also detect when a node is **rebooting gracefully**:  Manual shutdown commands, upgrade-related or MCO-related reboots.
In these situations, pacemaker will intercept the reboot command and remove the node from the etcd cluster. This will allow for the cluster to continue working as a single node until the reboot is finished and the removed node can resync and rejoin.

When a **node is disconnected or unavailable** (network outages, node crashes, etc), pacemaker will fence the failed node by powering it off via a fencing agent (through the node's BMC).
On the surviving node, pacemaker will force an etcd restart in a single-node configuration, keeping its current status. When the failed node recovers, it will drop its etcd contents and resync to re-join the etcd cluster. 

## Purpose and Motivation

The primary motivation for the fencing mode is to provide a more **economical solution for HA deployments at the edge**. Customers at edge locations often require redundancy but need a lower-cost option. This configuration allows organizations to deploy OpenShift with **only two regular-sized control plane nodes**. This helps maintain HA while keeping compute costs down.


## Limitations and Considerations

- **Technology Preview**: The arbiter node configuration is a Technology Preview feature and **not supported with Red Hat production service level agreements (SLAs)**.
- **Bare Metal Only**: Initially, support for installing OpenShift with 2 control plane nodes is **limited to bare metal**. Cloud deployments are not supported for this configuration at this time due to scope and validation practicality.
- **Placement**: ADD RESTRICTIONS ABOUT NEEDING BMC AND TWO NETWORK CONNECTIONS
- **Workload Restrictions**: ADD COMMENTS ABOUT NODE CAPACITY AND WORKLOAD DISTRIBUTION ON NODE FAILURE.