#!/usr/bin/env zsh

set -e

# powerlevel10k theme
if [ -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k" ]; then
  echo "Updating powerlevel10k theme"
  git -C "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k" pull --quiet
else
  echo "Installing powerlevel10k theme"
  git clone --quiet --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
  ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k/gitstatus/install
fi

# zsh syntax highlighting
if [ -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting" ]; then
  echo "Updating zsh syntax highlighting"
  git -C "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting" pull --quiet
else
  echo "Installing zsh syntax highlighting"
  git clone --quiet https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
fi

# zsh autosuggestions
if [ -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions" ]; then
  echo "Updating zsh autosuggestions"
  git -C "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions" pull --quiet
else
  echo "Installing zsh autosuggestions"
  git clone --quiet https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
fi

ln -sf "${DOTFILES_LOCATION}/omz/aliases.zsh" "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/aliases.zsh"
ln -sf "${DOTFILES_LOCATION}/omz/env.zsh" "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/env.zsh"
ln -sf "${DOTFILES_LOCATION}/omz/functions.zsh" "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/functions.zsh"
ln -sf "${DOTFILES_LOCATION}/omz/zshrc" "${HOME}/.zshrc"
ln -sf "${DOTFILES_LOCATION}/omz/p10k.zsh" "${HOME}/.p10k.zsh"
