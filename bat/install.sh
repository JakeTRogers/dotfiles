#!/usr/bin/env bash

set -e

if command -v bat &> /dev/null; then
  echo "🟢 bat is already installed"
else
  /usr/local/bin/getRelease -u https://github.com/sharkdp/bat
  if ! command -v bat &> /dev/null; then
    echo "🔴 bat install failed"
    exit 1
  else
    echo "🟢 bat installed successfully"
  fi
fi
