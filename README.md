# dotfiles

This repo manages my dotfiles and works nicely with the vscode dev container extension. It handles the installation and configuration of:

- [Tmux](https://github.com/tmux/tmux/wiki)
- [Git](https://git-scm.com/)
  - [pre-commit hooks template](https://pre-commit.com/)
  - [global gitignore](https://git-scm.com/docs/gitignore)
  - [gitconfig](https://git-scm.com/book/en/v2/Customizing-Git-Git-Configuration)
- [GPG Agent](https://gnupg.org/documentation/manuals/gnupg/Invoking-GPG_002dAGENT.html)
- [Vim](https://www.vim.org/)
  - [vimrc](https://vim.fandom.com/wiki/Open_vimrc_file)
  - [pathogen]()
  - pathogen managed plugins
    - [vim-colors-solarized](https://github.com/altercation/vim-colors-solarized)
    - [ctrlp.vim](https://github.com/ctrlpvim/ctrlp.vim)
    - [vim-snipmate](https://github.com/garbas/vim-snipmate)
    - [tabular](https://github.com/godlygeek/tabular)
    - [vim-addon-mw-utils](https://github.com/MarcWeber/vim-addon-mw-utils)
    - [numbers.vim](https://github.com/myusuf3/numbers.vim)
    - [vim-puppet](https://github.com/rodjek/vim-puppet)
    - [nerdtree](https://github.com/preservim/nerdtree)
    - [syntastic](https://github.com/vim-syntastic/syntastic)
    - [vim-polyglot](https://github.com/sheerun/vim-polyglot)
    - [tlib_vim](https://github.com/tomtom/tlib_vim)
    - [vim-surround](https://github.com/tpope/vim-surround)
    - [vim-airline](https://github.com/vim-airline/vim-airline)
    - [vim-airline-themes](https://github.com/vim-airline/vim-airline-themes)
- [Oh My Zsh](https://ohmyz.sh/)

## Installation

The installation process is handled by the `install.sh` script. Run this script to install and configure all the dotfiles. You should for this repo and adjust it to your needs before running the script.

## credit

- https://github.com/benmatselby/dotfiles
