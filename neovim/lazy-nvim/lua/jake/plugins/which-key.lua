return {
  -- https://github.com/folke/which-key.nvim
  "folke/which-key.nvim",
  version = "3.*",
  event = "VeryLazy",
  init = function()
    vim.o.timeout = true
    vim.o.timeoutlen = 500
  end,
  opts = {
    -- your configuration comes here
    -- or leave it empty to use the default settings
    -- refer to the configuration section below
    spec = {
      {
        mode = { "n" },
        { "<leader>c", group = "code", icon = { icon = "", color = "green" } },
        { "<leader>cs", group = "spelling", icon = { icon = "󰓆", color = "green" } },
        { "<leader>e", group = "explorer", icon = { icon = "󱧼", color = "blue" } },
        { "<leader>f", group = "fzf", icon = { icon = "", color = "yellow" } },
        { "<leader>g", group = "git", icon = { icon = "󰊢", color = "cyan" } },
        { "<leader>h", group = "git hunk", icon = { icon = "", color = "grey" } },
        { "<leader>m", group = "markdown", icon = { icon = "", color = "green" } },
        { "<leader>s", group = "screen", icon = { icon = "", color = "azure" } },
        { "<leader>t", group = "tabs", icon = { icon = "󰝜", color = "purple" } },
        { "<leader>q", group = "quit/session", icon = { icon = "󰈆", color = "red" } },
        { "<leader>x", group = "trouble", icon = { icon = "󰚑", color = "orange" } },
      },
    },
  },
  keys = {
    {
      "<leader>?",
      function()
        require("which-key").show({ global = false })
      end,
      desc = "Buffer Local Keymaps (which-key)",
    },
  },
}
