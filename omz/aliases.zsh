# general stuff
# Short-form DNS lookup honoring the search domain
alias digg='dig +short +search '
# Long listing
alias dir='ls -l'
# 50 largest directories here, in MB, descending
alias dutop='sudo du -m --max-depth=1 . | sort -nr | head -n50'
# grep with color always enabled
alias grep='grep --color=auto'
# Join stdin lines into one pipe-delimited alternation
alias grepify=' tr -s "\n" "|" | sed "s/|$//"'
# Show shell history
alias h='history'
# IPv4 address per interface, loopback excluded, as a table
alias ip4="command ip -o -4 a | grep -v ': lo' | sed 's/[0-9]\+\:\s*//;s/\// \//' | column -t"
# List all, long, with type indicators
alias l='ls -alF'
# List all, long
alias la='ls -la'
# List all, long, oldest modified first
alias lal='ls -altr'
# List only directories
alias ldir='ll -d */'
# Long listing
alias ll='ls -l'
# Long listing (typo guard)
alias ls-l='ls -l'
# Colorized ls with type indicators
alias ls='ls -F --color=auto'
# Long listing, oldest modified first
alias lt='ls -ltr'
# Long listing, oldest accessed first
alias lu='ls -ltur'
# ls (typo guard)
alias sl='ls'
# ⚠ ssh with host key checking disabled
alias sssh='ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no'
# ⚠ scp with host key checking disabled
alias sscp='scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no'
# Convert whitespace-separated stdin into CSV
alias toCSV="awk 'BEGIN { OFS=\",\" } { \$1=\$1; print }'"
# tmux forced to 256 colors
alias tmux='tmux -2'
# git pull every plugin under ~/.vim/bundle
alias update_vim_plugins='for dir in $(ls -1 ~/.vim/bundle); do echo "$dir"; git -C "$HOME/.vim/bundle/$dir" pull; echo; done'

# date stuff
# Today as YYYY-MM-DD
alias d='date +%Y-%m-%d'
# Now as YYYY-MM-DD-HH:MM
alias dt='date +%Y-%m-%d-%H:%M'
# Today as YYYYMMDD
alias sd='date +%Y%m%d'
# Now as YYYYMMDD-HHMM
alias sdt='date +%Y%m%d-%H%M'

# zsh stuff
# Open nvim
alias n=nvim

# bat stuff
# bat with no decorations (plain output)
alias batp='bat --plain'
