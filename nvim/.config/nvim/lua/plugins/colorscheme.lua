return {
	{
		"gnfisher/tomorrow-night-blue.nvim",
		lazy = false,
		priority = 1000,
		config = function()
			require("tomorrow-night-blue").setup({
			})
			vim.cmd.colorscheme("tomorrow-night-blue")
		end,
	},
}
