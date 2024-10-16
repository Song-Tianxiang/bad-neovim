return {
	{
		"hrsh7th/nvim-cmp",
		event = "InsertEnter",
		dependencies = {
			{
				-- snippet plugin
				"L3MON4D3/LuaSnip",
				build = function()
					require("_config.rocks").install("jsregexp")
				end,
				dependencies = {
					{ "rafamadriz/friendly-snippets" },
				},
				config = function()
					local luasnip = require("luasnip")
					local types = require("luasnip.util.types")
					luasnip.setup({
						keep_roots = true,
						link_roots = true,
						exit_roots = false,
						link_children = true,
						ext_opts = {
							[types.insertNode] = {
								unvisited = {
									virt_text = { { "|", "Conceal" } },
									virt_text_pos = "inline",
								},
							},
							[types.exitNode] = {
								unvisited = {
									virt_text = { { "|", "Conceal" } },
									virt_text_pos = "inline",
								},
							},
						},
					})
					require("luasnip.loaders.from_vscode").lazy_load()
					vim.keymap.set({ "i", "s" }, "<C-l>", function()
						if luasnip.jumpable(1) then
							luasnip.jump(1)
						end
					end, { silent = true, desc = "luasnip: jump foreward" })
					vim.keymap.set({ "i", "s" }, "<C-h>", function()
						if luasnip.jumpable(-1) then
							luasnip.jump(-1)
						end
					end, { silent = true, desc = "luasnip: jump backward" })
					vim.keymap.set({ "i", "s" }, "<C-k>", function()
						require("luasnip").activate_node()
					end, { silent = true, desc = "luasnip: activate node under cursor" })
				end,
			},

			-- auto pairs () {} []...
			{
				"windwp/nvim-autopairs",
				config = function(_, opts)
					require("nvim-autopairs").setup()

					local cmp_autopairs = require("nvim-autopairs.completion.cmp")
					require("cmp").event:on("confirm_done", cmp_autopairs.on_confirm_done())
				end,
			},

			-- cmp sources plugins
			{
				"saadparwaiz1/cmp_luasnip",
				"hrsh7th/cmp-nvim-lsp",
				"hrsh7th/cmp-buffer",
				"hrsh7th/cmp-path",
			},
		},
		config = function()
			local cmp = require("cmp")
			local options = {
				experimental = {
					ghost_text = true,
				},
				completion = {
					completeopt = "menuone,noselect,noinsert,popup,fuzzy",
				},
				snippet = {
					expand = function(args)
						require("luasnip").lsp_expand(args.body)
					end,
				},
				mapping = {
					["<C-p>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select }),
					["<C-n>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select }),
					["<C-e>"] = cmp.mapping.abort(),
					["<C-y>"] = cmp.mapping.confirm({ select = true }),
					["<C-d>"] = cmp.mapping.scroll_docs(5),
					["<C-u>"] = cmp.mapping.scroll_docs(-5),

					["<CR>"] = cmp.mapping({
						i = function(fallback)
							if cmp.visible() and cmp.get_active_entry() then
								cmp.confirm({ select = false })
							else
								fallback()
							end
						end,
						s = cmp.mapping.confirm({ select = true }),
					}),

					["<Tab>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
						else
							fallback()
						end
					end, { "i", "s" }),

					["<S-Tab>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_prev_item({ behavior = cmp.SelectBehavior.Select })
						else
							fallback()
						end
					end, { "i", "s" }),
				},
				sources = {
					{ name = "nvim_lsp" },
					{ name = "luasnip" },
					{ name = "buffer" },
					{ name = "path" },
				},
			}
			cmp.setup(vim.tbl_deep_extend("force", options, require("nvchad.cmp")))
		end,
	},
}
