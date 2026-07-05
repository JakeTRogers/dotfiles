#!/usr/bin/env bash

set -e

if [ "${INSTALL_MODE}" = 'full' ]; then
  mkdir -p "${HOME}/.vim/autoload" "${HOME}/.vim/bundle" "${HOME}/.vim/ftdetect"
  ln -sf "${DOTFILES_LOCATION}/vim/vimrc" "${HOME}/.vimrc"

  # install vim pathogen, pinned to a commit hash (latest release: v2.4) to reduce supply chain risk
  pathogen_commit='4d584ea8c85408ca0d68b7b1693f3e2db8aa762a'
  curl -fLSso "${HOME}/.vim/autoload/pathogen.vim" "https://raw.githubusercontent.com/tpope/vim-pathogen/${pathogen_commit}/autoload/pathogen.vim"

  # vim plugins to be cloned, each pinned to a commit hash (latest release, or HEAD
  # if the repo has none) to reduce supply chain risk from a compromised upstream branch
  vim_plugins=( \
    'https://github.com/altercation/vim-colors-solarized.git 528a59f26d12278698bb946f8fb82a63711eec21' \
    'https://github.com/ctrlpvim/ctrlp.vim.git 971c4d41880b72dbbf1620b3ad91418a6a6f6b9c' \
    'https://github.com/godlygeek/tabular.git 7bd1d0de5d390834220b7d0a791bb9734fafa0cc' \
    'https://github.com/myusuf3/numbers.vim.git d1e9dace93a628f22f159254f3754b5041f5602a' \
    'https://github.com/scrooloose/nerdtree.git 9b465acb2745beb988eff3c1e4aa75f349738230' \
    'https://github.com/sheerun/vim-polyglot.git 1d1f36b24ea601eb950865982e05b875aa702330' \
    'https://github.com/tomtom/tlib_vim.git 2ae171a8eb6bbd65bdbf75cdb5fa5303d6483bba' \
    'https://github.com/tpope/vim-surround.git aeb933272e72617f7c4d35e1f003be16836b948d' \
    'https://github.com/vim-airline/vim-airline.git 1586662296c9dc946083e17cb6a4ef0b3e7c0d68' \
    'https://github.com/vim-airline/vim-airline-themes.git 77aab8c6cf7179ddb8a05741da7e358a86b2c3ab' \
  )

  # clone vim plugins and pin them to their commit hash
  plugin_names=()
  for entry in "${vim_plugins[@]}"; do
    repo="${entry% *}"
    commit="${entry#* }"
    plugin_name="$(basename "$repo" .git)"
    plugin_dir="${HOME}/.vim/bundle/${plugin_name}"
    plugin_names+=("$plugin_name")

    if [ -d "$plugin_dir" ]; then
      echo "Updating $plugin_name"
      git -C "$plugin_dir" fetch --quiet --tags origin
    else
      echo "Installing $plugin_name"
      git clone --quiet "$repo" "$plugin_dir"
    fi
    git -C "$plugin_dir" checkout --quiet "$commit"
  done

  # remove any previously installed plugins that are no longer listed above
  for plugin_dir in "${HOME}/.vim/bundle"/*; do
    [ -d "$plugin_dir" ] || continue
    plugin_name="$(basename "$plugin_dir")"

    keep=false
    for name in "${plugin_names[@]}"; do
      if [ "$name" = "$plugin_name" ]; then
        keep=true
        break
      fi
    done

    if [ "$keep" = false ]; then
      echo "Removing $plugin_name"
      rm -rf "$plugin_dir"
    fi
  done
fi
