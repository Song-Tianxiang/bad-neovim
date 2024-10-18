local map_add = vim.keymap.set

map_add("n", "<C-q>", "<Cmd>bunload<CR>")

map_add("n", "<Leader>th", function()
	require("nvchad.themes").open()
end, { desc = "theme picker" })

map_add({ "n", "t" }, "<A-o>", function()
	require("nvchad.term").toggle({
		float_opts = {},
		pos = "float",
		id = "floatTerm",
	})
end, { desc = "terminal toggle floating term" })
