# TNA Deployment Dev Guide

This guide outlines the steps and requirements for setting up a development environment and deploying a cluster using this repository, which relies on the [openshift-metal3/dev-scripts](https://github.com/openshift-metal3/dev-scripts) repository.

**High Level Diagram of Deployment**

![Diagram](./tna-diagram.png)

## 1. Machine Requirements

To use this guide, you will need a remote machine to run the cluster on and your local machine to execute the ansible script from.

### Client Machine Requirements:

This is the machine where you run the deployment scripts, all that's needed is ansible.

- Make sure you have the ansible-playbook command installed.
- If you're missing the containers.podman collection, you can install it via: ansible-galaxy collection install containers.podman

### Remote Machine Requirements:

This is the target host where the cluster will be deployed.

- Must be a CentOS 9 or RHEL 9 host.
  - Alma and Rocky Linux 8 are also supported on a best effort basis.
  - Requires a file system that supports `d_type`. (Click [here](https://github.com/openshift-metal3/dev-scripts?tab=readme-ov-file#determining-if-your-filesystem-supports-d_type) for more info on this).
  - Ideally, it should be on a bare metal host.
  - Should have at least 64GB of RAM.
  - Needs a user with passwordless sudo access to run as.
  - You need a valid pull secret (json string) obtained from https://cloud.redhat.com/openshift/install/pull-secret.

> Note: Log in to subscription manager where appropriate for some package installs.

#### (Optional) Pre-configured remote host in AWS
If you have an AWS account available, you can use the tools in [dev-env-aws-hypervisor](/deploy/dev-env-aws-hypervisor/README.md) to deploy a host that will be ready to run this installation. Ater finishing the process, running `make info` will provide the necessary instance information to edit `inventory.ini` (see below)

## 2. Deploying the Cluster

The deployment process involves updating configuration files and running an Ansible playbook.

### Step 1: Update Configurations

#### Inventory file
- Copy `inventory.ini.sample` to `inventory.ini`: Edit this file to include the user and IP address of your remote machine. The ansible_ssh_extra_args are optional, but useful to keep alive the process during long installation steps
- Example: `ec2-user@100.100.100.100 ansible_ssh_extra_args='-o ServerAliveInterval=30 -o ServerAliveCountMax=120'`.

#### Pull secret
- Create `pull-secret.json`: Create a file named pull-secret.json in the `roles/arbiter-dev/files/` directory and paste your pull secret JSON string into it.
- Update `config.sh`: Modify the `OPENSHIFT_INSTALL_RELEASE_IMAGE_OVERRIDE` and `OPENSHIFT_RELEASE_IMAGE` variables in this file with your desired image.
- Example: `OPENSHIFT_INSTALL_RELEASE_IMAGE_OVERRIDE=quay.io/openshift-release-dev/ocp-release:4.19.0-rc.5-multi-x86_64`.
<br /> 
  > Note: The config.sh file is passed to metal-scripts. A full list of acceptable values can be found by checking the linked config_example.sh file in the [openshift-metal3/dev-scripts/config_example.sh](https://github.com/openshift-metal3/dev-scripts/blob/master/config_example.sh) repository.

#### SSH access (optional)
- Public Key Access: For convenience, your local public key is added to the authorized keys on the remote host.

  - This guide assumes your public key is located at `~/.ssh/id_ed25519.pub`.
    If your public key path is different, you need to update this path in the file roles/config/tasks/main.yaml.



### Step 2: Run Deployment

- Execute the command ansible-playbook setup.yml -i inventory.ini to start the deployment process.
- This process will take a while, so be prepared for it to run for some time.
- Once the playbook is finished, a file named `proxy.env` will be created containing the proxy configs to connect to the cluster.
- Source the `proxy.env` file by running `source proxy.env`.
- After sourcing the file, you should be able to run oc get nodes to see the nodes running in your deployed cluster.

> Note: The proxy.env file assumes a relative path for the kubeconfig. You can move the kubeconfig file or change the path in proxy.env to an absolute path for convenience.

### Optional: Attaching Extra Disks

- If your deployment requires extra disks, make sure you have the disks on the remote host.
- Then, use the attach-disk command to connect them to the virtual machines (VMs).
  - Example: `sudo virsh attach-disk ostest_arbiter_0 /dev/nvme2n1 vdc`.

### Troubleshooting Connection Issues:

- If you lose the ability to reach your cluster, it's likely an issue with the proxy container on the remote host.
  - SSH into the remote host.
  - Validate that the external-squid pod is running `podman ps`.
  - If it's not running, restart it using the command `podman start external-squid`.

## 3. Cleaning Up

To shut down and clean up the deployed environment:

- Run the command `ansible-playbook clean.yml -i inventory.ini`.

After cleaning up, you can re-create the deployment using a different payload image if desired.
