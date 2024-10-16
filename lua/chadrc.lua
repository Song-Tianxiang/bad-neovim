local M = {}

M.base46 = {
	theme = "onedark",
	hl_override = {},
	theme_toggle = { "chadtain", "one_light" },
}

M.ui = {
	statusline = {
		theme = "default",
		modules = {
			cwd = function()
				local s = require("base46").get_theme_tb("base_30").statusline_bg
				vim.api.nvim_set_hl(
					0,
					"St_cwd_sep",
					{ fg = vim.api.nvim_get_hl(0, { name = "St_cwd_sep" }).fg, bg = s }
				)
				vim.api.nvim_set_hl(
					0,
					"St_cwd_icon",
					{ fg = s, bg = vim.api.nvim_get_hl(0, { name = "St_cwd_icon" }).bg }
				)
				vim.api.nvim_set_hl(
					0,
					"St_cwd_sep_reverse",
					{ reverse = true, fg = vim.api.nvim_get_hl(0, { name = "St_cwd_sep" }).fg, bg = s }
				)
				local icon = "%#St_cwd_icon#" .. "  "
				local name = vim.uv.cwd()
				name = "%#St_cwd_sep#" .. " " .. (name:match("([^/\\]+)[/\\]*$") or name) .. " "
				return (
					vim.o.columns > 85 and ("%#St_cwd_sep#" .. " %#St_cwd_sep_reverse#" .. icon .. "" .. name)
				) or ""
			end,
			cursor = function()
				local s = require("base46").get_theme_tb("base_30").statusline_bg
				vim.api.nvim_set_hl(
					0,
					"St_pos_sep",
					{ fg = vim.api.nvim_get_hl(0, { name = "St_pos_sep" }).fg, bg = s }
				)
				vim.api.nvim_set_hl(
					0,
					"St_pos_icon",
					{ fg = s, bg = vim.api.nvim_get_hl(0, { name = "St_pos_icon" }).bg }
				)
				vim.api.nvim_set_hl(
					0,
					"St_pos_sep_reverse",
					{ reverse = true, fg = vim.api.nvim_get_hl(0, { name = "St_pos_sep" }).fg, bg = s }
				)
				return "%#St_pos_sep#" .. "" .. "%#St_pos_icon#  %#St_pos_sep_reverse#%#St_pos_sep#%p %%"
			end,
			-- %#St_pos_sep_reverse#  %#St_pos_sep#
		},
	},

	cmp = {
		icons_left = false, -- only for non-atom styles!
		lspkind_text = true,
		style = "default", -- default/flat_light/flat_dark/atom/atom_colored
		format_colors = {
			tailwind = false, -- will work for css lsp too
			icon = "󱓻",
		},
		format_abbr = {
			-- maxwidth = 30,
			-- minwidth = 180,
		},
	},
}

return M
