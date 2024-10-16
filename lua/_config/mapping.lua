local map_add = vim.keymap.set

map_add("n", "<C-q>", "<Cmd>bunload<CR>")

map_add("n", "<Leader>th", function()
	require("nvchad.themes").open()
end, { desc = "theme picker" })

map_add({ "n", "t" }, "<A-o>", function()
	require("nvchad.term").toggle({
		size = 0.8,
		float_opts = { width = vim.o.columns - 10, height = vim.o.lines - 5 },
		pos = "float",
		id = "floatTerm",
	})
end, { desc = "terminal toggle floating term" })
