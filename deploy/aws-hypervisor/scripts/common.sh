#!/bin/bash
SCRIPT_DIR=$(dirname "$0")
source "${SCRIPT_DIR}/../instance.env"

# Set defaults
export STACK_NAME="${STACK_NAME:-${USER}-dev}"
export SHARED_DIR="${SHARED_DIR:-instance-data}"
export RHEL_HOST_ARCHITECTURE="${RHEL_HOST_ARCHITECTURE:-x86_64}"
export EC2_INSTANCE_TYPE="${EC2_INSTANCE_TYPE:-c5n.metal}"
export RHEL_VERSION="${RHEL_VERSION:-9.6}"

readonly COLOR_RED='\033[0;31m'
readonly COLOR_YELLOW='\033[0;33m'
readonly COLOR_BLUE='\033[0;34m'
readonly COLOR_CLEAR='\033[0m'

function msg_err() {
  echo -e "${COLOR_RED}ERROR: ${1}${COLOR_CLEAR}" >&2
}

function msg_warning() {
  echo -e "${COLOR_YELLOW}WARNING: ${1}${COLOR_CLEAR}" >&2
}

function msg_info() {
  echo -e "${COLOR_BLUE}INFO: ${1}${COLOR_CLEAR}" >&2
}

function aws_ec2_describe_images() {
  aws ec2 describe-images \
  --query 'reverse(sort_by(Images, &CreationDate))[].[Name, ImageId, CreationDate]' \
  --filters "Name=name,Values=RHEL-${RHEL_VERSION}.*GA*${RHEL_HOST_ARCHITECTURE}*" \
  --region "${REGION}" \
  --owners amazon \
  --output json \
  --no-cli-pager
}

function get_rhel_ami() {
  local rhel_host_ami_object
  local ec2_instances
  ec2_instances="$(aws_ec2_describe_images)"
  if [ $? -ne 0 ]
  then
    msg_err " getting AMI from aws cli: $ec2_instances" >&2
    echo ""
  fi
  rhel_host_ami_object=$( echo "$ec2_instances" | jq -re 'map({ name: .[0], id: .[1], creationDate: .[2]}) | .[0]')
  if [ $? -eq 0 ]
  then
        ami_name="$(echo $rhel_host_ami_object | jq '.name')"
        ami_id="$(echo $rhel_host_ami_object | jq '.id')"
        msg_info "Found AMI: $ami_name" >&2
        msg_info "Found AMI ID: $ami_id" >&2
        echo "${ami_id}"
  else
        msg_err "error getting AMI's $rhel_host_ami_object" >&2
        echo ""
  fi
}