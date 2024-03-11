# dotfiles

This repo manages my dotfiles and works nicely with the vscode dev container extension. It handles the installation and configuration of:

- [Curl](https://github.com/curl/curl)
- [Git](https://git-scm.com/)
  - [.gitconfig](https://git-scm.com/book/en/v2/Customizing-Git-Git-Configuration)
  - [.gitignore_global](https://git-scm.com/docs/gitignore)
  - [pre-commit hooks template](https://pre-commit.com/)
- [GnuPG](https://gnupg.org/)
  - [gpg-agent.conf](https://gnupg.org/documentation/manuals/gnupg/Invoking-GPG_002dAGENT.html)
- [Less](https://github.com/gwsw/less)
- [Tmux](https://github.com/tmux/tmux/wiki)
  - [.tmux.conf](https://github.com/tmux/tmux/blob/master/example_tmux.conf)
  - [Tmux Plugin Manager](https://github.com/tmux-plugins/tpm)
    - [tmux-dracula](https://draculatheme.com/tmux)
    - [tmux-fingers](https://github.com/Morantron/tmux-fingers)
    - [tmux-logging](https://github.com/tmux-plugins/tmux-logging)
    - [tmux-pain-control](https://github.com/tmux-plugins/tmux-pain-control)
    - [tmux-sensible](https://github.com/tmux-plugins/tmux-sensible)
    - [tmux-yank](https://github.com/tmux-plugins/tmux-yank)
- [Vim](https://www.vim.org/)
  - [.vimrc](https://github.com/vim/vim/blob/master/runtime/vimrc_example.vim)
  - [Pathogen Plugin Manager](https://github.com/tpope/vim-pathogen)
    - [ctrlp.vim](https://github.com/ctrlpvim/ctrlp.vim)
    - [nerdtree](https://github.com/preservim/nerdtree)
    - [numbers.vim](https://github.com/myusuf3/numbers.vim)
    - [syntastic](https://github.com/vim-syntastic/syntastic)
    - [tabular](https://github.com/godlygeek/tabular)
    - [tlib_vim](https://github.com/tomtom/tlib_vim)
    - [vim-addon-mw-utils](https://github.com/MarcWeber/vim-addon-mw-utils)
    - [vim-airline-themes](https://github.com/vim-airline/vim-airline-themes)
    - [vim-airline](https://github.com/vim-airline/vim-airline)
    - [vim-colors-solarized](https://github.com/altercation/vim-colors-solarized)
    - [vim-polyglot](https://github.com/sheerun/vim-polyglot)
    - [vim-puppet](https://github.com/rodjek/vim-puppet)
    - [vim-snipmate](https://github.com/garbas/vim-snipmate)
    - [vim-surround](https://github.com/tpope/vim-surround)
- [zsh](https://www.zsh.org/)
  - [zshrc](https://github.com/ohmyzsh/ohmyzsh/blob/master/templates/zshrc.zsh-template)
  - [Oh My Zsh](https://ohmyz.sh/)
    - [powerlevel10k](https://github.com/romkatv/powerlevel10k)
    - [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions)
    - [zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting)

## Installation

The installation process is handled by the `install.sh` script. It has 2 install modes:

- `./install.sh` - without any arguments, it performs a minimal installation intended for devcontainers, skipping:
  - `.gitconfig`
  - `tmux`
  - `vim`
- `./install.sh full` - with the `full` argument, it will perform a full installation intended for a jump server/workstation.

> [!NOTE]
> You should fork this repo and adjust it to your needs before running the script.

## credit

- https://github.com/benmatselby/dotfiles
