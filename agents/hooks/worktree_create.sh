#!/usr/bin/env bash
# Claude Code WorktreeCreate hook: create the worktree at
# <repo root>/.worktrees/<name> on a new branch <name> from the current HEAD.
#
# Claude Code sends JSON on stdin with `cwd` and the worktree `name`, and reads
# the worktree's absolute path from the last non-empty line of stdout, so
# everything else goes to stderr. A non-zero exit fails the creation.
#   https://code.claude.com/docs/en/hooks#worktreecreate
#
# The new branch tracks the branch it started from, so `git rebase` in the
# worktree targets that branch, and worktree_remove.sh can tell whether the work
# has landed there.

set -euo pipefail
exec 3>&1 1>&2

die() { echo "worktree_create: ${1}"; exit 1; }

input="$(cat)"
name="$(jq -r '.name // empty' <<<"${input}")"
cwd="$(jq -r '.cwd // empty' <<<"${input}")"
cwd="${cwd:-${CLAUDE_PROJECT_DIR:-${PWD}}}"

[ -n "${name}" ] || die "no worktree name in the hook input"
git check-ref-format --branch "${name}" >/dev/null 2>&1 && [[ "${name}" != */* ]] ||
  die "'${name}' is not a valid worktree name"
git -C "${cwd}" rev-parse --is-inside-work-tree >/dev/null 2>&1 ||
  die "${cwd} is not inside a git work tree"

# The main worktree is listed first, so a worktree started from inside another
# worktree still lands under the main worktree's .worktrees/
root="$(git -C "${cwd}" worktree list --porcelain | sed -n '1s/^worktree //p')"
path="${root}/.worktrees/${name}"

git -C "${cwd}" show-ref --verify --quiet "refs/heads/${name}" &&
  die "branch ${name} already exists"
[ ! -e "${path}" ] || die "${path} already exists"

# Track the start branch when there is one; a detached HEAD has none
args=(-b "${name}")
start="$(git -C "${cwd}" symbolic-ref --quiet --short HEAD || true)"
if [ -n "${start}" ]; then
  args+=(--track)
else
  start=HEAD
fi
git -C "${cwd}" worktree add "${args[@]}" -- "${path}" "${start}" ||
  die "git worktree add failed for ${path}"

echo "${path}" >&3
