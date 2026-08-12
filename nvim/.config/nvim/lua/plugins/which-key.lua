return {
	"folke/which-key.nvim",
	event = "VeryLazy",
	config = function()
		require("which-key").setup({
			delay = 0,
			preset = "helix",
			triggers = {
				{ "<leader>", mode = "n" },
				{ "s", mode = "n" },
			},
			spec = {
				{ "<leader>s", group = "Surround", icon = "" },
				{ "<leader>fy", hidden = true },
				{ "<leader>e", icon = "󰇥" },
				{ "<leader>r", icon = "󰛔" },
				{ "<leader>E", hidden = true },
				{ "<leader>l", group = "Lsp" },
				{ "<leader>f", group = "Find" },
				{ "<leader>d", hidden = true },
				{ "<leader>lwa", hidden = true },
				{ "<leader>lwr", hidden = true },
				{ "<leader>lws", hidden = true },
				{ "<leader>lwl", hidden = true },
				{ "<leader>lg", hidden = true },
				{ "<leader>lf", hidden = true },
				{ "<leader>lH", hidden = true },
			},
		})
	end,
}
