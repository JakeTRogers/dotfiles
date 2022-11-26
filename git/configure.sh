#!/usr/bin/env bash

set -e

# devcontainers will automatically link ~/.gitconfig
if [ "${INSTALL_MODE}" = 'full' ]; then
    test -f "${HOME}/.gitconfig" || ln -sf "${DOTFILES_LOCATION}/git/gitconfig" "${HOME}/.gitconfig"
fi
ln -sf "${DOTFILES_LOCATION}/git/gitignore_global" "${HOME}/.gitignore_global"
