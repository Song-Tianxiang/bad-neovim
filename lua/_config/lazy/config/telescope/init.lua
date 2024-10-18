return {
	{
		"nvim-telescope/telescope.nvim",
		dependencies = {
			{ "nvim-treesitter/nvim-treesitter" },
			{
				"nvim-telescope/telescope-fzf-native.nvim",
				build = "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release",
				config = function()
					require("telescope").load_extension("fzf")
				end,
			},
		},
		cmd = "Telescope",
		keys = {
			{ "<Leader>ff", "<CMD>Telescope find_files<CR>", desc = "Telescope find files" },
			{ "<Leader>fo", "<CMD>Telescope oldfiles<CR>", desc = "Telescope oldfiles" },
			{ "<Leader>fi", "<CMD>Telescope<CR>", desc = "Telescope" },
		},
		config = function()
			require("telescope").setup({
				defaults = {
					prompt_prefix = "   ",
					selection_caret = " ",
					entry_prefix = " ",
					sorting_strategy = "ascending",
					layout_config = {
						horizontal = {
							prompt_position = "top",
							preview_width = 0.55,
						},
						width = 0.87,
						height = 0.80,
					},
					mappings = {
						n = { ["q"] = require("telescope.actions").close },
					},
				},

				extensions_list = { "themes", "terms" },
				extensions = {},
			})
		end,
	},
	{
		"nvim-telescope/telescope-frecency.nvim",
		enalbed = false,
		cmd = "Telescope frecency",
		keys = {
			{ "<Leader>fo", "<CMD>Telescope frecency<CR>", desc = "Telescope frecency" },
		},
		config = function()
			require("telescope").load_extension("frecency")
		end,
	},
}
