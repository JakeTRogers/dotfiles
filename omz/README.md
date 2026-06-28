# Oh My Zsh Configuration

This directory contains the Zsh and Oh My Zsh configuration for the dotfiles repo.

## Structure

### Core Configuration Files

- **`zshrc`** - Main Zsh configuration file, symlinked to `~/.zshrc`
- **`p10k.zsh`** - Powerlevel10k theme configuration, symlinked to `~/.p10k.zsh`
- **`env.zsh`** - Environment setup, symlinked to `$ZSH_CUSTOM/env.zsh`
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

Individual function files that are autoloaded on-demand. Each file contains a single function:

- **`cdr`** - Fuzzy-select a git repository under `~/gitrepos` and `cd` into it
- **`countdown`** - Timer countdown utility
- **`czbnt`** - `cz bump`, then strip the semver tag it leaves on HEAD
- **`decode_cert`** - Decode SSL/TLS certificates
- **`decode_jwt`** - Decode JWT tokens
- **`ff`** - Fuzzy-find a file and open it in `$EDITOR`
- **`fp`** - Podman fzf helpers dispatcher (`fpe`, `fpse`, `fpa`, `fpsa`, `fps`, `fprm`, `fprmi`, `fpl`, `fpst`, `fprestart`); run `fp help` for details
- **`gciaf`** - `git commit -a --fixup` for a commit
- **`gcif`** - `git commit --fixup` for a commit
- **`gdu`** - `git diff` with 0 lines of context
- **`gdus`** - `git diff --cached` with 0 lines of context
- **`get_k8s_images`** - Extract container images from Kubernetes pods with filtering and parsing options
- **`git_delete_head_semver_tags`** - Delete local semver tags pointing at HEAD (e.g. the one `cz bump` creates)
- **`git_find_branch_base`** - Find the base branch name or merge-base commit (main/master/develop/...)
- **`git_pr_check`** - Check subdirectories for GitHub pull requests
- **`git_tag_semver`** - Semantically tag a git repository with major/minor/patch versions
- **`grias`** - `git rebase --interactive --autosquash` from the branch base
- **`gundo`** - Undo the last commit (soft reset, keeps changes staged)
- **`install_it`** - Use Linux `install` to install binaries in `/usr/local/bin`
- **`install_kubectl`** - Install or upgrade kubectl to a specific version
- **`joincsv`** - Join two CSV files by their first column
- **`log_cmd`** - Command logging utility
- **`log_cmd_d`** - Command logging utility to default path: `/tmp/cmd-$(date).log`
- **`pprint`** - Pretty print utility
- **`rgf`** - Fuzzy-find a file containing a pattern and open it at the match in `$EDITOR`
- **`update_git_mirrors_in_subdirs`** - Fetch and mirror-push every git repo in the current directory's subdirectories

#### `completions/`

Zsh completion functions (prefixed with `_`) symlinked to `$ZSH_CUSTOM/completions/`:

- **`_czbnt`** - Completion for czbnt function
- **`_decode_cert`** - Completion for decode_cert function
- **`_decode_jwt`** - Completion for decode_jwt function
- **`_git_delete_head_semver_tags`** - Completion for git_delete_head_semver_tags function
- **`_fzf`** - FZF completion
- **`_getRelease`** - Completion for getRelease CLI
- **`_install_it`** - Completion for install_it function

#### `scripts/`

Standalone scripts for specific tasks:

- **`merge_kube_configs.zsh`** - Merge multiple kubeconfig files

## Adding New Functions

1. Create a new file in `functions/` with the function name
2. Add completion file to `completions/` prefixed with `_`
3. The function will be automatically available after reloading Zsh
