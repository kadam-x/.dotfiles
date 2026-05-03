return {
    "nvim-treesitter/nvim-treesitter",
    event = "VeryLazy",
    branch = "master",
    build = ":TSUpdate",
    cmd = { "TSUpdateSync", "TSUpdate", "TSInstall" },
    dependencies = {
        "nvim-treesitter/nvim-treesitter-textobjects",
    },
    opts = {
        ensure_installed = {
            "bash", "c", "diff", "html", "lua", "luadoc",
            "markdown", "markdown_inline", "query", "vim", "vimdoc",
            "rust", "regex", "python", "nix", "astro", "cpp",
            "php", "blade",
        },
        auto_install = true,
        highlight = {
            enable = true,
            additional_vim_regex_highlighting = { "ruby" },
        },
        indent = { enable = true, disable = { "ruby" } },
        incremental_selection = {
            enable = true,
            keymaps = {
                init_selection = "<M-space>",
                node_incremental = "<M-space>",
                scope_incremental = false,
                node_decremental = "<Backspace>",
            },
        },
        textobjects = {
            select = {
                enable = true,
                lookahead = true,
                keymaps = {
                    ["af"] = { query = "@function.outer", desc = "Select outer part of a function region" },
                    ["if"] = { query = "@function.inner", desc = "Select inner part of a function region" },
                    ["ac"] = { query = "@class.outer",    desc = "Select outer part of a class region" },
                    ["ic"] = { query = "@class.inner",    desc = "Select inner part of a class region" },
                    ["as"] = { query = "@local.scope", query_group = "locals", desc = "Select language scope" },
                },
            },
            swap = {
                enable = true,
                swap_next = {
                    ["<leader>xs"] = { query = "@parameter.inner", desc = "Swap with next" },
                },
                swap_previous = {
                    ["<leader>xS"] = { query = "@parameter.inner", desc = "Swap with previous" },
                },
            },
        },
    },
}
