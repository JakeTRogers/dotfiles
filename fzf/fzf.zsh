# if fzf is installed configure it
if command -v fzf &> /dev/null; then
  export FZF_DEFAULT_OPTS='--height 80% --tmux 100%,100% --layout reverse --border rounded'
  export FZF_CTRL_T_OPTS='--preview-window="bottom,70%,border-top" --preview "bat --color=always --style=header,grid --line-range :500 {}"'
  export FZF_ALT_C_OPTS="--preview 'tree -C {} | head -200'"
  export FZF_CTRL_R_OPTS="--preview 'bat {}' --preview-window down:3:hidden:wrap --bind '?:toggle-preview'"

  # source fzf key bindings
  source <(fzf --zsh)

  # source fzf git integration
  source "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/fzf-git.sh"

  # override fzf git integration defaults
  _fzf_git_fzf() {
    fzf --height=80% --tmux 100%,100% \
        --layout=reverse --multi --min-height=20 --border \
        --border-label-pos=2 \
        --color='header:italic:underline,label:blue' \
        --preview-window='bottom,70%,border-top' \
        --bind='ctrl-/:change-preview-window(down,50%,border-top|hidden|)' "$@"
  }

  # gcof, gaf, and gswt live in omz/functions/ alongside every other user
  # command, so they are autoloaded, completed, and covered by `cheat`.
fi
