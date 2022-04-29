#!/usr/bin/env bash

set -e

cmd_exists zsh || install_package zsh
chsh -s /usr/bin/zsh