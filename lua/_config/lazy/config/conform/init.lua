return {
	"stevearc/conform.nvim",
	event = { "BufWritePre" },
	cmd = { "ConformInfo" },
	keys = {
		{
			"<LocalLeader>f",
			function()
				require("conform").format({ async = true })
			end,
			mode = "",
			desc = "Format buffer",
		},
	},
	opts = {
		-- Define your formatters
		formatters_by_ft = {
			cmake = { "gersemi" },
			lua = { "stylua" },
			cpp = { "clang-format" },
			["*"] = { "codespell" },
			["_"] = { "trim_whitespace" },
		},
		-- Set default options
		default_format_opts = {
			async = true,
		},
		format_on_save = {
			lsp_format = "fallback",
			timeout_ms = 500,
		},
		-- Customize formatters
		formatters = {
			["clang-format"] = {
				prepend_args = { "--fallback-style=WebKit" },
			},
		},
	},
	init = function()
		-- If you want the formatexpr, here is the place to set it
		vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
	end,
}
