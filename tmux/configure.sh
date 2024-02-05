#!/usr/bin/env bash

set -e

if [ "${INSTALL_MODE}" = 'full' ]; then
  ln -sf "${DOTFILES_LOCATION}/tmux/tmux.conf" "${HOME}/.tmux.conf"

  # install tmux plugin manager
  if [ -d "${HOME}/.tmux/plugins" ]; then
    echo "Updating tmux plugin manager"
    git -C "${HOME}/.tmux/plugins/tpm" pull --quiet
  else
    echo "Installing tmux plugin manager"
    mkdir -p "${HOME}/.tmux/plugins"
    git clone --quiet https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
  fi

  # install tmux plugins
  ~/.tmux/plugins/tpm/bin/install_plugins
fi
