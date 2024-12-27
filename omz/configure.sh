#!/usr/bin/env zsh

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
ln -sf --no-dereference "${DOTFILES_LOCATION}/omz/functions" "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/functions"
ln -sf "${DOTFILES_LOCATION}/omz/functions.zsh" "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/functions.zsh"
ln -sf "${DOTFILES_LOCATION}/omz/variables.zsh" "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/variables.zsh"
ln -sf "${DOTFILES_LOCATION}/omz/zshrc" "${HOME}/.zshrc"
ln -sf "${DOTFILES_LOCATION}/omz/p10k.zsh" "${HOME}/.p10k.zsh"

# remove any dead symlinks from the custom completions directory or create it if it doesn't exist
if [ -e "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/completions" ]; then
  find "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/completions" -type l ! -exec test -e {} \; -delete
else
  mkdir "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/completions"
fi

# loop over all completions and symlink them
for completion in "${DOTFILES_LOCATION}/omz/completions"/*; do
  ln -sf "${completion}" "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/completions/$(basename ${completion})"
done
