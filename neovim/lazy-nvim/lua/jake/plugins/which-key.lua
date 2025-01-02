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
	},
}
