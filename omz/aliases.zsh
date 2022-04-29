alias digg='dig +short +search '
alias dir='ls -l'
alias dutop='sudo du -m --max-depth=1 . | sort -nr | head -n50'
alias grep='grep --color=auto'
alias grepify=' tr -s "\n" "|" | sed "s/|$//"'
alias h='history'
alias ip4="/?bin/ip -o -4 a | grep -v ': lo' | sed 's/[0-9]\+\:\s*//;s/\// \//' | column -t"
alias l='ls -alF'
alias la='ls -la'
alias lal='ls -altr'
alias ldir='ll -d */'
alias ll='ls -l'
alias ls-l='ls -l'
alias ls='ls -F --color=auto'
alias lt='ls -ltr'
alias lu='ls -ltur'
alias sl='ls'
alias sssh='ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no'
alias sscp='scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no'
alias tmux='tmux -2'
alias update_vim_plugins='for dir in $(ls -1 ~/.vim/bundle); do echo "$dir"; git -C "$HOME/.vim/bundle/$dir" pull; echo; done'

# date stuff
alias d='date +%Y-%m-%d'
alias dt='date +%Y-%m-%d-%H:%M'
alias sd='date +%Y%m%d'
alias sdt='date +%Y%m%d-%H%M'

# puppet and git stuff
alias guard='guard --no-bundler-warning'
alias pdkbe='pdk bundle exec'
alias pdkt='pdk test unit'
alias pdkv='pdk validate'
alias pdkvt='pdk validate && pdk test unit'
alias gciaf='git commit -a --fixup'
alias gcif='git commit --fixup'
alias gdu='git diff -U0'
alias gdus='git diff -U0 --cached'
alias ghist="git log --decorate --pretty=format:'%C(yellow)%h%C(reset) %C(green)%G?%C(reset) %C(blue)%an%C(reset) %C(cyan)%cr%C(reset) %s %C(auto)%d%C(reset)' --graph --date-order"
alias gitrebaseall='for branch in $(git br | egrep -v "main|development|production" | tr -d " " | tr -d "*"); do echo $branch; git co $branch && git rebase development && git push origin $branch -f; echo;echo;done; git co development; git br -v'
alias grias='git rebase --interactive --autosquash'

# zsh stuff
alias zshconfig="vim ~/.zshrc"
