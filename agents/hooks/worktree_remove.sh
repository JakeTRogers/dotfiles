#!/usr/bin/env bash
# Claude Code WorktreeRemove hook: remove a worktree that worktree_create.sh
# made, and delete its branch once the work has landed.
#
# Claude Code sends JSON on stdin with the `worktree_path` to remove. It does
# not fall back to git, and it never deletes the branch of a hook-created
# worktree, so both are done here. Removal fails if the directory still exists
# after a non-zero exit.
#   https://code.claude.com/docs/en/hooks#worktreeremove
#
# A worktree with uncommitted or untracked changes is kept, with its branch, and
# named on stderr. Otherwise the branch is deleted only when it is merged into
# the branch it started from, which worktree_create.sh set as its upstream, and
# is kept and named on stderr when it is not, so no work is lost.

set -euo pipefail
exec 1>&2

die() { echo "worktree_remove: ${1}"; exit 1; }

path="$(jq -r '.worktree_path // empty')"
[ -n "${path}" ] || die "no worktree_path in the hook input"
[ -d "${path}" ] || { echo "worktree_remove: ${path} is already gone"; exit 0; }

# Refuse anything but the top of a linked worktree, such as a plain directory
# inside some other repo
top="$(git -C "${path}" rev-parse --show-toplevel 2>/dev/null)" &&
  [ "$(cd "${top}" && pwd -P)" = "$(cd "${path}" && pwd -P)" ] &&
  [ "$(git -C "${path}" rev-parse --git-dir)" != "$(git -C "${path}" rev-parse --git-common-dir)" ] ||
  die "${path} is not a linked git worktree; leaving it alone"

# Run git from the main worktree, since this worktree is about to go
root="$(git -C "${path}" worktree list --porcelain | sed -n '1s/^worktree //p')"
branch="$(git -C "${path}" symbolic-ref --quiet --short HEAD || true)"
start=''
if [ -n "${branch}" ]; then
  start="$(git -C "${root}" rev-parse --quiet --abbrev-ref "${branch}@{upstream}" 2>/dev/null || true)"
fi

if [ -n "$(git -C "${path}" status --porcelain)" ]; then
  die "kept ${path}${branch:+ and branch ${branch}}: it has uncommitted or untracked changes"
fi
git -C "${root}" worktree remove -- "${path}" ||
  die "git worktree remove failed for ${path}"

if [ -z "${branch}" ]; then
  exit 0
elif [ -n "${start}" ] && git -C "${root}" merge-base --is-ancestor "${branch}" "${start}"; then
  git -C "${root}" branch -D -- "${branch}" ||
    echo "worktree_remove: kept branch ${branch}: git could not delete it"
elif [ -n "${start}" ]; then
  echo "worktree_remove: kept branch ${branch}: it has commits that ${start} lacks"
else
  echo "worktree_remove: kept branch ${branch}: it has no start branch to compare with"
fi
