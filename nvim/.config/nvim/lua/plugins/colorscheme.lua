return {
	"oskarnurm/koda.nvim",
	lazy = false,
	priority = 1000,
	config = function()
		require("koda").setup({
			on_highlights = function(hl, c)
				hl.Search = { bg = "#4d4d4d", fg = c.bg }
				hl.IncSearch = { bg = "#4d4d4d", fg = c.bg }
				hl.CurSearch = { bg = "#4d4d4d", fg = c.bg }
				hl.Visual = { bg = "#4d4d4d" }
				hl.MatchParen = { fg = "#4d4d4d", bold = true }
			end,
		})
		vim.cmd("colorscheme koda")
	end,
}
