#!/usr/bin/env bash
# Check that a gitstatusd binary reads repos that use relative worktrees.
#
#   omz/gitstatusd/test.sh GITSTATUSD
#
# Builds a repo with a linked worktree in git's relative-path form
# (extensions.relativeWorktrees), then asks GITSTATUSD for the branch from the
# main checkout and from inside the worktree, the way powerlevel10k does. The
# form is written by hand so the test does not depend on the git version.

set -euo pipefail

gitstatusd="${1:?usage: test.sh GITSTATUSD}"
[[ -x "${gitstatusd}" ]] || { echo "🔴 not executable: ${gitstatusd}"; exit 1; }

work="$(mktemp -d)"
trap 'rm -rf -- "${work}"' EXIT

# isolate git from the caller's config, hooks and templates
export GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_NOSYSTEM=1
repo="${work}/repo"
git init -q --template= -b main "${repo}"
git -C "${repo}" -c user.name=test -c user.email=test@example.invalid \
  commit -q --allow-empty -m init
git -C "${repo}" worktree add -q -b feature "${repo}/.worktrees/feature"

# convert the worktree links to relative paths, as worktree.useRelativePaths does
git -C "${repo}" config core.repositoryformatversion 1
git -C "${repo}" config extensions.relativeWorktrees true
printf 'gitdir: ../../.git/worktrees/feature\n' > "${repo}/.worktrees/feature/.git"
printf '../../../.worktrees/feature/.git\n' > "${repo}/.git/worktrees/feature/gitdir"

version="$("${gitstatusd}" --version)"
failed=0

# expect_branch DIR BRANCH: query DIR with -G set as powerlevel10k sets it
expect_branch() {
  local reply branch
  reply="$(printf 'id\037%s\0371\036' "$1" | timeout 5 "${gitstatusd}" -G "${version}" 2> /dev/null || true)"
  # reply fields: id, is-repo flag, workdir, commit, local branch, ...
  branch="$(printf '%s' "${reply}" | awk -F '\037' '$2 == "1" { print $5 }' RS='\036')"
  if [[ "${branch}" == "$2" ]]; then
    echo "🟢 ${1#"${work}/"}: ${branch}"
  else
    echo "🔴 ${1#"${work}/"}: expected branch $2, got '${branch}'"
    failed=1
  fi
}

expect_branch "${repo}" main
expect_branch "${repo}/.worktrees/feature" feature
exit "${failed}"
