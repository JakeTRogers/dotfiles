#!/usr/bin/env bash

set -e

user=$(whoami)

# get users current shell directly from /etc/passwd (avoids depending on getent,
# which is missing on some minimal images) and stays consistent with the
# /etc/passwd check used below to decide whether to run chsh
current_shell=$(basename "$(grep "^$user:" /etc/passwd | cut -d: -f7)")
if [ "$current_shell" = "$(basename "$(command -v zsh)")" ]; then
  echo "Login shell is already zsh, skipping chsh"
else
  # chsh is missing on minimal RHEL-family images (util-linux-user) and pointless in containers
  if command -v chsh &> /dev/null; then
    # skip chsh if the current user is not in /etc/passwd (e.g. ldap user)
    if grep -q "^$user:" /etc/passwd; then
      echo "Changing login shell to zsh for user $user"
      # shellcheck disable=SC2086,SC2154  # $elevate is exported by install.sh and must word-split
      $elevate chsh -s "$(command -v zsh)" "$user" || echo "⚠️ unable to change login shell to zsh"
    else
      echo "⚠️ user $user not found in /etc/passwd, skipping login shell change"
    fi
  else
    echo "⚠️ chsh not available, skipping login shell change"
  fi
fi

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
