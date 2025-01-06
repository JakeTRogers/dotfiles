return {
  -- https://github.com/williamboman/mason.nvim
  "williamboman/mason.nvim",
  version = "1.*",
  dependencies = {
    "williamboman/mason-lspconfig.nvim",
    "WhoIsSethDaniel/mason-tool-installer.nvim",
  },
  config = function()
    -- import mason
    local mason = require("mason")

    -- import mason-lspconfig
    local mason_lspconfig = require("mason-lspconfig")

    local mason_tool_installer = require("mason-tool-installer")

    -- enable mason and configure icons
    mason.setup({
      ui = {
        icons = {
          package_installed = "✓",
          package_pending = "➜",
          package_uninstalled = "✗",
        },
      },
    })

    mason_lspconfig.setup({
      -- list of servers for mason to install
      automatic_installation = { true },
      ensure_installed = {
        "ansiblels",
        "bashls",
        "cssls",
        "dockerls",
        "emmet_ls",
        "graphql",
        "html",
        "lua_ls",
        "marksman",
        "puppet",
        "ruff",
        "yamlls",
      },
    })

    mason_tool_installer.setup({
      ensure_installed = {
        "prettier", -- prettier formatter
        "stylua", -- lua formatter
        "ruff", -- python formatter
      },
    })
  end,
}
