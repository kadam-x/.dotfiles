return {
	"smoka7/hop.nvim",
	event = "VeryLazy",
	config = function()
		require("hop").setup()
		vim.keymap.set({ "n", "x", "o" }, "f", function()
			require("hop").hint_words()
		end, { desc = "Hop word jump (Helix gw)" })
	end,
}
