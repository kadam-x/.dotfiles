return {
	"nvim-lualine/lualine.nvim",
	event = "VeryLazy",
	config = function()
		require("lualine").setup({
			options = {
				component_separators = { left = "", right = "" },
				section_separators = { left = "", right = "" },
				globalstatus = true,
			},
			sections = {
				lualine_a = { "mode" },
				lualine_b = {
					{ "filename", symbols = { modified = " +", readonly = " -", unnamed = "" } },
					{ "branch", icon = "" },
				},
				lualine_c = {},
				lualine_x = {
					{
						function()
							return "bufs:" .. #vim.fn.getbufinfo({ buflisted = 1 })
						end,
					},
					{
						function()
							if #vim.lsp.get_clients({ bufnr = 0 }) > 0 then
								return vim.bo.filetype
							end
							return ""
						end,
					},
				},
				lualine_y = {},
				lualine_z = { "location" },
			},
			inactive_sections = {
				lualine_c = {},
				lualine_x = {},
			},
		})
	end,
}
