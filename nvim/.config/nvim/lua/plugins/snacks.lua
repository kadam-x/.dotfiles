return {
	"folke/snacks.nvim",
	priority = 1000,
	lazy = false,
	config = function()
		require("snacks").setup({
			bigfile = { enabled = true },
			image = { enabled = false },
			indent = { enabled = true },
			lazygit = { enabled = false },
			picker = { enabled = true },
			dashboard = {
				enabled = true,
				preset = {
					header = [[
       ██████╗███╗   ██╗███████╗███████╗██╗   ██╗██╗███╗   ███╗
      ██╔════╝████╗  ██║██╔════╝╚══███╔╝██║   ██║██║████╗ ████║
      ╚█████╗ ██╔██╗ ██║█████╗    ███╔╝ ██║   ██║██║██╔████╔██║
       ╚═══██╗██║╚██╗██║██╔══╝   ███╔╝  ╚██╗ ██╔╝██║██║╚██╔╝██║
      ██████╔╝██║ ╚████║███████╗███████╗ ╚████╔╝ ██║██║ ╚═╝ ██║
      ╚═════╝ ╚═╝  ╚═══╝╚══════╝╚══════╝  ╚═══╝  ╚═╝╚═╝     ╚═╝]],
					keys = {
						{
							icon = " ",
							key = "f",
							desc = "Find File",
							action = function()
								Snacks.picker.files()
							end,
						},
						{
							icon = " ",
							key = "r",
							desc = "Recent Files",
							action = function()
								Snacks.picker.recent()
							end,
						},
						{
							icon = " ",
							key = "g",
							desc = "Live Grep",
							action = function()
								Snacks.picker.grep()
							end,
						},
						{
							icon = " ",
							key = "c",
							desc = "Config Files",
							action = function()
								Snacks.picker.files({ cwd = vim.fn.stdpath("config") })
							end,
						},
						{ icon = " ", key = "q", desc = "Quit", action = ":qa" },
					},
				},
				sections = {
					{ section = "header" },
					{ section = "keys", gap = 1, padding = 1 },
					{ section = "recent_files", icon = " ", title = "Recent Files", indent = 2, padding = 1 },
				},
			},
		})

		vim.keymap.set("n", "<leader>un", function()
			Snacks.notifier.hide()
		end, { desc = "Dismiss notifications" })
		vim.keymap.set({ "n", "t" }, "<A-h>", function()
			Snacks.terminal.toggle(
				nil,
				{ win = { position = "float", width = 0.95, height = 0.65, border = "single" } }
			)
		end, { desc = "Toggle terminal" })
		vim.keymap.set("n", "<leader>ff", function()
			Snacks.picker.files()
		end, { desc = "Find Files" })
		vim.keymap.set("n", "<leader>fg", function()
			Snacks.picker.grep()
		end, { desc = "Live Grep" })
		vim.keymap.set("n", "<leader>fr", function()
			Snacks.picker.recent()
		end, { desc = "Recent Files" })
		vim.keymap.set({ "n", "x" }, "<leader>fw", function()
			Snacks.picker.grep_word()
		end, { desc = "Find Word" })
		vim.keymap.set("n", "<leader>fb", function()
			Snacks.picker.grep_buffers()
		end, { desc = "Grep Buffers" })
		vim.keymap.set("n", "<leader>fh", function()
			Snacks.picker.help()
		end, { desc = "Help Tags" })
		vim.keymap.set("n", "<leader>fk", function()
			Snacks.picker.keymaps({ confirm = "edit" })
		end, { desc = "Keymaps" })
		vim.keymap.set("n", "<leader>fd", function()
			Snacks.picker.diagnostics()
		end, { desc = "Diagnostics" })
		vim.keymap.set("n", "<leader>fc", function()
			Snacks.picker.files({ cwd = vim.fn.stdpath("config") })
		end, { desc = "Neovim Config Files" })
		vim.keymap.set("n", "<leader>ft", function()
			Snacks.picker.grep({
				search = "TODO|NOTE",
				live = false,
				dirs = { vim.fn.expand("~/projects"), vim.fn.expand("~/work") },
			})
		end, { desc = "TODO list" })
		vim.keymap.set("n", "X", function()
			Snacks.bufdelete()
		end, { desc = "Delete Buffer" })
	end,
}
