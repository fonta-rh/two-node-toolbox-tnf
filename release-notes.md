# Two-Node Toolbox Release Notes

## Version 0.5 - Instance and Cluster Lifecycle Management
*Release Date: July 2025*

### New Features

#### Instance and Cluster Lifecycle Management
- Added EC2 instance start/stop capabilities with OpenShift cluster detection
- Instance operations detect running OpenShift clusters and provide management options
- Interactive prompts guide users through cluster shutdown/startup procedures

#### Cluster Deployment Options
- New `make redeploy-cluster` command with deployment strategy detection
- Automatic detection of cluster topology changes (Arbiter ↔ Fencing) with cleanup strategies
- Deployment paths optimized based on cluster state and configuration changes

#### Cluster Cleanup Management
- Simplified cluster cleanup with `make clean` and `make full-clean` commands
- Standardized cleanup interface replacing direct ansible playbook commands
- Documentation updated to recommend make targets over manual ansible commands

### New Commands

- **Breaking Change**: All make commands now run from `deploy/` directory instead of `deploy/aws-hypervisor/`


#### Instance Management
- `make create` - Create new EC2 instance (renamed from `deploy`)
- `make start` - Start stopped EC2 instance with cluster detection
- `make stop` - Interactive stop with cluster management options  
- `make redeploy-cluster` - Cluster redeployment with mode selection
- `make shutdown-cluster` - Graceful OpenShift cluster VM shutdown
- `make startup-cluster` - Restore OpenShift cluster VMs and proxy services

#### Cluster Cleanup Management
- `make clean` - Standard cluster cleanup preserving cached data for faster redeployment
- `make full-clean` - Complete cluster cleanup including all cached data for thorough reset

#### Workflow Scripts
- Stop script detects running clusters and offers shutdown, cleanup, or redeploy options, with separate force-stop command
- Cluster state tracking maintains configuration state for recovery
- Automatic proxy container lifecycle management during cluster operations

### Technical Changes

- Cluster VM state tracking for startup/shutdown cycles
- Updated .gitignore for inventory backups and config files
- Reorganized Makefile with comprehensive command structure and help system
- Deployment selection between fast redeploy, clean deployment, and complete rebuild
- Enhanced Ansible playbook integration for redeploy workflows

### Documentation Restructuring

- Split README documentation: makefile commands documented in `deploy/README.md`
- AWS hypervisor scripts documented separately in `deploy/aws-hypervisor/README.md`

### Migration Notes

**For existing users**: Change your working directory from `deploy/aws-hypervisor/` to `deploy/` when running make commands:

```bash
# Old workflow
cd deploy/aws-hypervisor
make deploy

# New workflow  
cd deploy
make deploy
```

---

## Version 0.4 - Integrated Redfish Configuration  
*Release Date: July 10, 2025*

### Features

#### Redfish Stonith Setup
- Redfish fencing configuration for Two-Node with Fencing (TNF) clusters on OpenShift 4.19+
- Integrated and standalone Redfish configuration workflows
- Bare metal host management with Redfish-compatible BMC support

### Documentation Updates

- Configuration examples with separation between arbiter and fencing examples
- Redfish role documentation for configuration and troubleshooting
- Redfish configuration can run as part of main deployment or standalone

### Technical Changes

- Added `redfish.yml` playbook for standalone Redfish configuration
- New Redfish role with BMH (BareMetalHost) processing
- Integration with TNF installation workflow for stonith setup
- Enhanced role documentation

---

## Version 0.3 - TNF Deployment Integration
*Release Date: June 19, 2025*

### Features

#### Two-Node with Fencing (TNF) Support
- Added support for Two-Node with Fencing cluster topology
- Single toolbox supports both TNA (Two-Node Arbiter) and TNF deployments
- Interactive mode selection between arbiter and fencing topologies

### Project Restructuring

- Moved from `tna-ipi-baremetalds-virt` to unified `openshift-clusters` directory
- Separate config files for arbiter (`config_arbiter.sh`) and fencing (`config_fencing.sh`) deployments
- Reorganized roles for clarity and maintainability

### Documentation

- TNF documentation explaining Two-Node with Fencing concepts, Pacemaker integration, and use cases
- Updated Two-Node with Arbiter documentation  
- Added visual topology diagrams for both TNA and TNF configurations
- Consolidated deployment guide supporting both topologies

### Technical Changes

- Deployment script prompts for cluster type (arbiter/fencing)
- Enhanced config file validation and examples
- Role restructuring with `install-dev` replacing `arbiter-dev`

---

## Version 0.2 - AWS Development Hypervisor
*Release Date: June 5, 2025*

### Features

#### AWS EC2 Development Environment
- Toolchain for creating development hypervisors in AWS EC2
- CloudFormation integration for infrastructure provisioning with security groups and networking
- TNA deployment tools integration with AWS-provisioned hypervisors

### Infrastructure Tools

#### AWS Management Scripts
- `create.sh` - Deploy new EC2 instance using CloudFormation
- `init.sh` - Initialize and configure deployed instance  
- `destroy.sh` - Clean teardown of AWS resources
- `ssh.sh` - Direct SSH access to instances
- `configure.sh` - Post-deployment hypervisor setup

#### Configuration Management
- `instance.env.template` for AWS configuration
- Dynamic inventory management for Ansible
- SSH key management and security group setup

### Development Workflow

- `make deploy` (run from `deploy/` directory) creates, initializes, and configures development environment
- AWS hypervisor integration with cluster deployment tools
- Instance start/stop for development cost control

### Documentation

- Instructions for AWS account setup, CLI configuration, and deployment
- Instructions for using AWS hypervisor with cluster deployment tools
- Common issues and solutions for AWS-based development

---

## Version 0.1 - Two-Node Arbiter (TNA) Deployment  
*Release Date: May 16, 2025*

### Initial Release

#### Core TNA Deployment
- Deployment automation for OpenShift clusters with arbiter topology
- Integration with openshift-metal3/dev-scripts
- Optimized for bare metal development and testing environments

### Deployment Infrastructure

#### Ansible-Based Automation
- Modular roles for configuration, deployment, and cleanup
- Automated SSH setup, git configuration, and development tools
- Proxy container setup for external cluster access

#### Development Tools
- `ansible-playbook setup.yml` with configuration validation
- Start, stop, and cleanup operations for development clusters
- CLI setup with aliases and environment configuration

### Documentation

- Instructions for Two-Node Arbiter cluster deployment
- System requirements and setup instructions  
- Sample configs for OpenShift release images and development settings
- Basic connectivity and deployment issue resolution

### Architecture

- Separation between configuration, deployment, and management roles
- Template-based config files with environment-specific customization
- Optimized for rapid development, testing, and iteration workflows

---

## Project Overview

The Two-Node Toolbox provides tooling for deploying and managing two-node OpenShift clusters in development environments. It supports both Two-Node Arbiter (TNA) and Two-Node with Fencing (TNF) topologies for High Availability solutions in edge computing and development scenarios.

### Supported Topologies

- **Two-Node with Arbiter (TNA)**: 2 full control planes + 1 arbiter node
- **Two-Node with Fencing (TNF)**: 2 control planes + software-based fencing via Pacemaker/Corosync

### Use Cases

- Edge computing deployments requiring HA
- Development and testing environments  
- CI/CD integration for cluster lifecycle testing
- Prototyping and validation workflows

**Note**: Two-node configurations are Technology Preview features and not covered under Red Hat production SLAs. Primarily targets OpenShift 4.19+ deployments on bare metal infrastructure.

---