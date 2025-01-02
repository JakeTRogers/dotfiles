#!/usr/bin/env bash

set -e

if command -v bat &> /dev/null; then
  echo "🟢 bat is already installed"
else
  echo -e "🟠 bat not found in path, install it: get_release -u https://github.com/sharkdp/bat"
fi
