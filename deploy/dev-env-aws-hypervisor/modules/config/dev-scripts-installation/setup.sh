#!/bin/bash
sudo dnf upgrade -y
sudo dnf install containernetworking-plugins runc git make wget jq golang -y
rm -rf dev-scripts || true;
git clone ${DEV_SCRIPTS_REPO} --single-branch -b ${DEV_SCRIPTS_BRANCH}
cp dev-scripts/config_example.sh dev-scripts/config_${USER}.sh
sed -i "s/export CI_TOKEN=''/#export CI_TOKEN=''/g" dev-scripts/config_${USER}.sh
