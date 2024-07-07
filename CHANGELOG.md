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
