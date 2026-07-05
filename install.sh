#!/usr/bin/env bash

set -e

###
# Installation of packages, configurations, and dotfiles
###

# DOTFILES repo path
DOTFILES_LOCATION="$(pwd)"
export DOTFILES_LOCATION

# INSTALL_MODE == 'full' for workstation, else minimal for devcontainers
export INSTALL_MODE="${1}"

# create elevate variable to use sudo if needed
if [ "$EUID" -eq 0 ]; then
  elevate=''
else
  elevate='sudo'
fi
export elevate

###
# Install dependencies
###
./bin/dotfiles curl
./bin/dotfiles less
./bin/dotfiles tmux
./bin/dotfiles git
./bin/dotfiles gpg
./bin/dotfiles vim
./bin/dotfiles zsh
./bin/dotfiles omz
./bin/dotfiles getRelease
./bin/dotfiles bat
./bin/dotfiles fd
./bin/dotfiles fzf
./bin/dotfiles ripgrep


if [ "${INSTALL_MODE}" = 'full' ]; then
  ./bin/dotfiles neovim
fi

echo "🟢 dotfiles setup complete"
