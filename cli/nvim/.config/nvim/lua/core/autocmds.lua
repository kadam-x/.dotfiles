-- floating preview border
local orig_util_open_floating_preview = vim.lsp.util.open_floating_preview
function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
    opts = opts or {}
    opts.border = opts.border or "rounded"
    return orig_util_open_floating_preview(contents, syntax, opts, ...)
end

-- cursorline
vim.api.nvim_create_autocmd({ "BufEnter", "WinEnter", "InsertLeave" }, {
    callback = function()
        vim.opt.cursorline = true
        vim.opt.cursorlineopt = "number"
    end,
})
vim.api.nvim_create_autocmd("InsertEnter", {
    callback = function()
        vim.opt.cursorline = true
        vim.opt.cursorlineopt = "both"
    end,
})

-- textwidth
vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, {
    callback = function()
        vim.opt_local.textwidth = 80
        vim.opt_local.formatoptions:append("t")
        vim.opt_local.smartindent = false
    end,
})

-- open dashboard on directory
vim.api.nvim_create_autocmd("VimEnter", {
    callback = function()
        if vim.fn.argc() == 1 then
            local arg = vim.fn.argv(0)
            if vim.fn.isdirectory(arg) == 1 then
                vim.defer_fn(function()
                    pcall(vim.api.nvim_buf_delete, 0, { force = true })
                    require("snacks").dashboard.open()
                end, 10)
            end
        end
    end,
})

-- yank highlight
vim.api.nvim_create_autocmd("TextYankPost", {
    desc = "Highlight when yanking text",
    group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
    callback = function() vim.hl.on_yank() end,
})

-- transparent backgrounds
vim.api.nvim_create_autocmd("ColorScheme", {
    callback = function()
        local transparent = {
            "Normal", "NormalFloat", "FloatBorder", "FloatTitle", "FloatFooter",
            "NormalNC", "Pmenu", "PmenuSbar", "SignColumn", "StatusLine",
            "StatusLineNC", "WinSeparator", "SnacksNormal", "SnacksBorder", "SnacksBackdrop",
        }
        for _, hl in ipairs(transparent) do
            vim.api.nvim_set_hl(0, hl, { bg = "NONE" })
        end
        vim.diagnostic.config({ signs = false, virtual_text = true })
    end,
})
