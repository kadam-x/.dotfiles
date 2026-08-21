return {
	"echasnovski/mini.tabline",
	version = false,

	config = function()
		require("mini.tabline").setup({
			show_icons = true,
			set_vim_settings = true,
			tabpage_section = "right",
		})

		vim.keymap.set("n", "<Tab>", "<Cmd>bnext<CR>", {
			silent = true,
			noremap = true,
		})

		vim.keymap.set("n", "<C-Tab>", "<Cmd>bprevious<CR>", {
			silent = true,
			noremap = true,
		})

		local function setup_tabline()
			-- Background
			vim.api.nvim_set_hl(0, "MiniTablineFill", {
				bg = "NONE",
				ctermbg = "NONE",
			})

			vim.api.nvim_set_hl(0, "MiniTablineCurrent", {
				fg = "#0d0e17",
				bg = "#52ab8f",
				bold = true,
				ctermbg = "NONE",
			})

			vim.api.nvim_set_hl(0, "MiniTablineVisible", {
				fg = "NONE",
				bg = "NONE",
				ctermfg = "NONE",
				ctermbg = "NONE",
			})

			vim.api.nvim_set_hl(0, "MiniTablineHidden", {
				fg = "NONE",
				bg = "NONE",
				ctermfg = "NONE",
				ctermbg = "NONE",
			})

			-- Prevent Vim's base tabline groups from adding backgrounds
			vim.api.nvim_set_hl(0, "TabLine", {
				fg = "NONE",
				bg = "NONE",
				ctermfg = "NONE",
				ctermbg = "NONE",
			})

			vim.api.nvim_set_hl(0, "TabLineFill", {
				fg = "NONE",
				bg = "NONE",
				ctermfg = "NONE",
				ctermbg = "NONE",
			})

			vim.api.nvim_set_hl(0, "TabLineSel", {
				fg = "NONE",
				bg = "NONE",
				ctermfg = "NONE",
				ctermbg = "NONE",
			})
		end

		setup_tabline()

		vim.api.nvim_create_autocmd("ColorScheme", {
			callback = setup_tabline,
		})
	end,
}
