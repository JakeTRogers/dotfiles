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
alias toCSV="awk 'BEGIN { OFS=\",\" } { \$1=\$1; print }'"
alias tmux='tmux -2'
alias update_vim_plugins='for dir in $(ls -1 ~/.vim/bundle); do echo "$dir"; git -C "$HOME/.vim/bundle/$dir" pull; echo; done'

# date stuff
alias d='date +%Y-%m-%d'
alias dt='date +%Y-%m-%d-%H:%M'
alias sd='date +%Y%m%d'
alias sdt='date +%Y%m%d-%H%M'

# kubernetes stuff
# Pods not running or succeeded
alias k8b='kubectl get pods -A --field-selector=status.phase!=Running,status.phase!=Succeeded'
# Unschedulable pods
alias k8ef='kubectl get events -A --field-selector=reason=FailedScheduling --sort-by=.metadata.creationTimestamp'
# Externally exposed services(not through ingress)
alias k8ext='kubectl get svc -A | awk '\''$4=="LoadBalancer" || $4=="NodePort"'\'
# Pods with restarts > 0 (flapping)
alias k8flap="kubectl get pods -A -o json | jq -r '
(
  [\"NAMESPACE\",\"POD\",\"CONTAINER\",\"RESTARTS\"],
  ( .items[]
    | .metadata.namespace as \$ns
    | .metadata.name as \$pod
    | ( (.status.containerStatuses // []) + (.status.initContainerStatuses // []) )[]
    | select((.restartCount // 0) > 0)
    | [\$ns, \$pod, .name, ((.restartCount // 0) | tostring)]
  )
)
| @tsv' | column -t"
# Ingress inventory (custom-columns output) with header
alias k8ing="kubectl get ingress -A -o custom-columns='NS:.metadata.namespace,NAME:.metadata.name,HOSTS:.spec.rules[*].host' --no-headers=false"
# IngressRoute inventory(traefik)
alias k8ingr='kubectl get ingressroute -A -o json | jq -r '\''
  ["NAMESPACE","NAME","HOSTS"],
  (
    .items[]
    | select(.metadata.annotations["kubernetes.io/ingress.class"] == "traefik")
    | .metadata.namespace as $ns
    | .metadata.name as $name
    | (.spec.routes // [])
    | map(.match // "")
    | join(" || ")
    | [
        $ns,
        $name,
        (
          .
          | gsub("`"; "")
          | (scan("Host\\(([^)]*)\\)") | join(","))
          | if .=="" then "-" else . end
        )
      ]
  )
  | @tsv
'\'''
# Nodes not Ready
alias k8nr="kubectl get nodes -o json | jq -r '
  [\"NODE\"],
  ((.items // .)[]
    | select(.status.conditions[] | select(.type==\"Ready\" and .status!=\"True\"))
    | [.metadata.name]
  ) | @tsv' | column -t"
# Resources with stuck finalizers (may block deletion)
alias k8sf="kubectl get all -A -o json | jq -r '[
  \"KIND\",\"NAMESPACE\",\"NAME\",\"FINALIZERS\"
],
(.items[]
 | select(.metadata.finalizers != null)
 | [.kind, (.metadata.namespace // \"-\"), .metadata.name, (.metadata.finalizers | join(\",\"))]
) | @tsv' | column -t"
# pods by cpu
alias k8tc='kubectl top pods -A --sort-by=cpu'
# pods by memory
alias k8tm='kubectl top pods -A --sort-by=memory'

# git stuff
alias gitrebaseall='def_branch=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed "s@^refs/remotes/origin/@@" || { git branch | grep -m1 -E "development|production|main|master" | tr -d " *"; }); for branch in $(git branch | grep -vE "development|production|main|master" | tr -d " *"); do echo "Rebasing $branch..."; git checkout $branch && git rebase $def_branch && git push origin $branch -f || { echo "❌ Failed on $branch"; git rebase --abort 2>/dev/null; git checkout $def_branch; return 1; }; echo;done; git checkout $def_branch; git branch -v'

# zsh stuff
alias n=nvim
