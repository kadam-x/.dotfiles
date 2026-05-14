return {
	"nvim-treesitter/nvim-treesitter",
	version = false,
	branch = "main",
	event = "VeryLazy",
	build = ":TSUpdate",
	dependencies = {
		"nvim-treesitter/nvim-treesitter-textobjects",
	},
	opts = {
		ensure_installed = {
			"bash",
			"c",
			"diff",
			"html",
			"lua",
			"luadoc",
			"markdown",
			"markdown_inline",
			"query",
			"vim",
			"vimdoc",
			"rust",
			"regex",
			"python",
			"nix",
			"astro",
			"cpp",
			"php",
			"blade",
		},
		auto_install = true,
		highlight = { enable = true },
		indent = { enable = true },
		textobjects = {
			select = {
				enable = true,
				lookahead = true,
				keymaps = {
					["af"] = "@function.outer",
					["if"] = "@function.inner",
					["ac"] = "@class.outer",
					["ic"] = "@class.inner",
				},
			},
		},
	},
	config = function(_, opts)
		vim.treesitter.language.setup = vim.treesitter.language.setup or function() end
		require("nvim-treesitter").setup(opts)
	end,
}
