return {
	"vague-theme/vague.nvim",
	lazy = false,
	priority = 1000,
	config = function()
		require("vague").setup({
			transparent = false,
			bold = true,
			italic = true,
		})
		vim.cmd("colorscheme vague")
	end,
}
