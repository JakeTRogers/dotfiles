#!/usr/bin/env bash

set -e

# symlink the fzf config file
ln -sf "${DOTFILES_LOCATION}/fzf/fzf.zsh" "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/fzf.zsh"

# symlink fzf git integration
ln -sf "${DOTFILES_LOCATION}/fzf/fzf-git.sh" "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/fzf-git.sh"
