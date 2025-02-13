return {
  -- https://github.com/rmagatti/auto-session
  "rmagatti/auto-session",
  -- NOTE: no releases, tags only
  config = function()
    local auto_session = require("auto-session")

    auto_session.setup({
      auto_restore = false,
      suppressed_dirs = { "~/", "~/Dev/", "~/Downloads", "~/Documents", "~/Desktop/" },
    })

    vim.o.sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions"

    local keymap = vim.keymap
    keymap.set("n", "<leader>qr", "<cmd>SessionRestore<CR>", { desc = "Restore session for cwd" }) -- restore last workspace session for current directory
    keymap.set("n", "<leader>qs", "<cmd>SessionSave<CR>", { desc = "Save session for auto session root dir" }) -- save workspace session for current working directory
  end,
}
