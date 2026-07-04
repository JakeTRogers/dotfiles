#!/usr/bin/env zsh

set -eu
: "${DOTFILES_LOCATION:?DOTFILES_LOCATION must be set to the dotfiles repo path}"

zsh_custom="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

# powerlevel10k theme
if [ -d "${zsh_custom}/themes/powerlevel10k" ]; then
  echo "Updating powerlevel10k theme"
  git -C "${zsh_custom}/themes/powerlevel10k" pull --quiet || echo "⚠️ powerlevel10k update failed, continuing"
else
  echo "Installing powerlevel10k theme"
  git clone --quiet --depth=1 https://github.com/romkatv/powerlevel10k.git "${zsh_custom}/themes/powerlevel10k"
  "${zsh_custom}/themes/powerlevel10k/gitstatus/install"
fi

# zsh syntax highlighting
if [ -d "${zsh_custom}/plugins/zsh-syntax-highlighting" ]; then
  echo "Updating zsh syntax highlighting"
  git -C "${zsh_custom}/plugins/zsh-syntax-highlighting" pull --quiet || echo "⚠️ zsh-syntax-highlighting update failed, continuing"
else
  echo "Installing zsh syntax highlighting"
  git clone --quiet https://github.com/zsh-users/zsh-syntax-highlighting.git "${zsh_custom}/plugins/zsh-syntax-highlighting"
fi

# zsh autosuggestions
if [ -d "${zsh_custom}/plugins/zsh-autosuggestions" ]; then
  echo "Updating zsh autosuggestions"
  git -C "${zsh_custom}/plugins/zsh-autosuggestions" pull --quiet || echo "⚠️ zsh-autosuggestions update failed, continuing"
else
  echo "Installing zsh autosuggestions"
  git clone --quiet https://github.com/zsh-users/zsh-autosuggestions "${zsh_custom}/plugins/zsh-autosuggestions"
fi

# fzf-tab
if [ -d "${zsh_custom}/plugins/fzf-tab" ]; then
  echo "Updating fzf-tab"
  git -C "${zsh_custom}/plugins/fzf-tab" pull --quiet || echo "⚠️ fzf-tab update failed, continuing"
else
  echo "Installing fzf-tab"
  git clone --quiet https://github.com/Aloxaf/fzf-tab "${zsh_custom}/plugins/fzf-tab"
fi

ln -sf "${DOTFILES_LOCATION}/omz/aliases.zsh" "${zsh_custom}/aliases.zsh"
ln -sf --no-dereference "${DOTFILES_LOCATION}/omz/functions" "${zsh_custom}/functions"
ln -sf "${DOTFILES_LOCATION}/omz/variables.zsh" "${zsh_custom}/variables.zsh"
ln -sf "${DOTFILES_LOCATION}/omz/zshrc" "${HOME}/.zshrc"
ln -sf "${DOTFILES_LOCATION}/omz/p10k.zsh" "${HOME}/.p10k.zsh"

# remove any dead symlinks from the zsh custom directory
if [ -e "${zsh_custom}" ]; then
  find "${zsh_custom}" -maxdepth 1 -type l ! -exec test -e {} \; -delete
fi

# remove any dead symlinks from the custom completions directory or create it if it doesn't exist
if [ -e "${zsh_custom}/completions" ]; then
  find "${zsh_custom}/completions" -maxdepth 1 -type l ! -exec test -e {} \; -delete
else
  mkdir -p "${zsh_custom}/completions"
fi

# loop over all completions and symlink them
for completion in "${DOTFILES_LOCATION}/omz/completions"/*; do
  ln -sf "${completion}" "${zsh_custom}/completions/$(basename "${completion}")"
done

### SETUP CUSTOM SCRIPTS ###
# remove any dead symlinks from the custom scripts directory or create it if it doesn't exist
if [ -e "${HOME}/bin" ]; then
  find "${HOME}/bin" -maxdepth 1 -type l ! -exec test -e {} \; -delete
else
  mkdir -p "${HOME}/bin"
fi

# loop over all custom scripts and symlink them
for custom_script in "${DOTFILES_LOCATION}/omz/scripts"/*; do
  ln -sf "${custom_script}" "${HOME}/bin/$(basename "${custom_script}")"
done
