return {
	"folke/which-key.nvim",
	event = "VeryLazy",
	config = function()
		require("which-key").setup({
			delay = 0,
			preset = "helix",

			icons = {
				group = "",
			},

			triggers = {
				{ "<leader>", mode = "n" },
				{ "s", mode = "n" },
			},

			spec = {
				{ "<leader>c", group = "onform", icon = "C" },
				{ "<leader>e", group = "xplorer", icon = "E" },
				{ "<leader>r", group = "eplace", icon = "R" },
				{ "<leader>f", group = "ind", icon = "F" },
				{ "<leader>l", group = "sp", icon = "L" },
				{ "<leader>s", group = "urround", icon = "S" },

				{ "<leader>fb", group = "uffer Grep", icon = "B" },
				{ "<leader>fc", group = "onfig Files", icon = "C" },
				{ "<leader>fd", group = "iagnostics", icon = "D" },
				{ "<leader>ff", group = "ind Files", icon = "F" },
				{ "<leader>fg", group = "rep Files", icon = "G" },
				{ "<leader>fh", group = "elp Tags", icon = "H" },
				{ "<leader>fk", group = "eymaps", icon = "K" },
				{ "<leader>fp", group = "ath to clipboard", icon = "P" },
				{ "<leader>fr", group = "ecent Files", icon = "R" },
				{ "<leader>ft", group = "ODO List", icon = "T" },
				{ "<leader>fw", group = "ord Find", icon = "W" },

				{ "<leader>fy", hidden = true },
				{ "<leader>E", hidden = true },
				{ "<leader>d", hidden = true },
				{ "<leader>lwa", hidden = true },
				{ "<leader>lwr", hidden = true },
				{ "<leader>lws", hidden = true },
				{ "<leader>lwl", hidden = true },
				{ "<leader>lg", hidden = true },
				{ "<leader>lf", hidden = true },
				{ "<leader>lH", hidden = true },
				{ "<leader>un", hidden = true },
			},
		})
	end,
}
