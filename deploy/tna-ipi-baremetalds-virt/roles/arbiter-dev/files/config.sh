#!/bin/bash

export IP_STACK="v4"
export NUM_WORKERS=0
export ENABLE_ARBITER="true"
export ARBITER_MEMORY=16384
export MASTER_MEMORY=32768
export MASTER_DISK=100
export NUM_MASTERS=2
export FEATURE_SET="TechPreviewNoUpgrade"

# This is currently being used to avoid needing ci_token
export OPENSHIFT_CI="true"

export OPENSHIFT_INSTALL_RELEASE_IMAGE_OVERRIDE=quay.io/openshift-release-dev/ocp-release:4.19.0-ec.5-x86_64
export OPENSHIFT_RELEASE_IMAGE=quay.io/openshift-release-dev/ocp-release:4.19.0-ec.5-x86_64
