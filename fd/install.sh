#!/usr/bin/env bash

set -e

if command -v fd &> /dev/null; then
  echo "🟢 fd is already installed"
else
  getRelease -u https://github.com/sharkdp/fd
  if ! command -v fd &> /dev/null; then
    echo "🔴 fd install failed"
    exit 1
  else
    echo "🟢 fd installed successfully"
  fi
fi
