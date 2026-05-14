return {
	{
		"williamboman/mason-lspconfig.nvim",
		dependencies = {
			{
				"williamboman/mason.nvim",
				opts = {
					ui = {
						icons = {
							package_installed = "✓",
							package_pending = "➜",
							package_uninstalled = "✗",
						},
					},
				},
			},
			"neovim/nvim-lspconfig",
		},
		opts = {
			ensure_installed = {
				"html",
				"cssls",
				"lua_ls",
				"clangd",
				"rust_analyzer",
				"astro",
				"eslint",
				"pyrefly",
				"gopls",
			},
		},
		config = function(_, opts)
			require("mason").setup({
				ui = {
					icons = {
						package_installed = "✓",
						package_pending = "➜",
						package_uninstalled = "✗",
					},
				},
			})
			require("mason-lspconfig").setup(opts)

			vim.lsp.config("*", {})

			local servers = {
				"html",
				"cssls",
				"lua_ls",
				"clangd",
				"rust_analyzer",
				"astro",
				"eslint",
				"gopls",
			}
			for _, server in ipairs(servers) do
				vim.lsp.enable(server)
			end

			vim.lsp.config("pyrefly", {
				cmd = { "pyrefly", "lsp" },
				filetypes = { "python" },
				root_markers = {
					"pyrefly.toml",
					"pyproject.toml",
					"setup.py",
					"setup.cfg",
					"requirements.txt",
					"Pipfile",
					".git",
				},
			})
			vim.lsp.enable("pyrefly")

			vim.api.nvim_create_autocmd("LspAttach", {
				callback = function(args)
					local o = { buffer = args.buf }

					-- Standard binds
					vim.keymap.set("n", "K", vim.lsp.buf.hover, vim.tbl_extend("force", o, { desc = "Hover docs" }))
					vim.keymap.set(
						"n",
						"gd",
						vim.lsp.buf.definition,
						vim.tbl_extend("force", o, { desc = "Go to definition" })
					)
					vim.keymap.set(
						"n",
						"gr",
						vim.lsp.buf.references,
						vim.tbl_extend("force", o, { desc = "Go to references" })
					)
					vim.keymap.set(
						"i",
						"<C-k>",
						vim.lsp.buf.signature_help,
						vim.tbl_extend("force", o, { desc = "Signature help" })
					)

					-- <leader>l LSP group
					vim.keymap.set(
						"n",
						"<leader>ln",
						vim.lsp.buf.rename,
						vim.tbl_extend("force", o, { desc = "Rename symbol" })
					)
					vim.keymap.set(
						"n",
						"<leader>la",
						vim.lsp.buf.code_action,
						vim.tbl_extend("force", o, { desc = "Code action" })
					)
					vim.keymap.set(
						"n",
						"<leader>ld",
						vim.lsp.buf.declaration,
						vim.tbl_extend("force", o, { desc = "Go to declaration" })
					)
					vim.keymap.set(
						"n",
						"<leader>li",
						vim.lsp.buf.implementation,
						vim.tbl_extend("force", o, { desc = "Go to implementation" })
					)
					vim.keymap.set(
						"n",
						"<leader>lr",
						vim.lsp.buf.references,
						vim.tbl_extend("force", o, { desc = "Go to references" })
					)
				end,
			})
		end,
	},
	{
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		opts = {
			ensure_installed = {
				"prettier",
				"stylua",
				"isort",
				"black",
				"clang-format",
				"eslint_d",
			},
		},
		dependencies = { "williamboman/mason.nvim" },
	},
}
