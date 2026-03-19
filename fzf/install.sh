#!/usr/bin/env bash

set -e

if command -v fzf &> /dev/null; then
  echo "🟢 fzf is already installed"
else
  /usr/local/bin/getRelease -u https://github.com/junegunn/fzf
  if ! command -v fzf &> /dev/null; then
    echo "🔴 fzf install failed"
    exit 1
  else
    echo "🟢 fzf installed successfully"
  fi
fi
