#!/usr/bin/env bash

set -e

if command -v fd &> /dev/null; then
  echo "🟢 fd is already installed"
else
  echo -e "🟠 fd not found in path, install it: get_release -u https://github.com/sharkdp/fd"
fi
