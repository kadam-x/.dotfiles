return {
	"nvim-lualine/lualine.nvim",
	event = "VeryLazy",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	config = function()
		require("lualine").setup({
			options = {
				theme = require("onyx.lualine"),
				component_separators = { left = "", right = "" },
				section_separators = { left = "", right = "" },
				globalstatus = true,
			},
			sections = {
				lualine_a = { "mode" },
				lualine_b = {
					{ "branch", icon = "" },
					{ symbols = { modified = " +", readonly = " -", unnamed = "" } },
				},
				lualine_c = {},
				lualine_x = {
					{
						function()
							if #vim.lsp.get_clients({ bufnr = 0 }) > 0 then
								local devicons = require("nvim-web-devicons")
								return devicons.get_icon(vim.fn.expand("%:t"), vim.bo.filetype, { default = true })
									or ""
							end
							return ""
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
