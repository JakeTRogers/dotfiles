#!/usr/bin/env bash

set -e

ln -sf "${DOTFILES_LOCATION}/gpg/gpg-agent.conf" "${HOME}/.gnupg/gpg-agent.conf"
