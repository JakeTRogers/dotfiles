#!/usr/bin/env bash

set -e

# Link the one instruction file to each agent's user-level instruction file,
# so every repo and Dev container gets the same rules.
#
# Claude Code reads ~/.claude/CLAUDE.md:
#   https://code.claude.com/docs/en/memory
# Copilot CLI reads $COPILOT_HOME/copilot-instructions.md, where COPILOT_HOME
# defaults to ~/.copilot:
#   https://docs.github.com/en/copilot/how-tos/copilot-cli/add-custom-instructions
#   https://docs.github.com/en/copilot/reference/copilot-cli-reference/cli-config-dir-reference
# VS Code Copilot reads ~/.copilot/copilot-instructions.md too, and
# ~/.claude/CLAUDE.md when chat.useClaudeMdFile is on:
#   https://code.visualstudio.com/docs/copilot/customization/custom-instructions
instructions="${DOTFILES_LOCATION}/agents/instructions.md"
targets=(
  "${HOME}/.claude/CLAUDE.md"
  "${COPILOT_HOME:-${HOME}/.copilot}/copilot-instructions.md"
)

# A symlink to an agents/instructions.md, dangling or not, is ours from an
# earlier run, perhaps from a Checkout that has since moved, and is re-pointed.
# Anything else already at a target, another symlink included, is the user's
# own and is kept, even a dangling one, such as a link into an unmounted share
for target in "${targets[@]}"; do
  if [ -L "${target}" ]; then
    current="$(readlink "${target}")"
    [ "${current}" = "${instructions}" ] && continue
    if [[ "${current}" != */agents/instructions.md ]]; then
      echo "⚠️ ${target} links to ${current}, not ${instructions}; leaving it alone"
      continue
    fi
  elif [ -e "${target}" ]; then
    echo "⚠️ ${target} exists and is not a symlink to ${instructions}; leaving it alone"
    continue
  fi
  mkdir -p "${target%/*}"
  ln -sfn "${instructions}" "${target}"
done

# Make Claude Code create its worktrees at <repo root>/.worktrees/<name>, on a
# new branch from the current HEAD. No setting moves them out of
# .claude/worktrees/, so WorktreeCreate and WorktreeRemove hooks replace its
# git logic; with a create hook, worktree.baseRef has no effect:
#   https://code.claude.com/docs/en/worktrees
#   https://code.claude.com/docs/en/hooks#worktreecreate
# Claude Code writes to its user settings too, so merge into the file and keep
# every other key, rather than link it.
settings="${HOME}/.claude/settings.json"
if ! command -v jq > /dev/null; then
  echo "⚠️ jq is missing; not adding the worktree hooks to ${settings}"
  exit 0
fi
if [ ! -s "${settings}" ]; then
  echo '{}' > "${settings}"
fi
if ! current="$(jq . "${settings}" 2> /dev/null)"; then
  echo "⚠️ ${settings} is not valid JSON; leaving it alone"
  exit 0
fi
# Each hook is replaced by its own entry, matched by script name, so a moved
# Checkout leaves no stale command behind. Other hooks are kept, even those
# that share an entry with a stale command; an entry left empty is dropped.
# @sh quotes each script path for the shell that runs the hook, apostrophes
# included.
merged="$(jq \
  --arg create "${DOTFILES_LOCATION}/agents/hooks/worktree_create.sh" \
  --arg remove "${DOTFILES_LOCATION}/agents/hooks/worktree_remove.sh" '
  def ours($event; $script): .hooks[$event] = [
    (.hooks[$event] // [])[]
    | if .hooks then
        .hooks |= map(select((.command // "") | test("/agents/hooks/worktree_(create|remove)\\.sh\\b") | not))
      else . end
    | select(.hooks != [])
  ] + [{hooks: [{type: "command", command: ($script | @sh)}]}];
  ours("WorktreeCreate"; $create)
  | ours("WorktreeRemove"; $remove)
  ' <<< "${current}")"
if [ "${merged}" != "${current}" ]; then
  # Write in place so a settings file that is itself a link stays one
  printf '%s\n' "${merged}" > "${settings}"
fi
