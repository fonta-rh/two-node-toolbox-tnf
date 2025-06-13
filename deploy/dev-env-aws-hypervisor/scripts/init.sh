#!/bin/bash
source ./instance.env

instance_ip=$(cat ${SHARED_DIR}/ssh_user)@$(cat ${SHARED_DIR}/public_address)

ssh $instance_ip 'mkdir -p ~/.ssh'
scp $SSH_PRIVATE_KEY $instance_ip:~/.ssh/id_rsa
scp $SSH_PUBLIC_KEY $instance_ip:~/.ssh/id_rsa.pub

scp ./scripts/configure.sh $instance_ip:~/configure.sh

scp profile.env.template $instance_ip:profile.env

ssh $instance_ip 'sudo chmod +x ~/configure.sh'

ssh $instance_ip
