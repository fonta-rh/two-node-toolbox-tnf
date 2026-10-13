#!/bin/bash
# shellcheck source=/dev/null
source ~/profile.env

RHEL_MAJOR_VERSION=$(. /etc/os-release && echo "${VERSION_ID%%.*}")

sudo hostnamectl set-hostname "aws-${STACK_NAME}"

function get_ocp_version() {
    local latest_ga_ocp_version
    local default_version="${DEFAULT_OCP_VERSION:-}"
    if [[ -z "${default_version}" ]]; then
        case "${RHEL_MAJOR_VERSION}" in
            10) default_version="4.23" ;;
            *)  default_version="4.22" ;;
        esac
    fi
    if latest_ga_ocp_version="$(curl -sL https://sippy.dptools.openshift.org/api/releases | jq -re '.ga_dates | to_entries | max_by(.value) | .key')";
    then
        echo "${latest_ga_ocp_version:-$default_version}"
    else
        echo "$default_version"
    fi
}

user=${1:-pitadmin}
if id "$user" >/dev/null 2>&1; then
    echo "user $user found"
else
    echo "user $user not found, creating"
    sudo useradd -m "$user"
    # Generate a random secure password
    random_password=$(openssl rand -base64 12)
    echo "${random_password}" | sudo passwd --stdin "$user"
    echo "========================================"
    echo "User: $user"
    echo "Password: $random_password"
    echo "========================================"
    echo -e "${user}\tALL=(ALL)\tNOPASSWD: ALL" | sudo tee "/etc/sudoers.d/${user}"
fi

restore_repos_and_exit() {
    echo "ERROR: $1."
    if sudo test -d /etc/yum.repos.d.bak; then
        echo "Restoring pre-existing repo files."
        sudo rm -rf /etc/yum.repos.d
        sudo mv /etc/yum.repos.d.bak /etc/yum.repos.d
    else
        echo "No backup present (registration was already in place); leaving /etc/yum.repos.d untouched."
    fi
    exit 1
}

if sudo subscription-manager identity >/dev/null 2>&1; then
    echo "System already registered, skipping registration and repo wipe."
else
    sudo rm -rf /etc/yum.repos.d.bak
    if ! sudo cp -a /etc/yum.repos.d /etc/yum.repos.d.bak; then
        echo "ERROR: Failed to back up /etc/yum.repos.d. Aborting before wipe."
        exit 1
    fi
    sudo rm -rf /etc/yum.repos.d/*
    sudo subscription-manager config --rhsm.manage_repos=1 --rhsmcertd.disable=redhat-access-insights

    # Use activation key for non-interactive registration if available
    if [ -n "${RHSM_ACTIVATION_KEY}" ] && [ -n "${RHSM_ORG}" ]; then
        echo "Using activation key for RHSM registration"
        sudo subscription-manager register --activationkey="${RHSM_ACTIVATION_KEY}" --org="${RHSM_ORG}" \
            || restore_repos_and_exit "subscription-manager register failed"
    else
        echo "No activation key found, falling back to interactive registration"
        sudo subscription-manager register \
            || restore_repos_and_exit "subscription-manager register failed"
    fi
fi

sudo subscription-manager attach --pool=8a85f99c7d76f2fd017d96c411c70667 \
    || restore_repos_and_exit "subscription-manager attach failed"

sudo subscription-manager repos \
--enable "rhel-${RHEL_MAJOR_VERSION}-for-$(uname -m)-appstream-rpms" \
--enable "rhel-${RHEL_MAJOR_VERSION}-for-$(uname -m)-baseos-rpms" \
--enable "rhocp-$(get_ocp_version)-for-rhel-${RHEL_MAJOR_VERSION}-$(uname -m)-rpms" \
    || restore_repos_and_exit "subscription-manager repos --enable failed"

sudo rm -rf /etc/yum.repos.d.bak

# Enable CodeReady Builder (CRB) repo for -devel packages (e.g. libvirt-devel).
# On RHUI instances (like AWS), subscription-manager repos --enable can't touch
# CRB at all (registered or not) because it's managed by the static RHUI repo
# file, not RHSM entitlements. dnf config-manager edits that file directly,
# which is what 'crb enable' itself wraps on non-RHUI hosts.
enable_crb_repo() {
    if command -v crb &>/dev/null; then
        sudo crb enable
    else
        sudo dnf config-manager --set-enabled "codeready-builder-for-rhel-${RHEL_MAJOR_VERSION}-rhui-rpms"
    fi
}

echo "Enabling CRB repository..."
if ! enable_crb_repo; then
    echo "ERROR: Failed to enable CRB repository. libvirt-devel will be unavailable."
    exit 1
fi
