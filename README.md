# dotfiles

This repo manages my dotfiles and works nicely with the VS Code Dev Containers extension. It handles the installation and, where applicable, configuration of:

- [Curl](https://github.com/curl/curl)
- [Git](https://git-scm.com/)
  - [gitconfig](https://git-scm.com/book/en/v2/Customizing-Git-Git-Configuration) - shared settings, linked to `~/.config/git/config`; your identity lives in a per-machine `~/.gitconfig` (see [Git identity](#git-identity))
  - [.gitignore_global](https://git-scm.com/docs/gitignore)
  - [pre-commit hooks template](https://pre-commit.com/) - copied into new repositories so repo-local hook installs cannot modify the shared template
- [GnuPG](https://gnupg.org/)
  - [gpg-agent.conf](https://gnupg.org/documentation/manuals/gnupg/Invoking-GPG_002dAGENT.html)
- [Less](https://github.com/gwsw/less)
- [Vim](https://www.vim.org/) - configured in Full mode only; Minimal mode installs the package without configuration
  - [.vimrc](https://github.com/vim/vim/blob/master/runtime/vimrc_example.vim)
  - [Pathogen Plugin Manager](https://github.com/tpope/vim-pathogen) - pathogen and all plugins are pinned to specific commits to reduce supply chain risk; plugins no longer listed in [vim/configure.sh](vim/configure.sh) are automatically removed
    - [ctrlp.vim](https://github.com/ctrlpvim/ctrlp.vim)
    - [nerdtree](https://github.com/preservim/nerdtree)
    - [numbers.vim](https://github.com/myusuf3/numbers.vim)
    - [tabular](https://github.com/godlygeek/tabular)
    - [tlib_vim](https://github.com/tomtom/tlib_vim)
    - [vim-airline-themes](https://github.com/vim-airline/vim-airline-themes)
    - [vim-airline](https://github.com/vim-airline/vim-airline)
    - [vim-colors-solarized](https://github.com/altercation/vim-colors-solarized)
    - [vim-polyglot](https://github.com/sheerun/vim-polyglot)
    - [vim-surround](https://github.com/tpope/vim-surround)
- [zsh](https://www.zsh.org/)
  - [zshrc](https://github.com/ohmyzsh/ohmyzsh/blob/master/templates/zshrc.zsh-template)
  - [Oh My Zsh](https://ohmyz.sh/)
    - [powerlevel10k](https://github.com/romkatv/powerlevel10k)
      - Patched gitstatusd that reads repos with relative worktrees, on x86_64 (see [omz/gitstatusd/](omz/gitstatusd/))
    - [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions)
    - [zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting)
    - Built-in plugins: colored-man-pages, colorize, gh, git, gpg-agent, kubectl, ssh-agent (loaded only when there is a forwarded agent or a `~/.ssh` directory), tmux (loaded only when tmux is installed), wd
    - Custom functions and completions (see [omz/](omz/))
- [bat](https://github.com/sharkdp/bat) - A cat clone with syntax highlighting
  - Custom Tokyo Night theme
- [fd](https://github.com/sharkdp/fd) - A simple, fast and user-friendly alternative to find
- [fzf](https://github.com/junegunn/fzf) - A command-line fuzzy finder
  - [fzf-git.sh](https://github.com/junegunn/fzf-git.sh) - Git integration for fzf
  - [fzf-tab](https://github.com/Aloxaf/fzf-tab) - fzf integration for zsh tab completion
- [getRelease](https://github.com/JakeTRogers/getRelease) - A tool to download the latest release of a binary from GitHub
  - getRelease, bat, fd, fzf and ripgrep install into `~/.local/bin` without sudo, so a Dev container whose home directory is a Home volume keeps them after a Rebuild. On a machine where getRelease installed binaries elsewhere, such as `/usr/local/bin`, each run moves them into `~/.local/bin` and removes the old copies with sudo, so `sudo <tool>` no longer finds them (see [ADR 0001](docs/adr/0001-getrelease-tools-install-in-home.md))
- [ripgrep](https://github.com/BurntSushi/ripgrep) - A line-oriented search tool

This repo also includes a [PowerShell profile for Linux](powershell/profile_linux.ps1), which is not installed by `install.sh`.

## Full mode only

The following are only installed when using `./install.sh full`:

- [Neovim](https://neovim.io/)
  - [lazy.nvim](https://github.com/folke/lazy.nvim) - Plugin manager
  - Plugins including LSP support, fuzzy finding, git integration, markdown rendering, [and more](neovim/)
- [Tmux](https://github.com/tmux/tmux/wiki)
  - [.tmux.conf](https://github.com/tmux/tmux/blob/master/example_tmux.conf)
  - [Tmux Plugin Manager](https://github.com/tmux-plugins/tpm)
    - [dracula/tmux-dracula](https://draculatheme.com/tmux)
    - [tmux-fingers](https://github.com/Morantron/tmux-fingers)
    - [tmux-logging](https://github.com/tmux-plugins/tmux-logging)
    - [tmux-pain-control](https://github.com/tmux-plugins/tmux-pain-control)
    - [tmux-resurrect](https://github.com/tmux-plugins/tmux-resurrect)
    - [tmux-sensible](https://github.com/tmux-plugins/tmux-sensible)
    - [tmux-yank](https://github.com/tmux-plugins/tmux-yank)
- Vim configuration - `.vimrc` symlink, pathogen, and plugins (Minimal mode installs the vim package only)

## Installation

The installation process is handled by the `install.sh` script. It has 2 Install modes:

- `./install.sh` - without any arguments, it runs Minimal mode, intended for Dev containers and Lab servers, including:
  - curl, less, git, gpg, vim, zsh, oh-my-zsh, getRelease, bat, fd, fzf, ripgrep
- `./install.sh full` - with the `full` argument, it runs Full mode, intended for Workstations (laptops, desktops and jump servers), adding:
  - neovim, tmux (tmux.conf, TPM, plugins), vim configuration (vimrc, pathogen, plugins)

Changes to this repo reach a machine only when `install.sh` runs again. Each run records the commit it applied and its Install mode in `~/.local/state/dotfiles/installed`. While the Checkout is on its default branch, a new zsh prints one line with the command to run when the Checkout is behind origin, or has changed since `install.sh` last ran. It checks origin with a background fetch at most once a day.

> [!NOTE]
> You should fork this repo and adjust it to your needs before running the script.

## Git identity

Shared Git settings live in [git/gitconfig](git/gitconfig), which is linked to `~/.config/git/config`. That file sets `commit.gpgsign = true`, so every commit is signed. It contains no identity. Each machine keeps its own identity in `~/.gitconfig`, which is not tracked in this repo:

```ini
[user]
  name = Your Name
  email = you@example.com
  signingkey = <gpg key id>
```

Git reads both files, and `~/.gitconfig` takes precedence. In a dev container, the VS Code Dev Containers extension copies the host's `~/.gitconfig` into the container and forwards your GPG keys. This repo then links the shared settings. As a result, your identity and signing key reach the container without a bind mount and without changes to the project's `devcontainer.json`.

The extension copies only `~/.gitconfig` itself and ignores `[include]` directives, so keep the identity directly in that file. Changes reach a container only when it is rebuilt.

## credit

- [https://github.com/benmatselby/dotfiles](https://github.com/benmatselby/dotfiles)
