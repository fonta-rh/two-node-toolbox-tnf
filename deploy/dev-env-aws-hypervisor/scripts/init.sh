#!/bin/bash
source ./instance.env

instance_ip=$(cat ${SHARED_DIR}/ssh_user)@$(cat ${SHARED_DIR}/public_address)

ssh $instance_ip 'mkdir -p ~/.ssh'
scp $SSH_PRIVATE_KEY $instance_ip:~/.ssh/id_rsa
scp $SSH_PUBLIC_KEY $instance_ip:~/.ssh/id_rsa.pub

scp ./scripts/configure.sh $instance_ip:~/configure.sh

if [ -n "$CONFIG_MODULES" ]; then
  for module in "$CONFIG_MODULES"; do
    ssh $instance_ip 'mkdir -p modules/config/$module'
    rsync -r -e ssh ./modules/config/$module/ $instance_ip:modules/config/$module
  done
fi
scp profile.env.template $instance_ip:profile.env

ssh $instance_ip 'sudo chmod +x ~/configure.sh'

if [ -z "$SCRIPT_MODULES" ]; then
  exit 0
fi

for module in "$SCRIPT_MODULES"; do
  scp -r ./modules/script/$module/* $instance_ip:
done

ssh $instance_ip
