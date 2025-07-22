#!/bin/bash
source ./scripts/init.sh

msg_info "Stack: $(cat ${SHARED_DIR}/rhel_host_stack_name)"
msg_info "Host: $(cat ${SHARED_DIR}/public_address)"
msg_info "User: $(cat ${SHARED_DIR}/ssh_user)"
msg_info "Cockpit URL: http://$(cat ${SHARED_DIR}/public_address):9090"
