umask 022
export VISUAL=vi
export EDITOR="$VISUAL"
export PAGER='less -i'
export TERM='xterm-256color'

# auto accept and run autosuggest
bindkey '^ ' autosuggest-execute

# enforce emacs keybindings
bindkey -e

# start ssh-agent(12hr lifetime) if its not running and then add keys
ssh-add -l &>/dev/null
if [[ "$?" == 2 ]]; then
  test -r ~/.ssh-agent && eval "$(<~/.ssh-agent)" >/dev/null
  ssh-add -l &>/dev/null
  error_code=$?
  if [[ "$error_code" == 1 ]]; then
    ssh-add
  elif [[ "$error_code" == 2 ]]; then
    (umask 066; ssh-agent -t 43200 > ~/.ssh-agent)
    eval "$(<~/.ssh-agent)" >/dev/null
    ssh-add
  fi
fi
