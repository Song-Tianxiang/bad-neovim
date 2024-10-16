vim.diagnostic.config({
	signs = {
		text = {
			[vim.diagnostic.severity.ERROR] = "󰬌 ", --
			[vim.diagnostic.severity.WARN] = "󰬞 ", --
			[vim.diagnostic.severity.HINT] = "󰬏 ", --
			[vim.diagnostic.severity.INFO] = "󰬐 ", --
		},
	},
	virtual_text = {
		-- prefix = " ",
		-- virt_text_pos = "right_align",
	},
})
