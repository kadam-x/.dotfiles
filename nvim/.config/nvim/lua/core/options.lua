vim.opt.termguicolors = true
vim.opt.showtabline = 0
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.opt.showmode = false
vim.opt.laststatus = 3
vim.opt.nu = true
vim.opt.relativenumber = true
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.ruler = false
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.undofile = true
vim.opt.inccommand = "split"
vim.opt.background = "dark"
vim.opt.scrolloff = 8
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.updatetime = 50
vim.opt.mouse = "a"
vim.opt.signcolumn = "no"
vim.o.foldenable = true
vim.o.foldmethod = "manual"
vim.o.foldlevel = 99
vim.o.foldcolumn = "0"
vim.opt.clipboard = "unnamedplus"
vim.g.clipboard = {
	name = "wl-clipboard",
	copy = { ["+"] = "wl-copy --trim-newline", ["*"] = "wl-copy --trim-newline" },
	paste = { ["+"] = "wl-paste --no-newline", ["*"] = "wl-paste --no-newline" },
	cache_enabled = 1,
}
vim.o.showcmd = false
