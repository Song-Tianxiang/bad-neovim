return {
	-- {
	-- 	"nvim-neorg/neorg",
	-- 	lazy = false, -- Disable lazy loading as some `lazy.nvim` distributions set `lazy = true` by default
	-- 	version = "*", -- Pin Neorg to the latest stable release
	-- 	config = true,
	-- },
	{ "https://github.com/kmarius/jsregexp.git", build = "luarocks" },
	{ "nvim-lua/plenary.nvim" },
	{
		"echasnovski/mini.icons",
		opts = {},
		init = function()
			package.preload["nvim-web-devicons"] = function()
				require("mini.icons").mock_nvim_web_devicons()
				return package.loaded["nvim-web-devicons"]
			end
		end,
	},
	{
		"nvim-tree/nvim-web-devicons",
		opts = {},
	},
	{ "windwp/nvim-autopairs" },
	"nvchad/volt",
	"nvchad/minty",
	"nvchad/menu",
	{
		"lukas-reineke/indent-blankline.nvim",
		event = "User FilePost",
		opts = {
			indent = { char = "│", highlight = "IblChar" },
			scope = { char = "│", highlight = "IblScopeChar" },
		},
		config = function(_, opts)
			local hooks = require("ibl.hooks")
			hooks.register(hooks.type.WHITESPACE, hooks.builtin.hide_first_space_indent_level)
			require("ibl").setup(opts)
		end,
	},
}
