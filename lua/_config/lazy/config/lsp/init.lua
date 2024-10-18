return {
	{
		"neovim/nvim-lspconfig",
		event = { "User FilePost" },
		cmd = { "LspStart" },
		config = function()
			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("LspBufSet", { clear = true }),
				callback = function(args)
					local lsp = vim.lsp.buf
					local opts = function(des)
						return { silent = true, buffer = args.buf, desc = "LSP " .. des }
					end
					local keymap = function(mode, lhs, rhs, des)
						vim.keymap.set(mode, lhs, rhs, opts(des))
					end
					keymap({ "n", "v" }, "<LocalLeader>a", function()
						lsp.code_action({ apply = true })
					end, "Coda Action")
					-- keymap({ 'n', 'v' }, '<LocalLeader>f', lsp.format, "Format")
					keymap({ "n", "v" }, "<LocalLeader>h", lsp.signature_help, "Signature Help")
					keymap({ "n", "v" }, "<LocalLeader>n", require("nvchad.lsp.renamer") or lsp.rename, "Rename")

					keymap({ "n", "v" }, "<LocalLeader>d", lsp.definition, "Definition")
					keymap({ "n", "v" }, "<LocalLeader>r", lsp.references, "References")
					keymap({ "n", "v" }, "<LocalLeader>i", lsp.implementation, "Implementation")

					keymap({ "n", "v" }, "<LocalLeader>ci", lsp.incoming_calls, "Incoming Calls")
					keymap({ "n", "v" }, "<LocalLeader>co", lsp.outgoing_calls, "Outgoing Calls")

					keymap({ "n", "v" }, "<LocalLeader>td", lsp.type_definition, "Type Definition")
					keymap({ "n", "v" }, "<LocalLeader>tb", function()
						lsp.typehierarchy("subtypes")
					end, "Subtypes Typehierarchy")
					keymap({ "n", "v" }, "<LocalLeader>tp", function()
						lsp.typehierarchy("supertypes")
					end, "Supertypes, Typehierarchy")

					-- vim.api.nvim_set_option_value('formatexpr', 'v:lua.vim.lsp.formatexpr()', { buf = args.buf })
					vim.api.nvim_set_option_value("omnifunc", "v:lua.vim.lsp.omnifunc", { buf = args.buf })
					vim.api.nvim_set_option_value("tagfunc", "v:lua.vim.lsp.tagfunc", { buf = args.buf })
					vim.api.nvim_set_option_value("keywordprg", ":lua vim.lsp.buf.hover()", { buf = args.buf })

					keymap("n", "<LocalLeader>ee", vim.diagnostic.open_float, "Diagnostic open float")
					keymap("n", "<LocalLeader>en", function()
						vim.diagnostic.jump({ count = 1, float = true })
					end, "Diagnostic jump foreward")
					keymap("n", "<LocalLeader>ep", function()
						vim.diagnostic.jump({ count = -1, float = true })
					end, "Diagnostic jump backward")
					keymap("n", "<LocalLeader>el", vim.diagnostic.setloclist, "Diagnostic setloclist")
					keymap("n", "<LocalLeader>eq", vim.diagnostic.setqflist, "Diagnostic setqflist")
					keymap("n", "<LocalLeader>eh", vim.diagnostic.hide, "Diagnostic hide")
					keymap("n", "<LocalLeader>es", vim.diagnostic.show, "Diagnostic show")

					local client = vim.lsp.get_client_by_id(args.data.client_id)
					if client then
						if client.supports_method("textDocument/inlayHint") then
							vim.lsp.inlay_hint.enable()
						end
						if client.supports_method("textDocument/codeLens") then
							vim.lsp.codelens.refresh({ bufnr = args.buf })
						end
						-- if client.supports_method('textDocument/formatting') then
						--     vim.api.nvim_create_autocmd('BufWritePre', {
						--         buffer = args.buf,
						--         callback = function()
						--             vim.lsp.buf.format({ bufnr = args.buf, id = client.id })
						--         end,
						--     })
						-- end

						if client.name == "gopls" and not client.server_capabilities.semanticTokensProvider then
							local semantic = client.config.capabilities.textDocument.semanticTokens
							client.server_capabilities.semanticTokensProvider = {
								full = true,
								legend = { tokenModifiers = semantic.tokenModifiers, tokenTypes = semantic.tokenTypes },
								range = true,
							}
						end
					end
				end,
			})
			vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
				border = "rounded",
				max_width = 80,
			})
			require("lspconfig").lua_ls.setup({
				on_init = function(client)
					if client.workspace_folders then
						local path = client.workspace_folders[1].name
						if vim.uv.fs_stat(path .. "/.luarc.json") or vim.uv.fs_stat(path .. "/.luarc.jsonc") then
							return
						end
					end
					client.config.settings.Lua = vim.tbl_deep_extend("force", client.config.settings.Lua, {
						runtime = {
							version = "LuaJIT",
						},
						workspace = {
							checkThirdParty = false,
							library = {
								vim.env.VIMRUNTIME,
							},
						},
					})
				end,
				settings = {
					Lua = {
						diagnostics = {
							globals = { "vim" },
						},
						codeLens = {
							enable = true,
						},
						workspace = {
							checkThirdParty = false,
							library = {
								"$VIMRUNTIME",
								"${3rd}/luv/library",
							},
						},
					},
				},
			})
			require("lspconfig").gopls.setup({
				settings = {
					gopls = {
						hints = {
							assignVariableTypes = true,
							compositeLiteralFields = true,
							compositeLiteralTypes = true,
							constantValues = true,
							functionTypeParameters = true,
							parameterNames = true,
							rangeVariableTypes = true,
						},
						semanticTokens = true,
					},
				},
			})
			require("lspconfig").clangd.setup({
				cmd = {
					"clangd",
					"--header-insertion-decorators=false",
					"--header-insertion=never",
					"--fallback-style=WebKit",
				},
			})
			require("lspconfig").cmake.setup({})
			require("lspconfig").rust_analyzer.setup({})
		end,
	},
	{
		"williamboman/mason.nvim",
		cmd = { "Mason", "MasonInstall", "MasonInstallAll", "MasonUpdate" },
		config = function()
			require("mason").setup({
				PATH = "skip",
				ui = {
					icons = {
						package_pending = " ",
						package_installed = " ",
						package_uninstalled = " ",
					},
				},
			})
		end,
	},
}
