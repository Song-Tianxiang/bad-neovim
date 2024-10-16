local g = vim.g
local o = vim.o
local keycode = vim.keycode

g.mapleader = keycode("<Space>")
g.maplocalleader = keycode("<Bslash>")

-- o.loadplugins = false

o.termguicolors = true

o.number = true
o.signcolumn = "yes"

o.cursorline = true
o.cursorlineopt = "number"

o.tabstop = 4
o.softtabstop = 4
o.shiftwidth = 4
o.expandtab = true

o.cindent = false
o.smartindent = true
o.autoindent = true

o.ignorecase = true
o.smartcase = true

o.incsearch = true
o.hlsearch = false

o.splitbelow = true
o.splitright = true

o.showmode = false
o.showcmd = false

o.timeout = false
o.ttimeout = true
o.ttimeoutlen = 0

o.undofile = true
o.swapfile = true

o.ruler = false
o.laststatus = 3
-- o.scrolloff = 9

o.belloff = "all"
o.clipboard = "unnamedplus"

-- o.list = true
-- o.listchars = [[tab:  ,trail:·,nbsp:␣]]

o.shortmess = o.shortmess .. "aITc"
o.wildoptions = "fuzzy,pum"
o.fillchars = [[eob: ]]

o.completeopt = "menuone,popup,noinsert,noselect,fuzzy"

g.loaded_node_provider = 0
g.loaded_perl_provider = 0
g.loaded_python3_provider = 0
g.loaded_ruby_provider = 0
