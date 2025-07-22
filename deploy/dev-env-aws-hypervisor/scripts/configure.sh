#!/bin/bash

function get_ocp_version() {
    local latest_ga_ocp_version
    latest_ga_ocp_version="$(curl -sL https://sippy.dptools.openshift.org/api/releases | jq -re '.ga_dates | to_entries | max_by(.value) | .key')"
    if [ $? -eq 0 ]
    then
        echo "${latest_ga_ocp_version:-4.19}"
    else
        echo "4.19"
    fi
}

user=${1:-pitadmin}
if id "$user" >/dev/null 2>&1; then
    echo "user $user found"
else
    echo "user $user not found, creating"
    sudo useradd -m $user
    sudo passwd $user
    echo -e "${user}\tALL=(ALL)\tNOPASSWD: ALL" | sudo tee "/etc/sudoers.d/${user}"
fi

sudo rm -rf /etc/yum.repos.d/*
sudo subscription-manager config --rhsm.manage_repos=1 --rhsmcertd.disable=redhat-access-insights
sudo subscription-manager register
sudo subscription-manager attach --pool=8a85f99c7d76f2fd017d96c411c70667
sudo subscription-manager repos \
--enable "rhel-9-for-$(uname -m)-appstream-rpms" \
--enable "rhel-9-for-$(uname -m)-baseos-rpms" \
--enable "rhocp-$(get_ocp_version)-for-rhel-9-$(uname -m)-rpms"
