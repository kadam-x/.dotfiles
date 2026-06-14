return {
	{
		"kadam-x/onyx-colorscheme",
		lazy = false,
		priority = 1000,
		config = function()
			vim.opt.termguicolors = true
			vim.cmd([[colorscheme onyx]]) -- to set the theme permanently
		end,
	},
}
