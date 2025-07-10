# Clean Role

This role cleans up OpenShift deployments and resets the dev-scripts environment.

## Description

The clean role performs cleanup operations for OpenShift bare metal deployments managed by dev-scripts. It:

1. Stops the OpenShift cluster using the dev-scripts clean target
2. Resets the dev-scripts git checkout to the origin/master branch
3. Completely removes the `/opt/dev-scripts` directory and all its contents

## Requirements

- dev-scripts repository cloned and configured
- Make utility available
- Root/sudo privileges for directory removal

## Role Variables

### Default Variables (defaults/main.yml)

- `dev_scripts_path`: Path to the dev-scripts directory (default: "openshift-metal3/dev-scripts")
- `dev_scripts_branch`: Git branch to reset to (default: "master")

## Usage

This role is used by the cleanup playbook in the upper level directory:

```bash
ansible-playbook clean.yml
```

## Notes

- **Validation**: The role validates that `dev_scripts_path` is defined before proceeding 