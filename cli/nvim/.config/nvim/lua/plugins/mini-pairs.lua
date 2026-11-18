return {
	"nvim-mini/mini.pairs",
	event = "VeryLazy",
	version = false,
	opts = {
		mappings = {
			["<BS>"] = false,
		},
	},
	config = function(_, opts)
		require("mini.pairs").setup(opts)
		pcall(vim.keymap.del, "i", "<BS>")
	end,
}

