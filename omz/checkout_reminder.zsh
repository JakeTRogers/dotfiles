# Remind at shell start when the Checkout is stale.
#
# Configure step changes reach a machine only when the Installer runs again,
# and a Dev container with a Home volume runs it only on its first build. So
# when the Checkout is on its default branch, print one line naming the
# command to run when either:
#   - origin's default branch has commits the Checkout lacks, as of the last
#     fetch, which runs in the background at most once a day; or
#   - HEAD differs from the commit install.sh recorded on its last run.
#
# zshrc sources this above the Powerlevel10k instant prompt preamble, the one
# place console output does not trip p10k's warning. Startup never waits on
# the network, and this stays quiet on any other branch, when the fetch fails,
# and when install.sh has recorded nothing yet.

() {
  emulate -L zsh

  local state_dir=${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles
  [[ -r $state_dir/installed && -L $HOME/.zshrc ]] || return 0

  # ~/.zshrc links to omz/zshrc in the Checkout.
  local zshrc=${${:-$HOME/.zshrc}:A}
  [[ $zshrc == */omz/zshrc ]] || return 0
  local checkout=${zshrc:h:h}

  # git exports these to hooks, and they override -C. Unexported locals hide
  # them, so a shell started from a hook still looks at the Checkout.
  local GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE GIT_COMMON_DIR GIT_OBJECT_DIRECTORY

  # HEAD's commit, HEAD's branch, and the branch origin/HEAD points at.
  local -a refs
  refs=(${(f)"$(command git -C $checkout rev-parse HEAD \
    --symbolic-full-name HEAD refs/remotes/origin/HEAD 2>/dev/null)"}) || return 0
  (( $#refs == 3 )) || return 0
  local head=$refs[1] branch=$refs[2] origin_default=${refs[3]#refs/remotes/}
  [[ $branch == refs/heads/${origin_default#origin/} ]] || return 0

  # Fetch at most once a day, in the background and silently, for a later
  # shell to compare against. The stamp is written first, so a fetch that
  # fails waits a day too. BatchMode stops ssh asking for a passphrase or a
  # host key on /dev/tty, where it would interrupt the new shell.
  local -a fetched_today=($state_dir/last-fetch(N.mh-24))
  if (( ! $#fetched_today )); then
    : >| $state_dir/last-fetch
    GIT_TERMINAL_PROMPT=0 GIT_SSH_COMMAND="${GIT_SSH_COMMAND:-ssh} -o BatchMode=yes" \
      command git -C $checkout fetch --quiet origin &>/dev/null </dev/null &!
  fi

  # install.sh writes one key=value pair per line.
  local -A installed
  local line
  for line in ${(f)"$(<$state_dir/installed)"}; do
    installed[${line%%=*}]=${line#*=}
  done

  local checkout_display=${(D)checkout}
  local install_cmd='./install.sh'
  [[ $installed[mode] == full ]] && install_cmd+=' full'

  # Exit status 1 means origin's default branch is not in HEAD's history;
  # anything above 1 is an error, which says nothing about being behind.
  command git -C $checkout merge-base --is-ancestor $origin_default HEAD 2>/dev/null
  if (( $? == 1 )); then
    print -ru2 -- "dotfiles: $checkout_display is behind $origin_default. Update with: cd $checkout_display && git pull && $install_cmd"
  elif [[ $head != $installed[commit] ]]; then
    print -ru2 -- "dotfiles: $checkout_display has changed since install.sh last ran. Apply with: cd $checkout_display && $install_cmd"
  fi
}
