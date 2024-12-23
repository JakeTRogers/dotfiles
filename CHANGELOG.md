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
