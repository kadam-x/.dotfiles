return {
	"nvim-lualine/lualine.nvim",
	event = "VeryLazy",
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
					{ "filename", symbols = { modified = " +", readonly = " -", unnamed = "" } },
					{ "branch", icon = "" },
				},
				lualine_c = {},
				lualine_x = {
					{
						function()
							if #vim.lsp.get_clients({ bufnr = 0 }) > 0 then
								return vim.bo.filetype
							end
							return ""
						end,
					},
					{
						function()
							local count = #vim.tbl_filter(function(bufnr)
								return vim.api.nvim_buf_is_loaded(bufnr) and vim.bo[bufnr].buflisted
							end, vim.api.nvim_list_bufs())
							return "bufs: " .. count
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
