# functions

#######################################
# cdr - Change directory to a git repository
# Arguments:
#   None
# Outputs:
#   Interactive fzf selection of git repositories in ~/gitrepos, then cd into it
# Returns:
#   0 on success, 1 if no selection made
#######################################
cdr() {
  local repo
  repo=$(find ~/gitrepos -type d -name .git 2>/dev/null | sed 's#/.git$##' | fzf --prompt="repo> ") || return
  cd "$repo"
}

################################
# ff - Fuzzy find a file and open it in the editor
# Arguments:
#   None
# Outputs:
#   Interactive fzf selection of files in the current directory, then opens the selected file in the default editor
# Returns:
#   0 on success, 1 if no selection made
################################
ff() {
  local file
  file=$(fzf) || return
  ${EDITOR:-vim} "$file"
}

################################
# gundo - Undo the last git commit (soft reset)
# Arguments:
#   None
# Outputs:
#   Resets the last commit but keeps changes staged
# Returns:
#   0 on success, 128 if not in a git repository
################################
gundo() {
  git reset --soft HEAD~1
}

################################
# rgf - Fuzzy find a file containing a pattern and open it in the editor
# Arguments:
#   $1 - The pattern to search for
# Outputs:
#   Interactive fzf selection of files containing the pattern, then opens the selected file at the matching line in the default editor
# Returns:
#   0 on success, 1 if no selection made or pattern is empty
################################
rgf() {
  local query="$1"
  [[ -z "$query" ]] && { echo "Usage: rgf <pattern>"; return 1; }
  local file
  file=$(rg --line-number --no-heading "$query" | fzf --delimiter : --nth 1,2,3..) || return
  local f l
  f=$(echo "$file" | cut -d: -f1)
  l=$(echo "$file" | cut -d: -f2)
  ${EDITOR:-vim} "+${l}" "$f"
}

#######################################
# update all git mirrors in subdirectories of the current directory
# Arguments:
#   None
# Outputs:
#   Writes the git fetch and push status to stdout
# Returns:
#   0 on success, 1 if any operations failed
#######################################
function update_git_mirrors_in_subdirs () {
  local dir
  local failed=0

  for dir in */; do
    # Skip if not a directory
    [[ -d "$dir" ]] || continue

    # Strip trailing slash
    dir="${dir%/}"

    echo "Processing: $dir"

    # Check if it's a git repository
    if ! git -C "$dir" rev-parse --git-dir &>/dev/null; then
      echo "  ⚠️  Skipping: not a git repository"
      echo
      continue
    fi

    # Fetch with prune
    if git -C "$dir" fetch -p origin; then
      echo "  ✓ Fetch completed"
    else
      echo "  ✗ Fetch failed"
      ((failed++))
    fi

    # Push mirror
    if git -C "$dir" push --mirror; then
      echo "  ✓ Mirror push completed"
    else
      echo "  ✗ Mirror push failed"
      ((failed++))
    fi

    echo
  done

  if [[ $failed -gt 0 ]]; then
    echo "⚠️  Completed with $failed error(s)"
    return 1
  else
    echo "✅ All mirrors updated successfully"
  fi
}

#######################################
# git diff with 0 lines of context
# Arguments:
#   Files to diff (optional, defaults to all)
# Outputs:
#   Git diff output
#######################################
function gdu() {
  git diff -U0 "$@"
}

#######################################
# git diff staged with 0 lines of context
# Arguments:
#   Files to diff (optional, defaults to all)
# Outputs:
#   Git diff output
#######################################
function gdus() {
  git diff -U0 --cached "$@"
}

#######################################
# git commit fixup
# Arguments:
#   Commit hash to fixup
# Outputs:
#   Commit message
#######################################
function gcif() {
  git commit --fixup "$@"
}

#######################################
# git commit all fixup
# Arguments:
#   Commit hash to fixup
# Outputs:
#   Commit message
#######################################
function gciaf() {
  git commit -a --fixup "$@"
}

#######################################
# git rebase interactive autosquash
# Arguments:
#   Commit ref to rebase from (optional, defaults to branch base)
# Outputs:
#   Interactive rebase
#######################################
function grias() {
  local target=$1

  # If no argument, find the base branch
  if [[ -z $target ]]; then
    local base_branch
    base_branch=$(git_find_branch_base -n)
    [[ -z $base_branch ]] && { echo "grias: could not find main/master/develop/development/production" >&2; return 1; }
  fi

  git rebase --interactive --autosquash "$base_branch"
}

#######################################
# git_find_branch_base - Find base branch name or merge base commit
#
# Searches for main/master/develop/development/production branches.
# By default, returns the merge base commit hash.
# With -n or --name, returns the branch name instead.
#
# Usage:
#   local base_commit base_branch
#   base_commit=$(git_find_branch_base)
#   base_branch=$(git_find_branch_base -n)
#
# Arguments:
#   -n, --name    Return branch name instead of commit hash
#
# Globals:
#   None
# Returns:
#   Merge base commit hash (default) or branch name, or empty string if not found
#######################################
function git_find_branch_base() {
  local return_name=0
  local merge_base base_branch branch

  # Parse arguments
  if [[ "$1" == "-n" || "$1" == "--name" ]]; then
    return_name=1
  fi

  # Try to find base branch and merge base
  for branch in main master develop development production; do
    if git show-ref --verify --quiet "refs/heads/$branch" 2>/dev/null; then
      base_branch=$branch
      merge_base=$(git merge-base HEAD "$branch" 2>/dev/null)
      [[ -n "$merge_base" ]] && break
    fi
    if git show-ref --verify --quiet "refs/remotes/origin/$branch" 2>/dev/null; then
      base_branch="origin/$branch"
      merge_base=$(git merge-base HEAD "origin/$branch" 2>/dev/null)
      [[ -n "$merge_base" ]] && break
    fi
  done

  # If no merge base found with standard branches, fall back to initial commit
  if [[ -z "$merge_base" ]]; then
    merge_base=$(git rev-list --max-parents=0 HEAD 2>/dev/null | head -1)
  fi

  # Return based on flag
  if [[ $return_name -eq 1 ]]; then
    echo "$base_branch"
  else
    echo "$merge_base"
  fi
}

#######################################
# _check_podman - Check if podman is available
#
# Verifies that podman command is available in PATH.
# Prints error message if not found.
#
# Arguments:
#   None
# Returns:
#   0 if podman is available, 1 if not found
#######################################
function _check_podman() {
  if ! command -v podman &> /dev/null; then
    echo "podman: command not found" >&2
    return 1
  fi
  return 0
}

#######################################
# fpe - Exec into a running podman container
#
# Interactive selection of running container with fzf, then exec into it.
# Supports custom user, shell, working directory, and command execution.
#
# Arguments:
#   -u, --user USER       Run as specified user
#   -s, --shell SHELL     Use specified shell (default: /bin/bash)
#   -w, --workdir PATH    Set working directory
#   -c, --cmd COMMAND     Execute command instead of interactive shell
#   query                 Optional fzf search query
#
# Outputs:
#   Interactive fzf selection, then executes into container
#######################################
function fpe() {
  _check_podman || return 1

  local -A opts
  zparseopts -D -E -A opts u: -user:=u s: -shell:=s w: -workdir:=w c: -cmd:=c

  local user="${opts[-u]}"
  local shell="${opts[-s]:-/bin/bash}"
  local workdir="${opts[-w]}"
  local cmd="${opts[-c]}"
  local query="$1"

  local cid
  cid=$(podman ps | sed 1d | fzf -1 -q "$query" \
    --border-label '🐳 Running Containers' \
    --header 'CTRL-L (logs) ╱ ALT-I (inspect) ╱ CTRL-S (stats) ╱ CTRL-D (delete)' \
    --preview-window 'down,60%' \
    --preview 'podman inspect {1} | jq -C '\''.[0] | {Status: .State.Status, Image: .ImageName, Name: .Name, Created: .Created, Command: .Config.Cmd, Ports: .NetworkSettings.Ports, Mounts: [.Mounts[].Destination]}'\''' \
    --bind 'ctrl-l:execute(podman logs --tail 50 --color {1} | ${PAGER:-less} -R > /dev/tty)' \
    --bind 'alt-i:execute(podman inspect {1} | jq -C . | ${=PAGER:-less} -R > /dev/tty)' \
    --bind 'ctrl-s:execute(podman stats --no-stream {1} > /dev/tty; read -k 1)' \
    --bind 'ctrl-d:reload(podman rm {1} 2>&1; podman ps | sed 1d)' \
    | awk '{print $1}')

  [ -n "$cid" ] && podman exec ${user:+-u $user} ${workdir:+-w $workdir} -it "$cid" ${cmd:-$shell}
}

#######################################
# fpse - Start and exec into a podman container
#
# Interactive selection of any container (including stopped) with fzf,
# starts it if needed, then exec into it. Supports custom user, shell,
# working directory, and command execution.
#
# Arguments:
#   -u, --user USER       Run as specified user
#   -s, --shell SHELL     Use specified shell (default: /bin/bash)
#   -w, --workdir PATH    Set working directory
#   -c, --cmd COMMAND     Execute command instead of interactive shell
#   query                 Optional fzf search query
#
# Outputs:
#   Interactive fzf selection, starts container, then executes into it
#######################################
function fpse() {
  _check_podman || return 1

  local -A opts
  zparseopts -D -E -A opts u: -user:=u s: -shell:=s w: -workdir:=w c: -cmd:=c

  local user="${opts[-u]}"
  local shell="${opts[-s]:-/bin/bash}"
  local workdir="${opts[-w]}"
  local cmd="${opts[-c]}"
  local query="$1"

  local cid
  cid=$(podman ps -a | sed 1d | fzf -1 -q "$query" \
    --border-label '🐳 All Containers' \
    --header 'CTRL-L (logs) ╱ ALT-I (inspect) ╱ CTRL-S (stats) ╱ CTRL-D (delete)' \
    --preview-window 'down,60%' \
    --preview 'podman inspect {1} | jq -C '\''.[0] | {Status: .State.Status, Image: .ImageName, Name: .Name, Created: .Created, Command: .Config.Cmd, Ports: .NetworkSettings.Ports, Mounts: [.Mounts[].Destination]}'\''' \
    --bind 'ctrl-l:execute(podman logs --tail 50 --color {1} | ${PAGER:-less} -R > /dev/tty)' \
    --bind 'alt-i:execute(podman inspect {1} | jq -C . | ${=PAGER:-less} -R > /dev/tty)' \
    --bind 'ctrl-s:execute(podman stats --no-stream {1} > /dev/tty; read -k 1)' \
    --bind 'ctrl-d:reload(podman rm {1} 2>&1; podman ps -a | sed 1d)' \
    | awk '{print $1}')

  [ -n "$cid" ] && podman start "$cid" && podman exec ${user:+-u $user} ${workdir:+-w $workdir} -it "$cid" ${cmd:-$shell}
}

#######################################
# fpa - Attach to a running podman container
#
# Interactive selection of running container with fzf, then attach to it.
#
# Arguments:
#   query                 Optional fzf search query
#
# Outputs:
#   Interactive fzf selection, then attaches to container
#######################################
function fpa() {
  _check_podman || return 1

  local query="$1"

  local cid
  cid=$(podman ps | sed 1d | fzf -1 -q "$query" \
    --border-label '🐳 Running Containers' \
    --header 'CTRL-L (logs) ╱ ALT-I (inspect) ╱ CTRL-S (stats) ╱ CTRL-D (delete)' \
    --preview-window 'down,60%' \
    --preview 'podman inspect {1} | jq -C '\''.[0] | {Status: .State.Status, Image: .ImageName, Name: .Name, Created: .Created, Command: .Config.Cmd, Ports: .NetworkSettings.Ports, Mounts: [.Mounts[].Destination]}'\''' \
    --bind 'ctrl-l:execute(podman logs --tail 50 --color {1} | ${PAGER:-less} -R > /dev/tty)' \
    --bind 'alt-i:execute(podman inspect {1} | jq -C . | ${=PAGER:-less} -R > /dev/tty)' \
    --bind 'ctrl-s:execute(podman stats --no-stream {1} > /dev/tty; read -k 1)' \
    --bind 'ctrl-d:reload(podman rm {1} 2>&1; podman ps | sed 1d)' \
    | awk '{print $1}')

  [ -n "$cid" ] && podman attach "$cid"
}

#######################################
# fpsa - Start and attach to a podman container
#
# Interactive selection of any container (including stopped) with fzf,
# starts it if needed, then attach to it.
#
# Arguments:
#   query                 Optional fzf search query
#
# Outputs:
#   Interactive fzf selection, starts container, then attaches to it
#######################################
function fpsa() {
  _check_podman || return 1

  local query="$1"

  local cid
  cid=$(podman ps -a | sed 1d | fzf -1 -q "$query" \
    --border-label '🐳 All Containers' \
    --header 'CTRL-L (logs) ╱ ALT-I (inspect) ╱ CTRL-S (stats) ╱ CTRL-D (delete)' \
    --preview-window 'down,60%' \
    --preview 'podman inspect {1} | jq -C '\''.[0] | {Status: .State.Status, Image: .ImageName, Name: .Name, Created: .Created, Command: .Config.Cmd, Ports: .NetworkSettings.Ports, Mounts: [.Mounts[].Destination]}'\''' \
    --bind 'ctrl-l:execute(podman logs --tail 50 --color {1} | ${PAGER:-less} -R > /dev/tty)' \
    --bind 'alt-i:execute(podman inspect {1} | jq -C . | ${=PAGER:-less} -R > /dev/tty)' \
    --bind 'ctrl-s:execute(podman stats --no-stream {1} > /dev/tty; read -k 1)' \
    --bind 'ctrl-d:reload(podman rm {1} 2>&1; podman ps -a | sed 1d)' \
    | awk '{print $1}')

  [ -n "$cid" ] && podman start "$cid" && podman attach "$cid"
}

#######################################
# fps - Stop running podman containers
#
# Interactive selection of running containers with fzf (supports multiselect),
# then stops the selected containers.
#
# Arguments:
#   query                 Optional fzf search query
#
# Outputs:
#   Interactive fzf selection, then stops selected containers
#######################################
function fps() {
  _check_podman || return 1

  local query="$1"

  podman ps | sed 1d | fzf -1 -m -q "$query" \
    --border-label '🐳 Running Containers' \
    --header 'TAB (select multiple) ╱ CTRL-L (logs) ╱ ALT-I (inspect) ╱ CTRL-S (stats) ╱ CTRL-D (delete)' \
    --preview-window 'down,60%' \
    --preview 'podman inspect {1} | jq -C '\''.[0] | {Status: .State.Status, Image: .ImageName, Name: .Name, Created: .Created, Command: .Config.Cmd, Ports: .NetworkSettings.Ports, Mounts: [.Mounts[].Destination]}'\''' \
    --bind 'ctrl-l:execute(podman logs --tail 50 --color {1} | ${=PAGER:-less} -R > /dev/tty)' \
    --bind 'alt-i:execute(podman inspect {1} | jq -C . | ${=PAGER:-less} -R > /dev/tty)' \
    --bind 'ctrl-s:execute(podman stats --no-stream {1} > /dev/tty; read -k 1)' \
    --bind 'ctrl-d:reload(podman rm {1} 2>&1; podman ps | sed 1d)' \
    | awk '{print $1}' | xargs -r podman stop
}

#######################################
# fprm - Remove podman containers
#
# Interactive selection of containers with fzf (supports multiselect),
# then removes the selected containers.
#
# Arguments:
#   query                 Optional fzf search query
#
# Outputs:
#   Interactive fzf selection, then removes selected containers
#######################################
function fprm() {
  _check_podman || return 1

  local query="$1"

  podman ps -a | sed 1d | fzf -q "$query" --no-sort -m --tac \
    --border-label '🐳 All Containers' \
    --header 'TAB (select multiple) ╱ CTRL-L (logs) ╱ ALT-I (inspect) ╱ CTRL-S (stats)' \
    --preview-window 'down,60%' \
    --preview 'podman inspect {1} | jq -C '\''.[0] | {Status: .State.Status, Image: .ImageName, Name: .Name, Created: .Created, Command: .Config.Cmd, Ports: .NetworkSettings.Ports, Mounts: [.Mounts[].Destination]}'\''' \
    --bind 'ctrl-l:execute(podman logs --tail 50 --color {1} | ${=PAGER:-less} -R > /dev/tty)' \
    --bind 'alt-i:execute(podman inspect {1} | jq -C . | ${=PAGER:-less} -R > /dev/tty)' \
    --bind 'ctrl-s:execute(podman stats --no-stream {1} > /dev/tty; read -k 1)' \
    | awk '{print $1}' | xargs -r podman rm
}

#######################################
# fprmi - Remove podman images
#
# Interactive selection of images with fzf (supports multiselect),
# then removes the selected images.
#
# Arguments:
#   query                 Optional fzf search query
#
# Outputs:
#   Interactive fzf selection, then removes selected images
#######################################
function fprmi() {
  _check_podman || return 1

  local query="$1"

  podman images | sed 1d | fzf -q "$query" --no-sort -m --tac \
    --border-label '🐳 Images' \
    --header 'TAB (select multiple) ╱ ALT-I (inspect)' \
    --preview-window 'down,60%' \
    --preview 'podman inspect {3} | jq -C '\''.[0] | {Id: .Id, RepoTags: .RepoTags, Created: .Created, Size: .Size, Architecture: .Architecture, Os: .Os}'\''' \
    --bind 'alt-i:execute(podman inspect {3} | jq -C . | ${=PAGER:-less} -R > /dev/tty)' \
    | awk '{print $3}' | xargs -r podman rmi
}

#######################################
# fpl - View logs from podman containers
#
# Interactive selection of containers with fzf (supports multiselect),
# then displays logs. Supports following logs and specifying number of lines.
#
# Arguments:
#   -f, --follow          Follow log output
#   -n, --lines LINES     Number of lines to show (default: all)
#   query                 Optional fzf search query
#
# Outputs:
#   Interactive fzf selection, then displays container logs
#######################################
function fpl() {
  _check_podman || return 1

  local -A opts
  zparseopts -D -E -A opts f -follow=f n: -lines:=n

  local follow_flag=""
  local lines_flag=""
  [[ -n ${opts[-f]} ]] && follow_flag="-f"
  [[ -n ${opts[-n]} ]] && lines_flag="--tail ${opts[-n]}"

  local query="$1"

  local containers
  containers=($(podman ps -a | sed 1d | fzf -m -q "$query" \
    --border-label '🐳 All Containers' \
    --header 'TAB (select multiple) ╱ ALT-I (inspect) ╱ CTRL-S (stats) ╱ CTRL-D (delete)' \
    --preview-window 'down,60%' \
    --preview 'podman inspect {1} | jq -C '\''.[0] | {Status: .State.Status, Image: .ImageName, Name: .Name, Created: .Created, Command: .Config.Cmd, Ports: .NetworkSettings.Ports, Mounts: [.Mounts[].Destination]}'\''' \
    --bind 'alt-i:execute(podman inspect {1} | jq -C . | ${=PAGER:-less} -R > /dev/tty)' \
    --bind 'ctrl-s:execute(podman stats --no-stream {1} > /dev/tty; read -k 1)' \
    --bind 'ctrl-d:reload(podman rm {1} 2>&1; podman ps -a | sed 1d)' \
    | awk '{print $1}'))

  [ ${#containers[@]} -gt 0 ] && podman logs $follow_flag $lines_flag --color ${containers[@]}
}

#######################################
# fpst - View stats for podman containers
#
# Interactive selection of running containers with fzf (supports multiselect),
# then displays live statistics.
#
# Arguments:
#   query                 Optional fzf search query
#
# Outputs:
#   Interactive fzf selection, then displays container statistics
#######################################
function fpst() {
  _check_podman || return 1

  local query="$1"

  local containers
  containers=($(podman ps | sed 1d | fzf -m -q "$query" \
    --border-label '🐳 Running Containers' \
    --header 'TAB (select multiple) ╱ CTRL-L (logs) ╱ ALT-I (inspect) ╱ CTRL-D (delete)' \
    --preview-window 'down,60%' \
    --preview 'podman inspect {1} | jq -C '\''.[0] | {Status: .State.Status, Image: .ImageName, Name: .Name, Created: .Created, Command: .Config.Cmd, Ports: .NetworkSettings.Ports, Mounts: [.Mounts[].Destination]}'\''' \
    --bind 'ctrl-l:execute(podman logs --tail 50 --color {1} | ${=PAGER:-less} -R > /dev/tty)' \
    --bind 'alt-i:execute(podman inspect {1} | jq -C . | ${=PAGER:-less} -R > /dev/tty)' \
    --bind 'ctrl-d:reload(podman rm {1} 2>&1; podman ps | sed 1d)' \
    | awk '{print $1}'))

  [ ${#containers[@]} -gt 0 ] && podman stats ${containers[@]}
}

#######################################
# fprestart - Restart podman containers
#
# Interactive selection of containers with fzf (supports multiselect),
# then restarts the selected containers.
#
# Arguments:
#   query                 Optional fzf search query
#
# Outputs:
#   Interactive fzf selection, then restarts selected containers
#######################################
function fprestart() {
  _check_podman || return 1

  local query="$1"

  podman ps -a | sed 1d | fzf -m -q "$query" \
    --border-label '🐳 All Containers' \
    --header 'TAB (select multiple) ╱ CTRL-L (logs) ╱ ALT-I (inspect) ╱ CTRL-S (stats) ╱ CTRL-D (delete)' \
    --preview-window 'down,60%' \
    --preview 'podman inspect {1} | jq -C '\''.[0] | {Status: .State.Status, Image: .ImageName, Name: .Name, Created: .Created, Command: .Config.Cmd, Ports: .NetworkSettings.Ports, Mounts: [.Mounts[].Destination]}'\''' \
    --bind 'ctrl-l:execute(podman logs --tail 50 --color {1} | ${=PAGER:-less} -R > /dev/tty)' \
    --bind 'alt-i:execute(podman inspect {1} | jq -C . | ${=PAGER:-less} -R > /dev/tty)' \
    --bind 'ctrl-s:execute(podman stats --no-stream {1} > /dev/tty; read -k 1)' \
    --bind 'ctrl-d:reload(podman rm {1} 2>&1; podman ps -a | sed 1d)' \
    | awk '{print $1}' | xargs -r podman restart
}
