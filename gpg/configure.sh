#!/usr/bin/env bash

set -e

test -d "${HOME}/.gnupg" || mkdir -p "${HOME}/.gnupg"
ln -sf "${DOTFILES_LOCATION}/gpg/gpg-agent.conf" "${HOME}/.gnupg/gpg-agent.conf"
