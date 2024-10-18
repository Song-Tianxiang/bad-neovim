local lazypath = vim.fs.normalize(vim.fs.joinpath(vim.fn.stdpath("data"), "/lazy/lazy.nvim"))
local lazyconfig_path = vim.fs.normalize(vim.fs.joinpath(vim.fn.stdpath("config"), "lua", "_config", "lazy"))

if not vim.uv.fs_stat(lazypath) then
	local repo = "https://github.com/folke/lazy.nvim.git"
	vim.fn.system({ "git", "clone", "--filter=blob:none", repo, "--branch=stable", lazypath })
end

vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
	{ import = "_config.lazy.config" },
}, {
	lockfile = vim.fs.joinpath(lazyconfig_path, "lockfile.json"),
	defaults = { lazy = true },
	ui = {
		icons = {
			ft = "",
			lazy = "󰂠 ",
			loaded = "",
			not_loaded = "",
		},
	},
	performance = {
		rtp = {
			disabled_plugins = {
				"shada",
				"man",
				"spellfile",
				"osc52",
				"matchparen",
				"editorconfig",
				"2html_plugin",
				"tohtml",
				"getscript",
				"getscriptPlugin",
				"gzip",
				"logipat",
				"netrw",
				"netrwPlugin",
				"netrwSettings",
				"netrwFileHandlers",
				"matchit",
				"tar",
				"tarPlugin",
				"rrhelper",
				"spellfile_plugin",
				"vimball",
				"vimballPlugin",
				"zip",
				"zipPlugin",
				"tutor",
				"rplugin",
				"syntax",
				"synmenu",
				"optwin",
				"compiler",
				"bugreport",
				"ftplugin",
			},
		},
	},
	rocks = {
		hererocks = false,
		enabled = false,
		-- root = require("_config.rocks").rocks_root,
	},
})
