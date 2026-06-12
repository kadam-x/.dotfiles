return {
	"nvim-lualine/lualine.nvim",
	event = "VeryLazy",
	config = function()
		require("lualine").setup({
			options = {
				component_separators = { left = "", right = "" },
				section_separators = { left = "", right = "" },
				globalstatus = true,
				theme = require("onyx.lualine"),
			},
			sections = {
				lualine_a = { "mode" },
				lualine_b = {
					{ "branch", icon = "" },
					{
						"filename",
						path = 1,
						symbols = { modified = " +", readonly = " -", unnamed = "" },
						fmt = function(s)
							local parts = {}
							for p in s:gmatch("[^/\\]+") do
								table.insert(parts, p)
							end
							if #parts <= 4 then
								return s
							end
							return table.concat(
								{ parts[#parts - 3], parts[#parts - 2], parts[#parts - 1], parts[#parts] },
								"/"
							)
						end,
					},
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
							local clients = vim.lsp.get_clients({ bufnr = 0 })
							if #clients == 0 then
								return ""
							end

							local ok, icons = pcall(require, "nvim-web-devicons")
							if ok then
								local icon, _ = icons.get_icon_by_filetype(vim.bo.filetype)
								if icon then
									return icon .. " " .. vim.bo.filetype
								end
							end

							return vim.bo.filetype
						end,
					},
				},
				lualine_y = {},
				lualine_z = { "location" },
			},
			inactive_sections = {
				lualine_c = { { "filename", path = 1 } },
				lualine_x = {},
			},
		})
	end,
}
