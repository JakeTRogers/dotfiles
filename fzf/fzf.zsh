# if fzf is installed configure it
if command -v fzf &> /dev/null; then
  export FZF_DEFAULT_OPTS='--height 80% --tmux 95%,80% --layout reverse --border rounded'
  export FZF_CTRL_T_OPTS='--preview-window="right,60%,border-left" --preview "bat --color=always --style=header,grid --line-range :500 {}"'
  export FZF_ALT_C_OPTS="--preview 'tree -C {} | head -200'"
  export FZF_CTRL_R_OPTS="--preview 'bat {}' --preview-window down:3:hidden:wrap --bind '?:toggle-preview'"

  # source fzf key bindings
  source <(fzf --zsh)

  # source fzf git integration
  source "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/fzf-git.sh"

  # override fzf git integration defaults
  _fzf_git_fzf() {
    fzf --height=50% --tmux 95%,80% \
        --layout=reverse --multi --min-height=20 --border \
        --border-label-pos=2 \
        --color='header:italic:underline,label:blue' \
        --preview-window='right,65%,border-left' \
        --bind='ctrl-/:change-preview-window(down,50%,border-top|hidden|)' "$@"
  }

  # git functions/aliases
  gcof() {
    _fzf_git_each_ref --no-multi | xargs git checkout
  }

  gaf() {
    _fzf_git_each_files | xargs git add
  }
  gswt() {
    cd "$(_fzf_git_worktrees --no-multi)"
  }
fi
