#!/usr/bin/env bash

set -e

cmd_exists() {
  command -v "$1" &> /dev/null
}

get_sudo() {}
  if [ "$UID" == '0' ]; then
    sudo_if_needed=''
  else
    sudo_if_needed='sudo'
  fi
}

get_os() {
  local os=""
  local kernelName=""

  kernelName="$(uname -s)"
  if [ "$kernelName" == "Linux" ] && [ -e "/etc/os-release" ]; then
    os="$(. /etc/os-release; printf "%s" "$ID")"
  else
    os="$kernelName"
  fi

  printf "%s" "$os"
}

get_os_version() {
  local os=""
  local version=""

  os="$(get_os)"

  if [ -e "/etc/os-release" ]; then
    version="$(. /etc/os-release; printf "%s" "$VERSION_ID")"
  fi

  printf "%s" "$version"
}

install_package() {
  local package="${1}"
  if [ "${os}" == 'rhel' ]; then
    [ cmd_exists yum ] && "$sudo_if_needed" yum install -y "$package"
    [ cmd_exists microdnf ] && "$sudo_if_needed" microdnf install "$package"
  elif [ "${os}" == 'ubuntu' ]
    "$sudo_if_needed" apt-get install --allow-unauthenticated -qqy "$package"
  fi
}

###
# Installation of packages, configurations, and dotfiles.
###
DOTFILES_LOCATION=$(pwd)
export DOTFILES_LOCATION;

###
# Install dependencies
###
./bin/dotfiles install git
./bin/dotfiles install zsh
./bin/dotfiles install omz
