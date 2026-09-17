return {
	{
		"laz4rd/sugarplum.nvim",
		config = function()
			require("sugarplum").setup()
			vim.cmd.colorscheme("sugarplum")
		end,
	},
}
