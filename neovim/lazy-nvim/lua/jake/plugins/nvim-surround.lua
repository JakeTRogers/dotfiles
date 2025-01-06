return {
  -- https://github.com/kylechui/nvim-surround
  "kylechui/nvim-surround",
  version = "2.*",
  event = { "BufReadPre", "BufNewFile" },
  version = "*", -- Use for stability; omit to use `main` branch for the latest features
  config = true,
}
