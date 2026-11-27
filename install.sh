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
./bin/dotfiles jq
./bin/dotfiles agents


if [ "${INSTALL_MODE}" = 'full' ]; then
  ./bin/dotfiles neovim
  ./bin/dotfiles tmux
fi

###
# Record what this run applied. omz/checkout_reminder.zsh compares it with the
# Checkout at shell start, and names the command to run again.
###
if commit="$(git -C "${DOTFILES_LOCATION}" rev-parse HEAD 2> /dev/null)"; then
  if [ "${INSTALL_MODE}" = 'full' ]; then
    recorded_mode='full'
  else
    recorded_mode='minimal'
  fi
  state_dir="${XDG_STATE_HOME:-${HOME}/.local/state}/dotfiles"
  mkdir -p "${state_dir}"
  printf 'commit=%s\nmode=%s\n' "${commit}" "${recorded_mode}" > "${state_dir}/installed"
fi

echo "🟢 dotfiles setup complete"
