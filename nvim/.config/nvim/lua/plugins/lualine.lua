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
				lualine_a = {
					{
						"filename",
						path = 0,
						symbols = { modified = " +", readonly = " -", unnamed = "" },
					},
				},
				lualine_b = {
					{ "branch", icon = "" },
				},
				lualine_c = {},
				lualine_x = {
					{
						function()
							local clients = vim.lsp.get_clients({ bufnr = 0 })
							if #clients == 0 then
								return ""
							end
							local names = {}
							for _, c in ipairs(clients) do
								table.insert(names, c.name)
							end
							return table.concat(names, ", ")
						end,
					},
				},
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
