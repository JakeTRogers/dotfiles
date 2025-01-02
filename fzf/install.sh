#!/usr/bin/env bash

set -e

if command -v fzf &> /dev/null; then
  echo "🟢 fzf is already installed"
else
  echo -e "🟠 fzf not found in path, install it: get_release -u https://github.com/junegunn/fzf"
fi
