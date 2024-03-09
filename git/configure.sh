#!/usr/bin/env bash

set -e

# devcontainers will automatically link ~/.gitconfig
if [ "${INSTALL_MODE}" = 'full' ]; then
    test -f "${HOME}/.gitconfig" || ln -sf "${DOTFILES_LOCATION}/git/gitconfig" "${HOME}/.gitconfig"
fi
ln -sf "${DOTFILES_LOCATION}/git/gitignore_global" "${HOME}/.gitignore_global"

# make sure the git template directory exists and is linked to the correct location
test -d "${HOME}/.git-template" || mkdir "${HOME}/.git-template"
ln -sfnT "${DOTFILES_LOCATION}/git/git-template/hooks" "${HOME}/.git-template/hooks"
