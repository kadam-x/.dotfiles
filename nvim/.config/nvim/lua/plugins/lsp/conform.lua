return {
	"stevearc/conform.nvim",
	event = { "BufReadPre", "BufNewFile" },
	keys = {
		{
			"<leader>c",
			function()
				require("conform").format({ lsp_fallback = true, async = false, timeout_ms = 3000 })
			end,
			desc = "Format buffer",
		},
	},
	config = function()
		require("conform").setup({
			formatters_by_ft = {
				javascript = { "prettier" },
				typescript = { "prettier" },
				css = { "prettier" },
				html = { "prettier" },
				json = { "prettier" },
				yaml = { "prettier" },
				markdown = { "prettier" },
				lua = { "stylua" },
				cpp = { "clang_format" },
				c = { "clang_format" },
				rust = { "rustfmt" },
			},
		})
	end,
}
