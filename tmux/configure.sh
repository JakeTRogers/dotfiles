#!/usr/bin/env bash

set -e

if [ "${INSTALL_MODE}" = 'full' ]; then
  ln -sf "${DOTFILES_LOCATION}/tmux/tmux.conf" "${HOME}/.tmux.conf"

  # install tmux plugin manager
  mkdir -p ~/.tmux/plugins
  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

  # install tmux plugins
  ~/.tmux/plugins/tpm/bin/install_plugins
fi
