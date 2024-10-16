require("_config.diagnostic")
require("_config.options")

require("_config.rocks").setup({})

vim.g.base46_cache = vim.fn.stdpath("data") .. "/base46/"
vim.env.PATH = vim.env.PATH .. ":" .. vim.fs.normalize(vim.fs.joinpath(vim.fn.stdpath("data"), "mason", "bin"))
require("_config.lazy")

for _, v in ipairs(vim.fn.readdir(vim.g.base46_cache)) do
	dofile(vim.g.base46_cache .. v)
end

require("_config.autocmd")
require("_config.command")
require("_config.mapping")

require("_config.highlight")
