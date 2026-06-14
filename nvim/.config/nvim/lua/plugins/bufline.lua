return {
	"kadam-x/bufline.nvim",
	config = function()
		require("bufline").config.path_depth = 1
		require("bufline").config.border = "single"
		require("bufline").config.next_key = "<tab>"
		require("bufline").config.prev_key = "<s-tab>"
		require("bufline").config.timeout = 2000
		require("bufline").setup()
	end,
}
