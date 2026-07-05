#!/usr/bin/env zsh

set -e

if [ -d "${HOME}/.oh-my-zsh" ]; then
  echo "🟢 oh-my-zsh is already installed"
else
  # capture the installer first so a failed download is fatal instead of silently running `sh -c ""`
  installer="$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" || {
    echo "🔴 failed to download oh-my-zsh installer"
    exit 1
  }
  sh -c "${installer}" "" --unattended > /dev/null
fi
