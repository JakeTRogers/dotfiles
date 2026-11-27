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
