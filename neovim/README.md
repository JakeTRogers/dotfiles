# Neovim Configuration

This directory contains the Neovim configuration using [lazy.nvim](https://github.com/folke/lazy.nvim) as the plugin manager.

## Structure

### Entry Point

- **`lazy-nvim/init.lua`** - Main entry point that loads:
  - `jake.core` - Core configuration (options, keymaps)
  - `jake.lazy` - Plugin manager initialization

### Core Configuration (`lua/jake/core/`)

- **`init.lua`** - Loads all core modules
- **`options.lua`** - Neovim settings (line numbers, indentation, search, etc.)
- **`keymaps.lua`** - Custom key mappings

### Plugins (`lua/jake/plugins/`)

All plugins are defined as separate Lua modules that return lazy.nvim plugin specifications.

#### UI & Theme

- **`colorscheme.lua`** - [Tokyo Night](https://github.com/folke/tokyonight.nvim) color scheme with custom color overrides
- **`alpha.lua`** - Greeter dashboard
- **`lualine.lua`** - Status line
- **`bufferline.lua`** - Buffer tabs
- **`indent-blankline.lua`** - Indentation guides
- **`dressing.lua`** - Better UI for vim.ui.select and vim.ui.input
- **`which-key.lua`** - Keybinding popup display

#### Editor Enhancement

- **`autopairs.lua`** - Auto-close brackets, quotes, etc.
- **`nvim-surround.lua`** - Surround text objects
- **`comment.lua`** - Commenting utilities
- **`substitute.lua`** - Text substitution
- **`vim-maximizer.lua`** - Maximize/restore windows
- **`marks.lua`** - Enhanced mark visualization

#### Navigation & Search

- **`nvim-tree.lua`** - File explorer with `nvim-web-devicons`
- **`fzf.lua`** - Fuzzy finder integration
- **`treesitter.lua`** - Syntax parsing and highlighting
- **`trouble.lua`** - Diagnostics list
- **`init.lua`** - Common dependencies:
  - `plenary.nvim` - Lua utility functions
  - `vim-tmux-navigator` - Seamless tmux/vim navigation

#### Git Integration

- **`gitsigns.lua`** - Git decorations and hunk actions

#### Completion & Snippets

- **`nvim-cmp.lua`** - Autocompletion engine with sources:
  - `cmp-buffer` - Buffer text completion
  - `cmp-path` - File system path completion
  - `cmp_luasnip` - Snippet completion
  - `friendly-snippets` - Collection of useful snippets
  - `lspkind.nvim` - VS Code-like pictograms
- **`luasnip.lua`** - Snippet engine

#### LSP (`lsp/`)

- **`mason.lua`** - LSP server installer with:
  - `mason-lspconfig` - LSP integration bridge
  - `mason-tool-installer` - Automatic tool installation
- **`lspconfig.lua`** - LSP server configurations

#### Specialized

- **`formatter.lua`** - Code formatting
- **`auto-session.lua`** - Session management
- **`obsidian.lua`** - Obsidian vault integration
- **`render-markdown.lua`** - Enhanced markdown rendering
- **`bullets.lua`** - Bullet list management
- **`todo-comments.lua`** - Highlight TODO comments

### Custom Dictionary

- **`spell/en.utf-8.add.spl`** - Custom spell file

> [!NOTE]
> On first launch, lazy.nvim will automatically install all plugins.

## Key Features

- **LSP Support**: Full language server protocol support with Mason for easy server installation
- **Fuzzy Finding**: FZF integration for files, buffers, and grep
- **Git Integration**: GitSigns for inline git status and hunk navigation
- **Markdown**: Enhanced rendering with Obsidian vault support
- **Auto-completion**: Context-aware completion with snippets
- **Session Management**: Automatic session saving and restoration
- **Treesitter**: Advanced syntax highlighting and text objects

## Adding New Plugins

1. Create a new file in `lua/jake/plugins/` (e.g., `myplugin.lua`)
2. Return a lazy.nvim plugin spec:

    ```lua
    return {
      "author/plugin-name",
      config = function()
        -- plugin configuration
      end,
    }
    ```

3. Restart Neovim - lazy.nvim will automatically load and install the plugin

## Customization

- Modify `lua/jake/core/options.lua` for editor settings
- Modify `lua/jake/core/keymaps.lua` for key bindings
- Each plugin config can be customized in its respective file
