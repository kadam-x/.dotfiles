return {
    "mikavilpas/yazi.nvim",
    event = "VeryLazy",
    config = function()
        require("yazi").setup({
            open_for_directories = false,
            keymaps = {
                show_help                            = "<f1>",
                open_file_in_vertical_split          = "<c-v>",
                open_file_in_horizontal_split        = "<c-x>",
                open_file_in_tab                     = "<c-t>",
                grep_in_directory                    = "<c-s>",
                replace_in_directory                 = "<c-g>",
                cycle_open_buffers                   = "<tab>",
                copy_relative_path_to_selected_files = "<c-y>",
                send_to_quickfix_list                = "<c-q>",
            },
        })
        vim.keymap.set("n", "<leader>e",  "<cmd>Yazi<cr>",        { desc = "Open yazi at current file" })
        vim.keymap.set("n", "<leader>E",  "<cmd>Yazi cwd<cr>",    { desc = "Open yazi in cwd" })
        vim.keymap.set("n", "<leader>fy", "<cmd>Yazi toggle<cr>", { desc = "Resume last yazi session" })
    end,
}
