return {
	"nvim-lualine/lualine.nvim",
	event = "VeryLazy",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	config = function()
		local flat = { a = { fg = "#dadada" }, b = { fg = "#dadada" }, c = { fg = "#dadada" } }

		require("lualine").setup({
			options = {
				theme = {
					normal = flat,
					insert = flat,
					visual = flat,
					replace = flat,
					command = flat,
					inactive = flat,
				},
				component_separators = { left = "", right = "" },
				section_separators = { left = "", right = "" },
				globalstatus = true,
			},
			sections = {
				lualine_a = {},
				lualine_b = {},
				lualine_c = {
					{
						"filetype",
						icon_only = true,
						padding = { left = 1, right = 0 },
						cond = function()
							return #vim.lsp.get_clients({ bufnr = 0 }) > 0
						end,
					},
					{ "filename", path = 0, padding = { left = 1, right = 1 } },
				},
				lualine_x = {},
				lualine_y = { "progress" },
				lualine_z = { "location" },
			},
			inactive_sections = {
				lualine_c = {},
				lualine_x = {},
			},
		})
	end,
}
