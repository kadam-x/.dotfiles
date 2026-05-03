return {
	"saghen/blink.cmp",
	version = "*",
	opts = {
		keymap = {
			preset = "none",
			-- Only map in Insert mode explicitly
			["<Tab>"] = { "select_next", "fallback" },
			["<S-Tab>"] = { "select_prev", "fallback" },
			["<CR>"] = { "accept", "fallback" },
			["<Esc>"] = { "hide", "fallback" },
		},
		completion = {
			list = { selection = { preselect = true, auto_insert = true } },
			menu = { auto_show = true },
		},
	},
}
