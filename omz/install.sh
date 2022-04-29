#!/usr/bin/env zsh

set -e

if [ -d "${HOME}/.oh-my-zsh" ]; then
  printf "oh-my-zsh is already installed\n"
else
  sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

ln -sf "${DOTFILES_LOCATION}/omz/aliases.zsh" "${HOME}/.oh-my-zsh/custom/aliases.zsh"
ln -sf "${DOTFILES_LOCATION}/omz/exports.zsh" "${HOME}/.oh-my-zsh/custom/exports.zsh"
ln -sf "${DOTFILES_LOCATION}/omz/functions.zsh" "${HOME}/.oh-my-zsh/custom/functions.zsh"

# powerlevel10k theme
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
# zsh syntax highlighting
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
# zsh autosuggestions
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

ln -sf "${DOTFILES_LOCATION}/omz/.zshrc" "${HOME}/.zshrc"
ln -sf "${DOTFILES_LOCATION}/omz/.p10k.zsh" "${HOME}/.p10k.zsh"