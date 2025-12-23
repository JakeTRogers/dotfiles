## v2.10.1 (2025-12-22)

### Fix

- **omz**: add completion function for decode_jwt command
- **fzf**: update key bindings and completion functions for improved usability
- **git**: update templateDir path to use home directory shortcut
- **git**: update Python interpreter and add skip-on-missing-config option to pre-commit git templates
- **nvim**: update markdown.nvim version from 7.* to 8.*
- **nvim**: update nvim-surround version from 2.* to 3.*
- **nvim**: update gitsigns version from 0.* to 1.*
- **nvim**: update conform.nvim version from 8.* to 9.*
- **nvim**: enable line wrapping in Neovim configuration

## v2.10.0 (2025-12-16)

### Feature

- **omz**: enhance get_release file listing and integrate install_it

### Fix

- **omz**: correct get_release variable assignment for version option
- **omz**: install_it should remove source file after successful installation

## v2.9.0 (2025-12-15)

### Feature

- **omz**: add decode_jwt script to decode JWT w/ human readable timestamps

## v2.8.0 (2025-12-08)

### Feature

- **tmux**: add tmux-resurrect plugin for session management

## v2.7.0 (2025-05-26)

### Feature

- **omz**: add setup for custom scripts and symlink to ~/bin
- **script**: add script to merge multiple Kubernetes config files

## v2.6.3 (2025-05-18)

### Fix

- **nvim**: update nvim-lspconfig version to 2.* and adjust config syntax to support mason-lspconfig v2

## v2.6.2 (2025-05-10)

### Fix

- **nvim**: update mason.nvim to version 2.* and adjust dependencies

## v2.6.1 (2025-02-16)

### Fix

- **omz**: DISABLE_MAGIC_FUNCTIONS to address incompatibility with autocomplete plugin

## v2.6.0 (2025-02-06)

### Feature

- **omz**: add get_k8s_images function to retrieve images from a Kubernetes cluster

## v2.5.2 (2025-01-06)

### Fix

- **nvim**: expand ~/ home directory for obsidian project path

## v2.5.1 (2025-01-05)

### Fix

- **nvim**: add obsidian plugin
- **nvim**: realign keymappings and add icons to which-key
- **nvim**: add bullets plugin for markdown
- **nvim**: add render markdown to auto complete
- **nvim**: add keymap for next/prev git hunks
- **nvim**: add keymap for TodoFzfLua
- **nvim**: correct spelling vim options
- **nvim**: stop using system clipboard for default register

## v2.5.0 (2025-01-02)

### Feature

- **nvim**: add neovim w/ lazy.nvim plugin manager and a few dozen plugins
- **fzf**: add fzf for fuzzy file finding and git integration
- **rg**: add ripgrep for improved multi-threaded GNU grep alternative
- **fd**: add fd for improved GNU find alternative
- **bat**: add bat for cli syntax highlighting
- **omz**: add completion to zsh autosuggest strategy

### Fix

- update dotfiles install script to handle case where package != command name
- **tmux**: stop setting default-terminal and set terminal-features instead
- **hooks**: update shebang to /usr/bin/bash and remove skip-on-missing-config option in git templates

## v2.4.2 (2024-12-27)

### Refactor

- **omz**: improve omz configure.sh logic for managing zsh completions

## v2.4.1 (2024-12-27)

### Fix

- **omz**: remove set -e from omz configure.sh now that some commands are expected to return non-zero exit codes

## v2.4.0 (2024-12-27)

### Feature

- **omz**: manage zsh completions by removing dead symlinks and ensuring existing completions are symlinked
- **omz**: add zsh autocompletion for decode_cert, get_release, and install_it functions

### Fix

- **omz**: remove non-existent --help option from usage message

## v2.3.0 (2024-12-26)

### Feature

- add decode_cert funtion to parse certificates with certigo

## v2.2.1 (2024-12-24)

### Fix

- **omz**: properly nest archive error handling inside archive conditional and generalize file listing

## v2.2.0 (2024-12-22)

### Feature

- **omz**: add get_release function to download GitHub releases with option for listing available versions
- **omz**: add install_it function for installing executables from ~/install to /usr/local/bin using install command
- **omz**: add option to suppress trailing newline in output to pprint function
- **omz**: allow escape squences like new line in pprint message parameter

### Refactor

- **omz**: properly quote header variables
- **omz**: move function docs from comments to runtime help message for countdown, log_cmd, log_cmd_d, and pprint

## v2.1.0 (2024-12-17)

### Feature

- **omz**: move countdown, log_cmd, & pprint to autoload functions
- **omz**: add warp directory plugin
- **omz**: update zshrc to current template
- **omz**: add colors: purple, pink, orange, and grey

### Fix

- **omz**: rename git-pr-check, git-tag-semver, and install-kubectl with underscores per posix standard

### Refactor

- **omz**: replace git_pr_check echo commands using tput with pprint

## v2.0.0 (2024-12-15)

### BREAKING CHANGE

- remove unused getsudohash function

### Feature

- **omz**: remove getsudohash because it is only useful if all sudo files are identical
- **omz**: add function to install/upgrade kubectl
- **omz**: add countdown timer function
- **omz**: add pprint function that supports color and text styling

## v1.7.1 (2024-08-31)

### Fix

- **tmux**: bind home & end keys with correct escape sequence

## v1.7.0 (2024-07-07)

### Feature

- **powershell**: add basic Oh-My-Posh PowerShell profile for dev container usage

## v1.6.0 (2024-07-07)

### Feature

- **omz**: add log-cmd function to log the stderr and stdout of a command

### Refactor

- **omz**: order functions alphabetically

## v1.5.1 (2024-06-28)

### Fix

- **omz**: adjust repo detection logic and add color & emojis to git-pr-check function

## v1.5.0 (2024-06-28)

### Feature

- **omz**: add git-pr-check function to list GitHub pull requests in child directories

## v1.4.0 (2024-06-16)

### Feature

- **omz**: create git-tag-semver function to handle semantic versioning

### Fix

- **omz**: use zsh friendly argument handling for joincsv & getsudohash

## v1.3.1 (2024-03-10)

### Fix

- **tmux**: rebind fingers-jump-key to avoid conflict with pain-control

## v1.3.0 (2024-03-09)

### Feature

- **tmux**: add tmux-logging plugin
- **tmux**: add tmux-pain-control plugin and remove redundant bindings
- **tmux**: change horizontal split keybinding from | to +
- **tmux**: add keybinding to toggle pane input synchronization

## v1.2.1 (2024-03-09)

### Fix

- **tmux**: enforce emacs bindings

## v1.2.0 (2024-03-08)

### Feature

- **git**: add git hook templates for pre-push & prepare-commit-msg

### Fix

- **git**: add -nT flags to ln command to prevent creating recursive symlink
- **git**: remove recursive symlink

## v1.1.0 (2024-02-05)

### Feature

- **git**: add hook templates for pre-commit framework

### Fix

- make plugin install for omz, tmux, & vim idempotent
- **git**: remove .vscode from global git ignore

## v1.0.0 (2024-02-05)
