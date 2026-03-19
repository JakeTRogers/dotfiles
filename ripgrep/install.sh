#!/usr/bin/env bash

set -e

if command -v rg &> /dev/null; then
  echo "🟢 ripgrep is already installed"
else
  /usr/local/bin/getRelease -u https://github.com/BurntSushi/ripgrep
  if ! command -v rg &> /dev/null; then
    echo "🔴 ripgrep install failed"
    exit 1
  else
    echo "🟢 ripgrep installed successfully"
  fi
fi
