#!/usr/bin/env bash

set -e

if [ "${INSTALL_MODE}" = 'full' ]; then
  mkdir -p "${HOME}/.vim/autoload" "${HOME}/.vim/bundle" "${HOME}/.vim/ftdetect"
  ln -sf "${DOTFILES_LOCATION}/vim/vimrc" "${HOME}/.vimrc"

  # install vim pathogen
  curl -fLSso "${HOME}/.vim/autoload/pathogen.vim" https://raw.githubusercontent.com/tpope/vim-pathogen/master/autoload/pathogen.vim

  # array of vim plugins to be cloned
  vim_plugins=( \
    'https://github.com/altercation/vim-colors-solarized.git' \
    'https://github.com/ctrlpvim/ctrlp.vim.git' \
    'https://github.com/godlygeek/tabular.git' \
    'https://github.com/myusuf3/numbers.vim.git' \
    'https://github.com/scrooloose/nerdtree.git' \
    'https://github.com/sheerun/vim-polyglot.git' \
    'https://github.com/tomtom/tlib_vim.git' \
    'https://github.com/tpope/vim-surround.git' \
    'https://github.com/vim-airline/vim-airline.git' \
    'https://github.com/vim-airline/vim-airline-themes.git' \
  )

  # clone vim plugins
  for repo in "${vim_plugins[@]}"; do
    if [ -d "${HOME}/.vim/bundle/$(basename "$repo" .git)" ]; then
      echo "Updating $(basename "$repo" .git)"
      git -C "${HOME}/.vim/bundle/$(basename "$repo" .git)" pull --quiet
    else
      echo "Installing $(basename "$repo" .git)"
      git -C "${HOME}/.vim/bundle" clone --quiet "$repo"
    fi
  done
fi
