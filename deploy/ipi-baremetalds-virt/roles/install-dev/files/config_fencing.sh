#!/bin/bash

export IP_STACK="v4"
export NUM_WORKERS=0
export MASTER_MEMORY=32768
export MASTER_DISK=100
export NUM_MASTERS=2
export FEATURE_SET="DevPreviewNoUpgrade"

# This is currently being used to avoid the need for ci_token
export OPENSHIFT_CI="true"

# If you need to use an image from OpenShift CI that requires authentication, 
# OPENSHIFT_CI should be set to "false" or removed, and CI_TOKEN below used instead
#export CI_TOKEN=sha256~CI_TOKEN_HERE
 

export OPENSHIFT_INSTALL_RELEASE_IMAGE_OVERRIDE=quay.io/openshift-release-dev/ocp-release@sha256:3482dbdce3a6fb2239684d217bba6fc87453eff3bdb72f5237be4beb22a2160b
export OPENSHIFT_RELEASE_IMAGE=quay.io/openshift-release-dev/ocp-release@sha256:3482dbdce3a6fb2239684d217bba6fc87453eff3bdb72f5237be4beb22a2160b