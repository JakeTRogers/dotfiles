#!/usr/bin/env bash

set -e

$elevate chsh -s /usr/bin/zsh $(whoami)

cat <<'PROFILE' > "${HOME}/.profile"
# override shell assignment
if [ -z "${NOZSH}" ] && [ $TERM = "xterm" -o $TERM = "xterm-256color" -o $TERM = "screen" ] && type zsh &> /dev/null; then
  export SHELL=$(which zsh)
  if [[ -o login ]]; then
    exec zsh -l
  else
    exec zsh
  fi
fi
PROFILE
