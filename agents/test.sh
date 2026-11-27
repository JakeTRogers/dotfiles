#!/usr/bin/env bash
# Check the agents Tool's Claude Code worktree hooks, its Configure step and
# its bin/dotfiles run. Pre-commit does not run this; run it by hand from the
# Checkout after changing agents/ or bin/dotfiles:
#
#   agents/test.sh
#
# Pipes the JSON Claude Code sends into each hook, in throwaway repos, and runs
# the Configure step against a throwaway HOME. Needs git and jq.

set -euo pipefail

# A git hook runs with GIT_DIR, GIT_INDEX_FILE and the like set for the repo
# being committed to. Drop them, or every git command below acts on that repo.
# shellcheck disable=SC2046
unset $(git rev-parse --local-env-vars)

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
create="${here}/hooks/worktree_create.sh"
remove="${here}/hooks/worktree_remove.sh"

work="$(mktemp -d)"
trap 'rm -rf -- "${work}"' EXIT
# Resolve symlinks such as macOS's /tmp so paths compare equal to git's
work="$(cd "${work}" && pwd -P)"

# Isolate git from the caller's config, hooks and templates, but keep the
# Shared Git config's relative worktree paths, which the hooks must honour
export GIT_CONFIG_NOSYSTEM=1 GIT_CONFIG_GLOBAL="${work}/gitconfig"
git config --global worktree.useRelativePaths true
git config --global user.name test
git config --global user.email test@example.invalid
git config --global init.defaultBranch main

failures=0
fail() { echo "🔴 ${1}"; failures=$((failures + 1)); }
pass() { echo "🟢 ${1}"; }

new_repo() {
  local repo="${work}/${1}"
  git init -q --template= "${repo}"
  git -C "${repo}" commit -q --allow-empty -m init
  echo "${repo}"
}

# create_input CWD NAME prints the WorktreeCreate input Claude Code sends
create_input() {
  jq -n --arg cwd "${1}" --arg name "${2}" \
    '{session_id: "s", transcript_path: "/t.jsonl", cwd: $cwd, hook_event_name: "WorktreeCreate", name: $name}'
}

# remove_input CWD PATH prints the WorktreeRemove input Claude Code sends
remove_input() {
  jq -n --arg cwd "${1}" --arg path "${2}" \
    '{session_id: "s", transcript_path: "/t.jsonl", cwd: $cwd, hook_event_name: "WorktreeRemove", worktree_path: $path}'
}

###
# WorktreeCreate
###
repo="$(new_repo create)"
git -C "${repo}" switch -q -c feature
git -C "${repo}" commit -q --allow-empty -m 'feature work'
mkdir "${repo}/sub"
if out="$(create_input "${repo}/sub" bold-oak | "${create}" 2>"${work}/err")"; then
  path="$(printf '%s\n' "${out}" | sed '/^$/d' | tail -n 1)"
  if [ "${path}" != "${repo}/.worktrees/bold-oak" ]; then
    fail "create printed '${path}', not ${repo}/.worktrees/bold-oak"
  elif [ "$(git -C "${path}" branch --show-current)" != bold-oak ]; then
    fail "create did not check out a new bold-oak branch"
  elif [ "$(git -C "${path}" rev-parse HEAD)" != "$(git -C "${repo}" rev-parse feature)" ]; then
    fail "create did not branch from the current HEAD"
  elif [ "$(cat "${path}/.git")" != 'gitdir: ../../.git/worktrees/bold-oak' ]; then
    fail "create ignored worktree.useRelativePaths: $(cat "${path}/.git")"
  elif [ "$(printf '%s\n' "${out}" | sed '/^$/d' | wc -l)" -ne 1 ]; then
    fail "create printed more than the path on stdout: ${out}"
  else
    pass "create makes <repo root>/.worktrees/<name> on a new branch from HEAD"
  fi
else
  fail "create failed: $(cat "${work}/err")"
fi

# expect_create_fails WHAT CWD NAME PATTERN: create exits non-zero, prints
# nothing on stdout, and names the problem on stderr
expect_create_fails() {
  local out status=0
  out="$(create_input "${2}" "${3}" | "${create}" 2>"${work}/err")" || status=$?
  if [ "${status}" -eq 0 ]; then
    fail "create succeeded ${1}"
  elif [ -n "${out}" ]; then
    fail "create printed '${out}' on stdout ${1}"
  elif ! grep -q -- "${4}" "${work}/err"; then
    fail "create's stderr ${1} does not mention '${4}': $(cat "${work}/err")"
  else
    pass "create fails ${1}: $(cat "${work}/err")"
  fi
}

expect_create_fails "when the branch exists" "${repo}" feature 'branch feature already exists'
mkdir -p "${repo}/.worktrees/taken"
expect_create_fails "when the path exists" "${repo}" taken "${repo}/.worktrees/taken already exists"
mkdir "${work}/plain"
expect_create_fails "outside a git repo" "${work}/plain" anywhere 'not inside a git work tree'
expect_create_fails "for a name with a slash" "${repo}" ../escape 'not a valid worktree name'

###
# WorktreeRemove
###
# made_worktree NAME: create a worktree through the hook and print its path
made_worktree() {
  create_input "${repo}" "${1}" | "${create}" 2>/dev/null | tail -n 1
}

# A branch whose commits landed on its start branch is deleted
path="$(made_worktree landed)"
git -C "${path}" commit -q --allow-empty -m 'landed work'
git -C "${repo}" merge -q --ff-only landed
if ! remove_input "${path}" "${path}" | "${remove}" 2>"${work}/err"; then
  fail "remove failed for a landed branch: $(cat "${work}/err")"
elif [ -e "${path}" ]; then
  fail "remove left ${path} behind"
elif git -C "${repo}" show-ref --verify --quiet refs/heads/landed; then
  fail "remove kept the landed branch"
else
  pass "remove deletes the worktree and its landed branch"
fi

# A branch with commits its start branch lacks is kept and reported, even when
# it was merged into some other branch
path="$(made_worktree unlanded)"
git -C "${path}" commit -q --allow-empty -m 'unlanded work'
git -C "${repo}" branch -q elsewhere unlanded
if ! remove_input "${repo}" "${path}" | "${remove}" 2>"${work}/err"; then
  fail "remove failed for an unlanded branch: $(cat "${work}/err")"
elif [ -e "${path}" ]; then
  fail "remove left ${path} behind"
elif ! git -C "${repo}" show-ref --verify --quiet refs/heads/unlanded; then
  fail "remove deleted the unlanded branch"
elif ! grep -q 'kept branch unlanded' "${work}/err"; then
  fail "remove did not report the kept branch: $(cat "${work}/err")"
else
  pass "remove keeps and reports an unlanded branch: $(cat "${work}/err")"
fi

# A worktree with uncommitted or untracked changes is kept, with its branch
for change in uncommitted untracked; do
  path="$(made_worktree "${change}")"
  git -C "${path}" commit -q --allow-empty -m "${change} work"
  git -C "${repo}" merge -q --ff-only "${change}"
  echo "${change}" >"${path}/${change}.txt"
  if [ "${change}" = uncommitted ]; then
    git -C "${path}" add "${change}.txt"
  fi
  if remove_input "${repo}" "${path}" | "${remove}" 2>"${work}/err"; then
    fail "remove succeeded for a worktree with ${change} changes"
  elif [ ! -f "${path}/${change}.txt" ]; then
    fail "remove discarded the ${change} changes in ${path}"
  elif ! git -C "${repo}" show-ref --verify --quiet "refs/heads/${change}"; then
    fail "remove deleted the branch of a worktree with ${change} changes"
  elif ! grep -q "kept ${path} and branch ${change}" "${work}/err"; then
    fail "remove did not name the kept worktree: $(cat "${work}/err")"
  else
    pass "remove keeps a worktree with ${change} changes: $(cat "${work}/err")"
  fi
done

# A worktree started from a detached HEAD has no start branch to land on
git -C "${repo}" switch -q --detach
path="$(made_worktree detached)"
git -C "${repo}" switch -q feature
if ! remove_input "${repo}" "${path}" | "${remove}" 2>"${work}/err"; then
  fail "remove failed for a detached start: $(cat "${work}/err")"
elif [ -e "${path}" ] || ! git -C "${repo}" show-ref --verify --quiet refs/heads/detached; then
  fail "remove did not remove the worktree and keep the branch of a detached start"
else
  pass "remove keeps the branch of a worktree started from a detached HEAD"
fi

###
# Configure step: link the instruction file
###
configure() {
  HOME="${work}/home" DOTFILES_LOCATION="${here%/*}" COPILOT_HOME='' "${here}/configure.sh"
}
instructions="${here}/instructions.md"
claude_md="${work}/home/.claude/CLAUDE.md"
copilot_md="${work}/home/.copilot/copilot-instructions.md"

# No targets yet: both links are made, parent directories included, and a
# second run changes nothing and warns of nothing
for run in first second; do
  if ! configure >"${work}/out" 2>&1; then
    fail "Configure step failed on the ${run} link run: $(cat "${work}/out")"
  elif [ "$(readlink "${claude_md}")" != "${instructions}" ] ||
    [ "$(readlink "${copilot_md}")" != "${instructions}" ]; then
    fail "Configure step did not link both targets on the ${run} run"
  elif grep -q '⚠️' "${work}/out"; then
    fail "Configure step warned on the ${run} link run: $(cat "${work}/out")"
  else
    pass "Configure step links both targets on the ${run} run"
  fi
done

# Anything else at a target, a regular file or another symlink, is kept with
# a warning that names it
rm -f -- "${claude_md}" "${copilot_md}"
echo mine >"${claude_md}"
echo theirs >"${work}/elsewhere.md"
ln -s "${work}/elsewhere.md" "${copilot_md}"
if ! configure >"${work}/out" 2>&1; then
  fail "Configure step failed with existing targets: $(cat "${work}/out")"
elif [ -L "${claude_md}" ] || [ "$(cat "${claude_md}")" != mine ]; then
  fail "Configure step replaced a regular file at ${claude_md}"
elif [ "$(readlink "${copilot_md}")" != "${work}/elsewhere.md" ]; then
  fail "Configure step replaced another symlink at ${copilot_md}"
elif ! grep -q "⚠️ ${claude_md} exists" "${work}/out" ||
  ! grep -q "⚠️ ${copilot_md} links to" "${work}/out"; then
  fail "Configure step did not warn about both kept targets: $(cat "${work}/out")"
else
  pass "Configure step keeps a regular file and another symlink, with warnings"
fi
rm -f -- "${claude_md}" "${copilot_md}"

# A dangling symlink elsewhere, such as into an unmounted share, is the user's
# too: kept with a warning, not taken for a stale link of ours
ln -s "${work}/unmounted/rules.md" "${claude_md}"
if ! configure >"${work}/out" 2>&1; then
  fail "Configure step failed with a dangling link: $(cat "${work}/out")"
elif [ "$(readlink "${claude_md}")" != "${work}/unmounted/rules.md" ]; then
  fail "Configure step replaced a dangling link to elsewhere at ${claude_md}"
elif ! grep -q "⚠️ ${claude_md} links to" "${work}/out"; then
  fail "Configure step did not warn about a kept dangling link: $(cat "${work}/out")"
else
  pass "Configure step keeps a dangling link to elsewhere, with a warning"
fi
rm -f -- "${claude_md}" "${copilot_md}"

# A link from an earlier run, to a Checkout that has moved (dangling) or to
# another Checkout's instructions, is re-pointed without a warning
mkdir -p "${work}/other/agents"
echo old >"${work}/other/agents/instructions.md"
ln -s "${work}/moved/agents/instructions.md" "${claude_md}"
ln -s "${work}/other/agents/instructions.md" "${copilot_md}"
if ! configure >"${work}/out" 2>&1; then
  fail "Configure step failed with stale links: $(cat "${work}/out")"
elif [ "$(readlink "${claude_md}")" != "${instructions}" ] ||
  [ "$(readlink "${copilot_md}")" != "${instructions}" ]; then
  fail "Configure step did not re-point stale links"
elif grep -q '⚠️' "${work}/out"; then
  fail "Configure step warned about its own stale links: $(cat "${work}/out")"
else
  pass "Configure step re-points its links from a moved or other Checkout"
fi
rm -f -- "${claude_md}" "${copilot_md}"

###
# Configure step: merge the hooks into Claude Code's user settings
###
mkdir -p "${work}/home/.claude"
cat >"${work}/home/.claude/settings.json" <<'EOF'
{
  "model": "opus",
  "permissions": {"allow": ["Bash(git status)"]},
  "hooks": {
    "PreToolUse": [{"matcher": "Bash", "hooks": [{"type": "command", "command": "echo pre"}]}],
    "WorktreeRemove": [
      {"hooks": [{"type": "command", "command": "'/old/checkout/agents/hooks/worktree_remove.sh'"}]},
      {"hooks": [{"type": "command", "command": "'/older/checkout/agents/hooks/worktree_remove.sh'"}, {"type": "command", "command": "echo cleanup"}]}
    ]
  },
  "attribution": {"commit": "Co-Authored-By: Claude"},
  "worktree": {"baseRef": "fresh", "symlinkDirectories": ["node_modules"]}
}
EOF
# The expected result, written out by hand: other keys kept, including
# worktree.baseRef, a stale entry from an old Checkout path replaced, and
# commit and PR attribution turned off
create_cmd="'${here}/hooks/worktree_create.sh'"
remove_cmd="'${here}/hooks/worktree_remove.sh'"
expected="$(jq -S . <<EOF
{
  "model": "opus",
  "permissions": {"allow": ["Bash(git status)"]},
  "hooks": {
    "PreToolUse": [{"matcher": "Bash", "hooks": [{"type": "command", "command": "echo pre"}]}],
    "WorktreeCreate": [{"hooks": [{"type": "command", "command": "${create_cmd}"}]}],
    "WorktreeRemove": [
      {"hooks": [{"type": "command", "command": "echo cleanup"}]},
      {"hooks": [{"type": "command", "command": "${remove_cmd}"}]}
    ]
  },
  "attribution": {"commit": "", "pr": ""},
  "worktree": {"baseRef": "fresh", "symlinkDirectories": ["node_modules"]}
}
EOF
)"
for run in first second; do
  if ! configure >"${work}/out" 2>&1; then
    fail "Configure step failed on the ${run} run: $(cat "${work}/out")"
  elif [ "$(jq -S . "${work}/home/.claude/settings.json")" != "${expected}" ]; then
    fail "settings after the ${run} run: $(cat "${work}/home/.claude/settings.json")"
  else
    pass "Configure step merges the settings on the ${run} run"
  fi
done

# A Checkout path with an apostrophe still gives each hook a command the shell
# reads back as that one path
quoted_home="${work}/quoted_home"
quoted_checkout="${work}/Jake's dotfiles"
if HOME="${quoted_home}" DOTFILES_LOCATION="${quoted_checkout}" COPILOT_HOME='' \
  "${here}/configure.sh" >"${work}/out" 2>&1; then
  quoted_ok=1
  for hook in create remove; do
    event="Worktree${hook^}"
    command="$(jq -r --arg event "${event}" '.hooks[$event][0].hooks[0].command' "${quoted_home}/.claude/settings.json")"
    words="$(eval "set -- ${command}" && printf '%s\n' "$#" "$1")" || words=''
    if [ "${words}" != "$(printf '1\n%s' "${quoted_checkout}/agents/hooks/worktree_${hook}.sh")" ]; then
      fail "${event} command for a path with an apostrophe does not parse back: ${command}"
      quoted_ok=0
    fi
  done
  [ "${quoted_ok}" -eq 1 ] && pass "Configure step shell-quotes a Checkout path with an apostrophe"
else
  fail "Configure step failed for a Checkout path with an apostrophe: $(cat "${work}/out")"
fi

# No settings file yet: the Configure step creates one
rm "${work}/home/.claude/settings.json"
if configure >"${work}/out" 2>&1 &&
  [ "$(jq -c '[.worktree, (.hooks | keys), .attribution]' "${work}/home/.claude/settings.json")" = '[null,["WorktreeCreate","WorktreeRemove"],{"commit":"","pr":""}]' ]; then
  pass "Configure step creates a missing settings file"
else
  fail "Configure step did not create the settings file: $(cat "${work}/out")"
fi

# Settings that are not valid JSON are left alone with a warning
printf '{ "model": ' >"${work}/home/.claude/settings.json"
if configure >"${work}/out" 2>&1 && grep -q '⚠️' "${work}/out" &&
  [ "$(cat "${work}/home/.claude/settings.json")" = '{ "model": ' ]; then
  pass "Configure step leaves invalid settings alone: $(grep '⚠️' "${work}/out")"
else
  fail "Configure step on invalid settings: $(cat "${work}/out")"
fi

###
# bin/dotfiles agents: no Install step, so no package manager and no ⚪ line
###
# elevate prefixes every package manager command, so this stub records any
cat >"${work}/elevate" <<EOF
#!/bin/sh
echo "\$*" >>"${work}/elevated"
EOF
chmod +x "${work}/elevate"
if ! HOME="${work}/dotfiles_home" DOTFILES_LOCATION="${here%/*}" INSTALL_MODE='' elevate="${work}/elevate" COPILOT_HOME='' \
  "${here%/*}/bin/dotfiles" agents >"${work}/out" 2>&1; then
  fail "bin/dotfiles agents failed: $(cat "${work}/out")"
elif [ -e "${work}/elevated" ]; then
  fail "bin/dotfiles agents ran the package manager: $(cat "${work}/elevated")"
elif grep -q '⚪' "${work}/out"; then
  fail "bin/dotfiles agents printed an Install step: $(cat "${work}/out")"
elif ! grep -qx '🔵 Configuring agents' "${work}/out" || [ ! -L "${work}/dotfiles_home/.claude/CLAUDE.md" ]; then
  fail "bin/dotfiles agents did not run the Configure step: $(cat "${work}/out")"
else
  pass "bin/dotfiles agents runs only the Configure step"
fi

if [ "${failures}" -ne 0 ]; then
  echo "🔴 ${failures} check(s) failed"
  exit 1
fi
echo "🟢 all agents checks passed"
