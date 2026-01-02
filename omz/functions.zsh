# functions

#######################################
# update all mirrored puppet forge modules in the current directory
# Arguments:
#   None
# Outputs:
#   Writes the git fetch and push status to stdout
#######################################
function update_forge_modules () {
  for dir in $(ls -1); do
    echo $dir
    git -C "$dir" fetch -p origin
    git -C "$dir" push --mirror
    echo
    echo
  done
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
