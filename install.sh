#!/usr/bin/env bash

set -e

###
# Installation of packages, configurations, and dotfiles
###

# DOTFILES repo path
DOTFILES_LOCATION="$(pwd)"
export DOTFILES_LOCATION

# INSTALL_MODE == 'full' for Full mode on Workstations, else Minimal mode on
# Dev containers and Lab servers
export INSTALL_MODE="${1}"

# create elevate variable to use sudo if needed
if [ "$EUID" -eq 0 ]; then
  elevate=''
else
  elevate='sudo'
fi
export elevate

# getRelease and the Tools it installs live in ~/.local/bin, which may not be
# on PATH until zsh runs, so add it for this run's post-install checks
export PATH="${HOME}/.local/bin:${PATH}"

###
# Install dependencies
###
./bin/dotfiles curl
./bin/dotfiles less
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
  ./bin/dotfiles tmux
fi

echo "🟢 dotfiles setup complete"
