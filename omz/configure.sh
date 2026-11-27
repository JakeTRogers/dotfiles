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

# patched gitstatusd: powerlevel10k's own gitstatusd cannot read repos with
# relative worktrees. zshrc points powerlevel10k at this copy when its
# version matches the gitstatus powerlevel10k bundles. See omz/gitstatusd/README.md.
source "${DOTFILES_LOCATION}/omz/gitstatusd/gitstatusd.env"
# empty when powerlevel10k has no build.info, which the version check below reports
p10k_gitstatus_version="$( (. "${zsh_custom}/themes/powerlevel10k/gitstatus/build.info" && print -r -- "${gitstatus_version:-}") 2> /dev/null || true)"
gitstatusd_version="${${release_tag#gitstatusd-}%-*}"
gitstatusd_path="${HOME}/.local/share/gitstatusd/${gitstatusd_version}/gitstatusd"
if [[ -z "${release_tag}" ]]; then
  echo "⚠️ no patched gitstatusd release is pinned, so the prompt uses powerlevel10k's own gitstatusd"
elif [[ "$(uname -m)" != x86_64 ]]; then
  echo "⚠️ patched gitstatusd is built for x86_64 only, so the prompt uses powerlevel10k's own gitstatusd"
elif [[ "${gitstatusd_version}" != "${p10k_gitstatus_version}" ]]; then
  echo "⚠️ patched gitstatusd ${release_tag} does not match powerlevel10k's gitstatus ${p10k_gitstatus_version:-(unknown)}, so the prompt uses powerlevel10k's own gitstatusd"
elif [[ -x "${gitstatusd_path}" ]] && echo "${release_sha256}  ${gitstatusd_path}" | sha256sum --check --status 2> /dev/null; then
  echo "🟢 patched gitstatusd ${release_tag} is already installed"
else
  echo "Installing patched gitstatusd ${release_tag}"
  gitstatusd_download="$(mktemp)"
  if curl -fsSL -o "${gitstatusd_download}" \
      "https://github.com/${release_repo}/releases/download/${release_tag}/gitstatusd-linux-x86_64" &&
    echo "${release_sha256}  ${gitstatusd_download}" | sha256sum --check --status 2> /dev/null; then
    mkdir -p "${gitstatusd_path:h}"
    install -m 755 "${gitstatusd_download}" "${gitstatusd_path}"
  else
    echo "⚠️ patched gitstatusd ${release_tag} failed to download or verify, so the prompt uses powerlevel10k's own gitstatusd"
  fi
  rm -f "${gitstatusd_download}"
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
