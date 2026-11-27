# dotfiles

## Tools

- Tool scripts read three variables that `install.sh` exports: `DOTFILES_LOCATION` (repo path), `INSTALL_MODE` (`full`, or empty for Minimal mode) and `elevate` (`sudo`, or empty when root). Set all three to run one Tool: `DOTFILES_LOCATION="$PWD" INSTALL_MODE=full elevate=sudo ./bin/dotfiles <tool>`; the getRelease Tools (bat, fd, fzf, ripgrep) also need `~/.local/bin` on `PATH`, as `install.sh` sets, to find `getRelease`. Without `DOTFILES_LOCATION`, `bin/dotfiles` reports success and skips the Tool's own `install.sh` and `configure.sh`.
- To add a Tool: register it in `install.sh` (inside the `full` block for a Full mode Tool), map the directory to its command in `bin/dotfiles` when the names differ (`neovim` → `nvim`), and list it in `README.md`.
- Read `omz/README.md` before adding or changing an omz function, completion or alias: the `cheatsheet-audit` hook enforces its conventions.

## Checks

- `pre-commit run --all-files` runs every check, the same as the Lint workflow. It needs `zsh` installed.
- Run the Installer only in a throwaway container or VM, e.g. `podman run --rm -it -v "$PWD:/dotfiles:Z" -w /dotfiles ubuntu:26.04`, prepared with the bootstrap step in `.github/workflows/smoke.yml`. On a Workstation it runs sudo and rewrites config in the home directory. After `./install.sh`, verify the install with `sh bin/smoke_verify`, the same checks CI runs. To check one Tool's Configure step, run it with `HOME` set to a temp directory instead.
- The Workstation enforces SELinux: give every podman bind mount `:Z`, and when a script runs the container itself, wrap podman with `--security-opt label=disable`. Mount a fresh `git clone` instead of the Checkout when the image's git is older than 2.48, which rejects the Checkout's `extensions.relativeWorktrees`.
- Git hooks inherit `GIT_DIR`, `GIT_INDEX_FILE` and similar variables, so a test that a hook runs must `unset $(git rev-parse --local-env-vars)` before running git in a temp repo, or it acts on this repo instead.

## Commits

- Conventional Commits, checked by the commitizen `commit-msg` hook. The scope is the Tool (`fix(omz):`), or the area for files outside a Tool (`ci(hooks):`, `build(vscode):`).
- `CHANGELOG.md` and the version in `.cz.yaml` are written only by `cz bump`, which the maintainer runs. A PR with `feat` or `fix` commits fails the Version Bump Check until then.

## Agent skills

### Issue tracker

Issues and specs live in GitHub Issues, managed with the `gh` CLI. See `docs/agents/issue-tracker.md`.

### Triage labels

The five default labels: `needs-triage`, `needs-info`, `ready-for-agent`, `ready-for-human`, `wontfix`. See `docs/agents/triage-labels.md`.

### Domain docs

Terms such as Tool, Install mode and Workstation are defined in `GLOSSARY.md`, and decisions are recorded in `docs/adr/`, both at the repo root (single context). See `docs/agents/domain.md`.
