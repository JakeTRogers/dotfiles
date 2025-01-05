return {
  -- https://github.com/ibhagwan/fzf-lua
  "ibhagwan/fzf-lua",
  -- NOTE: no releases, no tags
  -- optional for icon support
  dependencies = {
    "nvim-tree/nvim-web-devicons",
    "echasnovski/mini.icons",
  },
  -- or if using mini.icons/mini.nvim
  opts = {},

  config = function()
    local fzf_lua = require("fzf-lua")

    fzf_lua.setup({
      winopts = {
        height = 0.85,
        width = 0.90,
        preview = {
          border = "noborder",
          hidden = "nohidden",
        },
      },
      lsp = { async_or_timeout = 3000 },
      files = {
        input_prompt = "Files❯ ",
        prompt = "Files❯ ",
      },
      grep = {
        input_prompt = "Rg❯ ",
        prompt = "Rg❯ ",
      },
      previewers = {
        bat = {
          theme = "tokyonight_night",
        },
      },
    })

    local keymap = vim.keymap -- for conciseness

    keymap.set("n", "<leader>fb", "<cmd>FzfLua buffers<cr>", { desc = "Fuzzy find buffers" })
    keymap.set("n", "<leader>fc", "<cmd>FzfLua grep_cWORD<cr>", { desc = "Find string under cursor in cwd" })
    keymap.set("n", "<leader>fe", "<cmd>FzfLua resume<cr>", { desc = "Fuzzy find resume" })
    keymap.set("n", "<leader>ff", "<cmd>FzfLua files<cr>", { desc = "Fuzzy find files in cwd" })
    keymap.set("n", "<C-p>", "<cmd>FzfLua files<cr>", { desc = "Fuzzy find files in cwd" })
    keymap.set("n", "<leader>fg", "<cmd>FzfLua registers<cr>", { desc = "Fuzzy find registers" })
    keymap.set("n", "<leader>fm", "<cmd>FzfLua marks<cr>", { desc = "Fuzzy find marks" })
    keymap.set("n", "<leader>fq", "<cmd>FzfLua quickfix<cr>", { desc = "Fuzzy find quickfix list" })
    keymap.set("n", "<leader>fr", "<cmd>FzfLua oldfiles<cr>", { desc = "Fuzzy find recent files" })
    keymap.set("n", "<leader>fs", "<cmd>FzfLua live_grep<cr>", { desc = "Find string in cwd" })

    -- git keymaps
    keymap.set("n", "<leader>gb", "<cmd>FzfLua git_branches<cr>", { desc = "Fuzzy git branches" })
    keymap.set("n", "<leader>gc", "<cmd>FzfLua git_commits<cr>", { desc = "Fuzzy git commit log (project)" })
    keymap.set("n", "<leader>gf", "<cmd>FzfLua git_files<cr>", { desc = "Fuzzy git ls-files" })
    keymap.set("n", "<leader>gh", "<cmd>FzfLua git_stash<cr>", { desc = "Fuzzy git stash" })
    keymap.set("n", "<leader>gs", "<cmd>FzfLua git_status<cr>", { desc = "Fuzzy git status" })
    keymap.set("n", "<leader>gt", "<cmd>FzfLua git_tags<cr>", { desc = "Fuzzy git tags" })
    keymap.set("n", "<leader>gw", "<cmd>FzfLua git_blame<cr>", { desc = "Fuzzy git blame" })
  end,
}
