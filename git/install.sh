#!/usr/bin/env bash

set -e

ln -sf "${DOTFILES_LOCATION}/git/.gitconfig" "${HOME}/.gitconfig"
ln -sf "${DOTFILES_LOCATION}/git/.gitignore_global" "${HOME}/.gitignore_global"
