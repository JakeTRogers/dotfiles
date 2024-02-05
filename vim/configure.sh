#!/usr/bin/env bash

set -e

if [ "${INSTALL_MODE}" = 'full' ]; then
  test -d ${HOME}/.vim || mkdir ${HOME}/.vim
  test -d ${HOME}/.vim/autoload || mkdir ${HOME}/.vim/autoload
  test -d ${HOME}/.vim/bundle || mkdir ${HOME}/.vim/bundle
  test -d ${HOME}/.vim/ftdetect || mkdir ${HOME}/.vim/ftdetect
  ln -sf "${DOTFILES_LOCATION}/vim/vimrc" "${HOME}/.vimrc"

  # install vim pathogen
  curl -LSso ~/.vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim

  # array of vim plugins to be cloned
  vim_plugins=( \
    'https://github.com/altercation/vim-colors-solarized.git' \
    'https://github.com/ctrlpvim/ctrlp.vim.git' \
    'https://github.com/garbas/vim-snipmate.git' \
    'https://github.com/godlygeek/tabular.git' \
    'https://github.com/MarcWeber/vim-addon-mw-utils.git' \
    'https://github.com/myusuf3/numbers.vim.git' \
    'https://github.com/rodjek/vim-puppet.git' \
    'https://github.com/scrooloose/nerdtree.git' \
    'https://github.com/scrooloose/syntastic.git' \
    'https://github.com/sheerun/vim-polyglot.git' \
    'https://github.com/tomtom/tlib_vim.git' \
    'https://github.com/tpope/vim-surround.git' \
    'https://github.com/vim-airline/vim-airline.git' \
    'https://github.com/vim-airline/vim-airline-themes.git' \
  )

  # clone vim plugins
  for repo in "${vim_plugins[@]}"; do
    if [ -d "${HOME}/.vim/bundle/$(basename $repo .git)" ]; then
      echo "Updating $(basename $repo .git)"
      git -C "${HOME}/.vim/bundle/$(basename $repo .git)" pull --quiet
    else
      echo "Installing $(basename $repo .git)"
      git -C "${HOME}/.vim/bundle" clone --quiet $repo
    fi
  done
fi
