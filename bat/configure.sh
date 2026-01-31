#!/usr/bin/env bash

set -e

ln -snf "${DOTFILES_LOCATION}/bat/config" "${HOME}/.config/bat"
ln -sf "$DOTFILES_LOCATION/bat/config/themes" ~/.config/bat/themes

# Build bat theme cache so custom themes are available
if command -v bat &>/dev/null; then
	bat cache --build
fi
