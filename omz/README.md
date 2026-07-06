# Oh My Zsh Configuration

This directory contains the Zsh and Oh My Zsh configuration for the dotfiles repo.

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
- **`copipe`** - Pipe stdin or a file to the `copilot` CLI with a prompt
- **`countdown`** - Timer countdown utility
- **`czbnt`** - `cz bump`, then strip the semver tag it leaves on HEAD
- **`decode_cert`** - Decode SSL/TLS certificates
- **`decode_jwt`** - Decode JWT tokens
- **`ff`** - Fuzzy-find a file and open it in `$EDITOR`
- **`fp`** - Podman fzf helpers dispatcher (`fpe`, `fpse`, `fpa`, `fpsa`, `fps`, `fprm`, `fprmi`, `fpl`, `fpst`, `fprestart`); run `fp help` for details
- **`gcfuh`** - Interactively create fixup commits targeting the commits that last touched the changed lines
- **`gciaf`** - `git commit -a --fixup` for a commit
- **`gcif`** - `git commit --fixup` for a commit
- **`gdu`** - `git diff` with 0 lines of context
- **`gdus`** - `git diff --cached` with 0 lines of context
- **`get_k8s_images`** - Extract container images from Kubernetes pods with filtering and parsing options
- **`ghist`** - Show commit history since the branch base
- **`git_delete_head_semver_tags`** - Delete local semver tags pointing at HEAD (e.g. the one `cz bump` creates)
- **`git_find_branch_base`** - Find the base branch name or merge-base commit (main/master/develop/...)
- **`git_pr_check`** - Check subdirectories for GitHub pull requests
- **`git_tag_semver`** - Semantically tag a git repository with major/minor/patch versions
- **`grias`** - `git rebase --interactive --autosquash` from the branch base
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

Hand-written completions for the custom functions above: `_ccm`, `_copipe`, `_czbnt`, `_decode_cert`, `_decode_jwt`, `_fp` (dispatcher), `_fpe` (also covers `fpse`), `_fpl`, `_fp_simple` (covers `fpa`, `fpsa`, `fps`, `fprm`, `fprmi`, `fpst`, `fprestart`), `_gcfuh`, `_gciaf`, `_gcif`, `_gdu`, `_gdus`, `_get_k8s_images`, `_ghist`, `_git_delete_head_semver_tags`, `_git_pr_check`, `_git_tag_semver`, `_grias`, `_install_it`, `_update_omz_all`, plus the shared helper `_commits_since_merge`.

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
2. Add completion file to `completions/` prefixed with `_`
3. The function will be automatically available after reloading Zsh
