return {
	{
		"j-hui/fidget.nvim",
		enabled = false,
		event = { "LspProgress" },
		init = function()
			vim.notify = require("fidget.notification").notify
		end,
		config = function()
			require("fidget").setup({
				integration = {
					["nvim-tree"] = {
						enable = false, -- Integrate with nvim-tree/nvim-tree.lua (if installed)
					},
					["xcodebuild-nvim"] = {
						enable = false, -- Integrate with wojciech-kulik/xcodebuild.nvim (if installed)
					},
				},
			})
		end,
	},

	{
		"echasnovski/mini.notify",
		version = false,
		init = function()
			vim.notify = require("mini.notify").make_notify()
		end,
		config = function()
			require("mini.notify").setup({
				lsp_progress = {
					enable = false,
				},
				window = {
					max_width_share = 0.69,
					config = {
						border = "none",
					},
				},
			})
		end,
	},
}
