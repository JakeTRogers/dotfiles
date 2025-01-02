#!/usr/bin/env bash

set -e

test -d "${HOME}/.config/nvim" || mkdir "${HOME}/.config/nvim"

# symlink neovim config
ln -sf "${DOTFILES_LOCATION}/neovim/lazy-nvim/init.lua" "${HOME}/.config/nvim/init.lua"
ln -snf "${DOTFILES_LOCATION}/neovim/lazy-nvim/lua" "${HOME}/.config/nvim/lua"
ln -snf "${DOTFILES_LOCATION}/neovim/lazy-nvim/spell" "${HOME}/.config/nvim/spell"
