return {
	"kyazdani42/blue-moon",
	lazy = false,
	priority = 1000,
	config = function()
		vim.opt.termguicolors = true
		vim.cmd("colorscheme blue-moon")
	end,
}
