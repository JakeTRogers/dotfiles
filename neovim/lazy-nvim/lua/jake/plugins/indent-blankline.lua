return {
	-- https://github.com/lukas-reineke/indent-blankline.nvim
	"lukas-reineke/indent-blankline.nvim",
	version = "3.*",
	event = { "BufReadPre", "BufNewFile" },
	main = "ibl",
	opts = {
		indent = { char = "┊" },
	},
}
