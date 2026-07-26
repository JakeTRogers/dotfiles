# Oh My Zsh Configuration

This directory contains the Zsh and Oh My Zsh configuration for the dotfiles repo.

## Cheatsheet

Press **`CTRL-G ?`** for a searchable picker covering every key binding, alias, and function
here — plus the tmux bindings from `tmux/tmux.conf` and its plugins — with a preview pane
showing full help for whichever entry is highlighted. Selecting a function or alias puts its
name on the command line; key bindings are listed to be pressed, not inserted.

Inside the picker: `ALT-A` folds in the ~330 aliases oh-my-zsh plugins provide, which are
hidden by default so they do not bury this config's own entries. `SHIFT-↑/↓` scrolls the
preview, `CTRL-/` resizes it, `CTRL-Y` copies the name.

This replaces the binding list fzf-git installs on the same chord, which showed only the
`CTRL-G` chords in a one-shot `zle -M` message area with no search and no detail. The other
fzf-git chords are untouched.

The same data is available as a static screen:

```zsh
cheat                 # everything, grouped and paged
cheat git             # one category
cheat tmux            # a category family: tmux, tmux-pane, tmux-tools, tmux-copy
cheat fixup           # anything matching a term
cheat --keys          # key bindings only, shell and tmux
cheat --fzf           # the picker, same as CTRL-G ?
cheat --audit         # report drift between this config and this README
```

Nothing is hand-maintained twice. `cheat` derives its entries from the sources that already
exist:

| Data | Source |
| ---- | ------ |
| Functions | The `# <name> - <description>` docstring header of each `functions/` file |
| Aliases | The `# description` comment on the line above each alias in `aliases.zsh` |
| Key bindings | A curated table in `functions/_cheat_data` — `bindkey -L` reports widget names, not meanings, and the in-picker bindings exist only inside `--header` strings in `fzf/fzf-git.sh` |
| tmux bindings | The same curated table, transcribed from `tmux list-keys` against `tmux/tmux.conf` so the plugin bindings (pain-control, yank, logging, resurrect, fingers) are included, not just the eleven written by hand |

Because of that, **a function without a conforming docstring header, or an alias without a
comment above it, silently vanishes from the cheatsheet**. The `cheatsheet-audit` pre-commit
hook (`bin/cheatsheet_audit`) fails the commit when that happens, and also when this README
names a function that no longer exists, omits one that does, or when a user command is defined
as a shell function in `omz/*.zsh` or `fzf/*.zsh` instead of `functions/`.

## Structure

### Core Configuration Files

- **`zshrc`** - Main Zsh configuration file, symlinked to `~/.zshrc`
- **`p10k.zsh`** - Powerlevel10k theme configuration, symlinked to `~/.p10k.zsh`
- **`variables.zsh`** - Shell variables, symlinked to `$ZSH_CUSTOM/variables.zsh`
- **`aliases.zsh`** - Shell aliases, symlinked to `$ZSH_CUSTOM/aliases.zsh`

### Notable Aliases

#### Kubernetes Aliases

| Alias | Description |
| ----- | ----------- |
| `k8b` | Pods not in Running or Succeeded state |
| `k8ef` | Events for FailedScheduling (unschedulable pods) |
| `k8ext` | Externally exposed services (LoadBalancer/NodePort) |
| `k8flap` | Pods with restarts > 0 (flapping containers) |
| `k8ing` | Ingress inventory |
| `k8ingr` | IngressRoute inventory (Traefik) |
| `k8nr` | Nodes not in Ready state |
| `k8sf` | Resources with stuck finalizers |
| `k8tc` | Pods sorted by CPU usage |
| `k8tm` | Pods sorted by memory usage |

### Directories

#### `functions/`

Individual function files that are autoloaded on-demand. Each file contains a single function. Files prefixed with `_` are internal helpers used by the other functions:

- **`ccm`** - Generate a commit message for staged changes with the `copilot` CLI, then commit with it
- **`cdr`** - Fuzzy-select a git repository under `~/gitrepos` and `cd` into it
- **`cheat`** - Searchable reference for every key binding, alias, and function below (see [Cheatsheet](#cheatsheet))
- **`copipe`** - Pipe stdin or a file to the `copilot` CLI with a prompt
- **`countdown`** - Timer countdown utility
- **`czbnt`** - `cz bump`, then strip the semver tag it leaves on HEAD
- **`decode_cert`** - Decode SSL/TLS certificates
- **`decode_jwt`** - Decode JWT tokens
- **`ff`** - Fuzzy-find a file and open it in `$EDITOR`
- **`fp`** - Podman fzf helpers dispatcher (`fpe`, `fpse`, `fpa`, `fpsa`, `fps`, `fprm`, `fprmi`, `fpl`, `fpst`, `fprestart`); run `fp help` for details
- **`gaf`** - Fuzzy-select changed files and `git add` them
- **`gcfuh`** - Interactively create fixup commits targeting the commits that last touched the changed lines
- **`gciaf`** - `git commit -a --fixup` for a commit
- **`gcif`** - `git commit --fixup` for a commit
- **`gcof`** - Fuzzy-select a ref and `git checkout` it
- **`gdu`** - `git diff` with 0 lines of context
- **`gdus`** - `git diff --cached` with 0 lines of context
- **`get_k8s_images`** - Extract container images from Kubernetes pods with filtering and parsing options
- **`ghist`** - Show commit history since the branch base
- **`git_delete_head_semver_tags`** - Delete local semver tags pointing at HEAD (e.g. the one `cz bump` creates)
- **`git_find_branch_base`** - Find the base branch name or merge-base commit (main/master/develop/...)
- **`git_pr_check`** - Check subdirectories for GitHub pull requests
- **`git_tag_semver`** - Semantically tag a git repository with major/minor/patch versions
- **`grias`** - `git rebase --interactive --autosquash` from the branch base
- **`gswt`** - Fuzzy-select a linked worktree and `cd` into it
- **`gundo`** - Undo the last commit (soft reset, keeps changes staged)
- **`install_it`** - Use Linux `install` to install binaries in `/usr/local/bin`
- **`install_kubectl`** - Install or upgrade kubectl to a specific version (checksum-verified)
- **`joincsv`** - Join two CSV files by their first column
- **`log_cmd`** - Command logging utility (default log: `~/command.log`, override with `CMD_LOG_FILE`)
- **`log_cmd_d`** - Command logging utility to a unique timestamped file under `$TMPDIR`
- **`pprint`** - Pretty print utility
- **`rgf`** - Fuzzy-find a file containing a pattern and open it at the match in `$EDITOR`
- **`update_git_mirrors_in_subdirs`** - Fetch and mirror-push every git repo in the current directory's subdirectories
- **`update_omz_all`** - Update oh-my-zsh itself plus all custom themes/plugins (`--dry-run` supported)

#### `completions/`

Zsh completion functions (prefixed with `_`) symlinked to `$ZSH_CUSTOM/completions/`.

Functions that take no arguments (`cdr`, `ff`, `gaf`, `gcof`, `gswt`, `gundo`,
`update_git_mirrors_in_subdirs`) share a single `_no_args` file, which suppresses the filename
completion zsh would otherwise offer. `countdown` (an integer) and `rgf` (a free-form regex)
have nothing worth completing and deliberately have no file.

Hand-written completions for the custom functions above: `_ccm`, `_cheat`, `_copipe`, `_czbnt`, `_decode_cert`, `_decode_jwt`, `_fp` (dispatcher), `_fpe` (also covers `fpse`), `_fpl`, `_fp_simple` (covers `fpa`, `fpsa`, `fps`, `fprm`, `fprmi`, `fpst`, `fprestart`), `_gcfuh`, `_gciaf`, `_gcif`, `_gdu`, `_gdus`, `_get_k8s_images`, `_ghist`, `_git_delete_head_semver_tags`, `_git_find_branch_base`, `_git_pr_check`, `_git_tag_semver`, `_grias`, `_install_it`, `_install_kubectl`, `_joincsv`, `_log_cmd` (also covers `log_cmd_d`), `_pprint`, `_update_omz_all`, plus the shared helpers `_commits_since_merge` and `_no_args`.

Generated/vendored completions: `_bat`, `_fd`, `_rg` (shipped by the upstream tools) and `_getRelease`, `_depflow`, `_dyff`, `_goDiffIt`, `_kustomize`, `_subnetCalc`, `_timeBuddy` (Cobra-generated for external CLIs).

#### `scripts/`

Standalone scripts for specific tasks:

- **`merge_kube_configs.zsh`** - Merge multiple kubeconfig files

## Sharp Edges

A few commands are deliberately powerful — know what they do before running them:

- **`gitrebaseall`** (alias) - rebases every local branch onto the default branch and **force-pushes each one** to origin
- **`update_git_mirrors_in_subdirs`** - runs `git push --mirror` in every subdirectory repo, which **deletes remote refs that don't exist locally**
- **`sssh` / `sscp`** (aliases) - ssh/scp with host-key checking disabled (`StrictHostKeyChecking=no`, throwaway known_hosts); convenient for ephemeral hosts, but offers no MITM protection
- **`ccm` / `copipe`** - send staged diffs / arbitrary input to GitHub Copilot, i.e. off the machine

## Adding New Functions

1. Create a new file in `functions/` with the function name
2. Give it a docstring header whose second line reads `# <name> - <one-line description>`;
   this is what `cheat` and the audit hook read
3. Add completion file to `completions/` prefixed with `_`, then re-run `configure.sh` to
   symlink it (the `functions/` directory is a single symlink and needs no re-run)
4. Add a bullet for it under [`functions/`](#functions) in this README
5. The function will be automatically available after reloading Zsh

Run `bin/cheatsheet_audit` to confirm steps 2 and 4 are satisfied; pre-commit runs it for you.
