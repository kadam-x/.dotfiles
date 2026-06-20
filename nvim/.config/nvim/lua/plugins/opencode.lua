return {
	"nickjvandyke/opencode.nvim",
	version = "*",
	dependencies = {
		{
			---@module "snacks"
			"folke/snacks.nvim",
			optional = true,
			opts = {
				input = {},
				picker = {
					actions = {
						opencode_send = function(...)
							return require("opencode").snacks_picker_send(...)
						end,
					},
					win = {
						input = {
							keys = {
								["<a-a>"] = { "opencode_send", mode = { "n", "i" } },
							},
						},
					},
				},
			},
		},
	},
	config = function()
		---@type opencode.Opts
		vim.g.opencode_opts = {}

		vim.o.autoread = true

		-- Core actions
		vim.keymap.set({ "n", "x" }, "<leader>oa", function()
			require("opencode").ask("@this: ")
		end, { desc = "Ask OpenCode" })

		vim.keymap.set({ "n", "x" }, "<leader>os", function()
			require("opencode").select()
		end, { desc = "Select OpenCode action" })

		vim.keymap.set({ "n", "t" }, "<leader>ot", function()
			require("opencode").toggle()
		end, { desc = "Toggle OpenCode" })

		-- Session management
		vim.keymap.set("n", "<leader>on", function()
			require("opencode").command("session.new")
		end, { desc = "New OpenCode session" })

		vim.keymap.set("n", "<leader>ol", function()
			require("opencode").command("session.list")
		end, { desc = "List OpenCode sessions" })

		vim.keymap.set("n", "<leader>oc", function()
			require("opencode").command("session.compact")
		end, { desc = "Compact OpenCode session" })

		vim.keymap.set("n", "<leader>oi", function()
			require("opencode").command("session.interrupt")
		end, { desc = "Interrupt OpenCode" })

		-- Scrolling
		vim.keymap.set("n", "<leader>ou", function()
			require("opencode").command("session.half.page.up")
		end, { desc = "Scroll OpenCode up" })

		vim.keymap.set("n", "<leader>od", function()
			require("opencode").command("session.half.page.down")
		end, { desc = "Scroll OpenCode down" })

		vim.keymap.set({ "n", "x" }, "go", function()
			return require("opencode").operator("@this ")
		end, { desc = "Append range to OpenCode", expr = true })

		vim.keymap.set("n", "goo", function()
			return require("opencode").operator("@this ") .. "_"
		end, { desc = "Append line to OpenCode", expr = true })
	end,
}
