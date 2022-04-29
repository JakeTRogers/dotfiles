#!/usr/bin/env zsh

set -e

# powerlevel10k theme
git clone -q --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k/gitstatus/install
# zsh syntax highlighting
git clone -q https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
# zsh autosuggestions
git clone -q https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

ln -sf "${DOTFILES_LOCATION}/omz/aliases.zsh" "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/aliases.zsh"
ln -sf "${DOTFILES_LOCATION}/omz/env.zsh" "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/env.zsh"
ln -sf "${DOTFILES_LOCATION}/omz/functions.zsh" "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/functions.zsh"
ln -sf "${DOTFILES_LOCATION}/omz/zshrc" "${HOME}/.zshrc"
ln -sf "${DOTFILES_LOCATION}/omz/p10k.zsh" "${HOME}/.p10k.zsh"
