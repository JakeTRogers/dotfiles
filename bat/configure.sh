#!/usr/bin/env bash

set -e

test -d "${HOME}/.config" || mkdir -p "${HOME}/.config"
ln -snf "${DOTFILES_LOCATION}/bat/config" "${HOME}/.config/bat"

# Build bat theme cache so custom themes are available
if command -v bat &>/dev/null; then
  bat cache --build
fi
