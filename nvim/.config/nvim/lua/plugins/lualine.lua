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
					{ "filename", symbols = { modified = " +", readonly = " -", unnamed = "" } },
					{ "branch", icon = "" },
				},
				lualine_c = {},
				lualine_x = {
					{
						function()
							if #vim.lsp.get_clients({ bufnr = 0 }) > 0 then
								local devicons = require("nvim-web-devicons")
								local icon =
									devicons.get_icon(vim.fn.expand("%:t"), vim.bo.filetype, { default = true })
								return (icon or "") .. " " .. vim.bo.filetype
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
