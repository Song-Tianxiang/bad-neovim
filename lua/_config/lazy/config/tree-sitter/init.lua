return {
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		cmd = { "TSUninstall", "TSUpdate", "TSInstall" },
		branch = "main",
		opts = {
			ensure_install = {
				"c",
				"lua",
				"vim",
				"vimdoc",
				"markdown",
				"markdown_inline",
				"bash",
				"python",
				"query",
				"toml",
				"yaml",
				"json",
				"diff",
				"cpp",
				"cmake",
				"rust",
				"go",
			},
		},
		config = function(_, opts)
			require("nvim-treesitter").setup(opts)
		end,
	},
}
