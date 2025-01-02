#!/usr/bin/env bash

set -e

if command -v rg &> /dev/null; then
  echo "🟢 ripgrep is already installed"
else
  echo -e "🟠 rg not found in path, install it: get_release -u https://github.com/BurntSushi/ripgrep"
fi
