-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    local lazyrepo = "https://github.com/folke/lazy.nvim.git"
    local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
    if vim.v.shell_error ~= 0 then
        vim.api.nvim_echo({
            { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
            { out,                            "WarningMsg" },
            { "\nPress any key to exit..." },
        }, true, {})
        vim.fn.getchar()
        os.exit(1)
    end
end
vim.opt.rtp:prepend(lazypath)


-- options
vim.g.base46_cache = vim.fn.stdpath "data" .. "/elijah/base46/"

vim.g.mapleader = vim.keycode('<Space>')
vim.g.maplocalleader = vim.keycode('<Bslash>')

vim.opt.termguicolors = true
-- vim.cmd.colorscheme 'retrobox'

vim.opt.number = true
vim.opt.cursorline = true
vim.opt.cursorlineopt = 'both'

vim.opt.tabstop = 8
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.opt.incsearch = true
vim.opt.hlsearch = false

vim.opt.splitbelow = true
vim.opt.splitright = true

vim.opt.scrolloff = 9
vim.opt.belloff = 'all'
vim.opt.wildoptions:append { 'fuzzy', 'pum' }
vim.opt.shortmess:append { I = true, c = true }
vim.opt.fillchars:append { eob = " " }
vim.opt.hidden = true
vim.opt.showmode = false
vim.opt.showcmd = false
vim.opt.laststatus = 3
vim.opt.cmdheight = 1
vim.opt.signcolumn = 'yes'
vim.opt.clipboard = 'unnamedplus'

vim.opt.timeout = false
vim.opt.ttimeout = true
vim.opt.ttimeoutlen = 0

vim.opt.undofile = true
vim.opt.swapfile = true

vim.opt.completeopt = { 'menuone', 'popup', 'noinsert', 'noselect', 'fuzzy' }

-- Setup lazy.nvim
require("lazy").setup({
    spec = {
        {
            'Song-Tianxiang/base46',
            priority = 290,
            init = function()
                vim.g.base46 = {
                    theme = "ayu_dark", -- default theme
                    hl_add = {},
                    hl_override = {},
                    integrations = {},
                    changed_themes = {},
                    transparency = false,
                    theme_toggle = { "ayu_dark", "ayu_dark" },
                    ui = {
                        cmp = {
                            icons = true,
                            lspkind_text = true,
                            style = "atom", -- default/flat_light/flat_dark/atom/atom_colored
                        },

                        telescope = { style = "bordered" }, -- borderless / bordered
                        lsp = { signature = true },
                        cheatsheet = {
                            theme = "grid",                                                     -- simple/grid
                            excluded_groups = { "terminal (t)", "autopairs", "Nvim", "Opens" }, -- can add group name or with mode
                        },
                    }
                }
            end,
            config = function()
                require('base46').load_all_highlights()
                dofile(vim.g.base46_cache .. "defaults")
                dofile(vim.g.base46_cache .. "term")
            end
        },
        {
            'nvim-treesitter/nvim-treesitter',
            branch = 'main',
            build = ':TSUpdate',
            lazy = false,
            config = function()
                vim.api.nvim_create_autocmd('FileType', {
                    pattern = { 'make', 'yaml', 'cmake', 'go', 'c', 'cpp', 'lua', 'vim', 'vimdoc', 'markdown', 'markdown_inline' },
                    callback = function() vim.treesitter.start() end,
                })
            end
        },
        {
            'neovim/nvim-lspconfig',
            config = function()
                vim.api.nvim_create_autocmd('LspAttach', {
                    group = vim.api.nvim_create_augroup('LspBufSet', { clear = true }),
                    callback = function(args)
                        local lsp = vim.lsp.buf
                        local opts = { silent = true, buffer = args.buf }
                        local keymap = function(mode, lhs, rhs)
                            vim.keymap.set(mode, lhs, rhs, opts)
                        end
                        keymap({ 'n', 'v' }, '<LocalLeader>a', function() lsp.code_action({ apply = true }) end)
                        keymap({ 'n', 'v' }, '<LocalLeader>f', lsp.format)
                        keymap({ 'n', 'v' }, '<LocalLeader>h', lsp.signature_help)
                        keymap({ 'n', 'v' }, '<LocalLeader>n', lsp.rename)

                        keymap({ 'n', 'v' }, '<LocalLeader>d', lsp.definition)
                        keymap({ 'n', 'v' }, '<LocalLeader>r', lsp.references)
                        keymap({ 'n', 'v' }, '<LocalLeader>i', lsp.implementation)

                        keymap({ 'n', 'v' }, '<LocalLeader>ci', lsp.incoming_calls)
                        keymap({ 'n', 'v' }, '<LocalLeader>co', lsp.outgoing_calls)

                        keymap({ 'n', 'v' }, '<LocalLeader>td', lsp.type_definition)
                        keymap({ 'n', 'v' }, '<LocalLeader>tb', function() lsp.typehierarchy('subtypes') end)
                        keymap({ 'n', 'v' }, '<LocalLeader>tp', function() lsp.typehierarchy('supertypes') end)

                        vim.api.nvim_set_option_value('formatexpr', 'v:lua.vim.lsp.formatexpr()', { buf = args.buf })
                        vim.api.nvim_set_option_value('omnifunc', 'v:lua.vim.lsp.omnifunc', { buf = args.buf })
                        vim.api.nvim_set_option_value('tagfunc', 'v:lua.vim.lsp.tagfunc', { buf = args.buf })
                        vim.api.nvim_set_option_value('keywordprg', ':lua vim.lsp.buf.hover()', { buf = args.buf })

                        keymap('n', '<LocalLeader>ee', vim.diagnostic.open_float)
                        keymap('n', '<LocalLeader>en', function() vim.diagnostic.jump({ count = 1, float = true }) end)
                        keymap('n', '<LocalLeader>ep', function() vim.diagnostic.jump({ count = -1, float = true }) end)
                        keymap('n', '<LocalLeader>el', vim.diagnostic.setloclist)
                        keymap('n', '<LocalLeader>eq', vim.diagnostic.setqflist)
                        keymap('n', '<LocalLeader>eh', vim.diagnostic.hide)
                        keymap('n', '<LocalLeader>es', vim.diagnostic.show)

                        local client = vim.lsp.get_client_by_id(args.data.client_id)
                        if client then
                            if client.supports_method('textDocument/inlayHint') then
                                vim.lsp.inlay_hint.enable()
                            end
                            if client.supports_method('textDocument/formatting') then
                                vim.api.nvim_create_autocmd('BufWritePre', {
                                    buffer = args.buf,
                                    callback = function()
                                        vim.lsp.buf.format({ bufnr = args.buf, id = client.id })
                                    end,
                                })
                            end
                        end
                    end,
                })
                vim.lsp.handlers['textDocument/hover'] = vim.lsp.with(
                    vim.lsp.handlers.hover, {
                        border = 'rounded',
                        max_width = 80,
                    }
                )
                require 'lspconfig'.lua_ls.setup {
                    on_init = function(client)
                        if client.workspace_folders then
                            local path = client.workspace_folders[1].name
                            if vim.uv.fs_stat(path .. '/.luarc.json') or vim.uv.fs_stat(path .. '/.luarc.jsonc') then
                                return
                            end
                        end
                        client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, {
                            runtime = {
                                version = 'LuaJIT'
                            },
                            workspace = {
                                checkThirdParty = false,
                                library = {
                                    vim.env.VIMRUNTIME
                                }
                            }
                        })
                    end,
                    settings = {
                        Lua = {
                            diagnostics = {
                                globals = { 'vim' }
                            }
                        }
                    }
                }
                require 'lspconfig'.gopls.setup {}
                require 'lspconfig'.clangd.setup {
                    cmd = { 'clangd', '--header-insertion-decorators=false', "--header-insertion=never", "--fallback-style=WebKit" }
                }
                require 'lspconfig'.cmake.setup {}
            end
        },

        {
            'hrsh7th/nvim-cmp',
            dependencies = {
                {
                    'hrsh7th/cmp-nvim-lsp',
                    dependencies = {
                        'neovim/nvim-lspconfig',
                        'hrsh7th/cmp-nvim-lsp-signature-help',
                    }
                },

                {
                    'windwp/nvim-autopairs',
                    config = function()
                        require('nvim-autopairs').setup()
                        local cmp_autopairs = require('nvim-autopairs.completion.cmp')
                        local cmp = require('cmp')
                        cmp.event:on(
                            'confirm_done',
                            cmp_autopairs.on_confirm_done()
                        )
                    end
                },

                {
                    'saadparwaiz1/cmp_luasnip',
                    dependencies = {
                        {
                            'L3MON4D3/LuaSnip',
                            build = 'make install_jsregexp',
                            dependencies = {
                                { 'rafamadriz/friendly-snippets' },
                            },
                            config = function()
                                local ls = require('luasnip')
                                ls.config.set_config(
                                    { history = true, updateevents = 'TextChanged,TextChangedI' }
                                )
                                require('luasnip.loaders.from_vscode').lazy_load()
                                vim.keymap.set({ 'i', 's' }, '<C-l>', function()
                                    if ls.jumpable(1) then
                                        ls.jump(1)
                                    else
                                        vim.cmd [[call feedkeys("\<C-l>", 'n')]]
                                    end
                                end, { silent = true })
                                vim.keymap.set({ 'i', 's' }, '<C-h>', function()
                                    if ls.jumpable(-1) then
                                        ls.jump(-1)
                                    else
                                        vim.cmd [[call feedkeys("\<C-h>", 'n')]]
                                    end
                                end, { silent = true })
                                vim.keymap.set({ 'i', 's' }, '<C-k>', function()
                                    if ls.choice_active() then
                                        ls.change_choice(1)
                                    else
                                        vim.cmd [[call feedkeys("\<C-k>", 'n')]]
                                    end
                                end, { silent = true })
                            end
                        }
                    }
                },

                'hrsh7th/cmp-buffer',
                'hrsh7th/cmp-path',

                {
                    'Song-Tianxiang/base46',
                },

            },
            config = function()
                local cmp = require('cmp')

                local kind_icons = {
                    Text = '󰦨',
                    Method = '󰆧',
                    Function = '󰊕',
                    Constructor = '',
                    Field = '󰇽',
                    Variable = '󰂡',
                    Class = '󰠱',
                    Interface = '',
                    Module = '',
                    Property = '󰜢',
                    Unit = '',
                    Value = '󰎠',
                    Enum = '',
                    Keyword = '󰌋',
                    Snippet = '',
                    Color = '󰏘',
                    File = '󰈙',
                    Reference = '',
                    Folder = '󰉋',
                    EnumMember = '',
                    Constant = '󰏿',
                    Struct = '',
                    Event = '',
                    Operator = '󰆕',
                    TypeParameter = '󰅲',
                }

                local formatFn = function(_, item)
                    local ELLIPSIS_CHAR = '…'
                    local MAX_LABEL_WIDTH = 29
                    local MIN_LABEL_WIDTH = 0

                    local label = item.abbr
                    local truncated_label = vim.fn.strcharpart(label, 0, MAX_LABEL_WIDTH)
                    if truncated_label ~= label then
                        item.abbr = truncated_label .. ELLIPSIS_CHAR
                    elseif string.len(label) < MIN_LABEL_WIDTH then
                        local padding = string.rep(' ', MIN_LABEL_WIDTH - string.len(label))
                        item.abbr = label .. padding
                    end

                    local icon = kind_icons[item.kind] or ''
                    icon = ' ' .. icon .. ' '

                    item.menu = ('   (' .. item.kind .. ')') or ''
                    item.kind = icon

                    return item
                end

                require('cmp').setup({
                    experimental = {
                        ghost_text = true,
                    },
                    matching = {
                        disallow_fuzzy_matching = false,
                    },
                    completion = {
                        keyword_length = 1,
                        completeopt = 'menuone,noselect,noinsert,popup,fuzzy',
                    },
                    snippet = {
                        expand = function(args)
                            require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
                        end,
                    },
                    mapping = {
                        ['<C-p>'] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
                        ['<C-n>'] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
                        ['<C-e>'] = cmp.mapping.abort(),
                        ['<C-y>'] = cmp.mapping.confirm({ select = true }),
                        ['<C-d>'] = cmp.mapping.scroll_docs(3),
                        ['<C-u>'] = cmp.mapping.scroll_docs(-3),

                        ['<CR>'] = cmp.mapping({
                            i = function(fallback)
                                if cmp.visible() and cmp.get_active_entry() then
                                    cmp.confirm({ select = false })
                                else
                                    fallback()
                                end
                            end,
                            s = cmp.mapping.confirm({ select = true }),
                        }),
                    },
                    formatting = {
                        expandable_indicator = true,
                        fields = { 'kind', 'abbr', 'menu' },
                        format = formatFn,
                    },
                    window = {
                        completion = {
                            col_offset = -3,
                            side_padding = 0,
                            winhighlight = "Normal:CmpPmenu,CursorLine:CmpSel,Search:None",
                            scrollbar = true,
                            -- border = { '', '─','', '─',},
                            -- border = { "", "", "", "│", "", "", "", "│" },
                        },
                        documentation = {
                            border = {
                                { "┌", "CmpDocBorder" },
                                { "─", "CmpDocBorder" },
                                { "┐", "CmpDocBorder" },
                                { "│", "CmpDocBorder" },
                                { "┘", "CmpDocBorder" },
                                { "─", "CmpDocBorder" },
                                { "└", "CmpDocBorder" },
                                { "│", "CmpDocBorder" },
                            },
                            winhighlight = "Normal:CmpDoc",
                        },
                    },
                    sources = cmp.config.sources({
                        { name = 'luasnip' },
                        { name = 'nvim_lsp', },
                        { name = 'buffer' },
                        { name = 'path' },
                        { name = 'nvim_lsp_signature_help' },
                    }, {
                    })
                })
            end
        },

        {
            "nvim-lualine/lualine.nvim",
            dependencies = {
                { 'lewis6991/gitsigns.nvim' },
            },
            config = function()
                local my_theme = {
                    normal = {
                        a = { bg = "#AA336A", fg = "#a89984", gui = "bold" },
                        b = { bg = "None", fg = "#a89984" },
                        c = { bg = "None", fg = "#a89984" },
                    },
                    insert = {
                        a = { bg = "None", fg = "#83a598", gui = "bold,reverse" },
                        b = { bg = "None", fg = "#a89984" },
                        c = { bg = "None", fg = "#a89984" },
                    },
                    visual = {
                        a = { bg = "None", fg = "#fabd2f", gui = "bold,reverse" },
                        b = { bg = "None", fg = "#a89984" },
                        c = { bg = "None", fg = "#a89984" },
                    },
                    replace = {
                        a = { bg = "None", fg = "#fb4934", gui = "bold,reverse" },
                        b = { bg = "None", fg = "#a89984" },
                        c = { bg = "None", fg = "#a89984" },
                    },
                    command = {
                        a = { bg = "None", fg = "#98c379", gui = "bold,reverse" }, --#b8bb26
                        b = { bg = "None", fg = "#a89984" },
                        c = { bg = "None", fg = "#a89984" },
                    },
                    inactive = {
                        a = { bg = "None", fg = "#a89984", gui = "bold" },
                        b = { bg = "None", fg = "#a89984" },
                        c = { bg = "None", fg = "#a89984" },
                    },
                }

                require('lualine').setup({
                    options = {
                        theme = my_theme,
                        globalstatus = true,
                        section_separators = "",
                        component_separators = "",
                        disabled_filetypes = { statusline = { "dashboard", "lazy", "alpha" } },
                    },
                    sections = {
                        lualine_a = { 'mode' },
                        lualine_b = {
                            {
                                "filename",
                                file_status = true,
                                newfile_status = true,
                                path = 1,
                                symbols = {
                                    modified = '「有改动」',
                                    readonly = '「只读文件」', -- Text to show when the file is non-modifiable or readonly.
                                    unnamed = '「未命名」', -- Text to show for unnamed buffers.
                                    newfile = '「新文件」', -- Text to show for newly created file before first write
                                },
                            },
                        },
                        lualine_c = { 'searchcount', 'selectioncount' },
                        lualine_x = {
                            'diff',
                            {
                                'diagnostics',
                                symbols = {
                                    error = 'E ',
                                    warn = 'W ',
                                    info = 'I ',
                                    hint = 'H '
                                }
                            },
                            {
                                "filetype",
                                icon_only = true
                            }
                        },
                        lualine_y = { 'progress' },
                        lualine_z = {},
                    },
                })
            end
        },
        { "nvim-tree/nvim-web-devicons" },

        {
            'lewis6991/satellite.nvim',
            config = function()
                require('satellite').setup {
                    excluded_filetypes = { 'NvimTree' },
                }
            end
        },
        {
            'williamboman/mason.nvim',
            config = function()
                require('mason').setup()
            end
        },
        {
            'lewis6991/gitsigns.nvim',
            config = function()
                require('gitsigns').setup()
            end
        },

        {
            'nvim-tree/nvim-tree.lua',
            dependencies = 'nvim-tree/nvim-web-devicons',
            keys = {
                { '<C-n>', '<CMD>NvimTreeToggle<CR>' },
            },
            config = function()
                local opts = {
                    filters = {
                        dotfiles = false,
                    },
                    disable_netrw = true,
                    hijack_netrw = true,
                    hijack_cursor = true,
                    hijack_unnamed_buffer_when_opening = false,
                    sync_root_with_cwd = true,
                    update_cwd = true,
                    update_focused_file = {
                        enable = true,
                        update_root = true,
                    },
                    view = {
                        adaptive_size = false,
                        side = 'left',
                        width = 30,
                        preserve_window_proportions = true,
                    },
                    git = {
                        enable = true,
                        ignore = true,
                    },
                    filesystem_watchers = {
                        enable = true,
                    },
                    actions = {
                        open_file = {
                            resize_window = true,
                        },
                    },
                    renderer = {
                        -- root_folder_label = false,
                        root_folder_label = ":~:s?$?/..?",
                        highlight_git = true,
                        highlight_opened_files = 'none',
                        indent_markers = {
                            enable = true,
                        },

                        icons = {
                            show = {
                                file = true,
                                folder = true,
                                folder_arrow = true,
                                git = true,
                            },

                            glyphs = {
                                default = '󰈚',
                                symlink = '',
                                folder = {
                                    default = '',
                                    empty = '',
                                    empty_open = '',
                                    open = '',
                                    symlink = '',
                                    symlink_open = '',
                                    arrow_open = '',
                                    arrow_closed = '',
                                },
                                git = {
                                    unstaged = '✗',
                                    staged = '✓',
                                    unmerged = '',
                                    renamed = '➜',
                                    untracked = '★',
                                    deleted = '',
                                    ignored = '◌',
                                },
                            },
                        },
                    },
                }
                require('nvim-tree').setup(opts)
            end,
        },
        {
            "folke/flash.nvim",
            event = "VeryLazy",
            opts = {},
            keys = {
                { [[<A-/>]], mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
            },
        },
        -- {
        --     'ggandor/leap.nvim',
        --     config = function()
        --         vim.keymap.set('n', '<leader>s', '<Plug>(leap)')
        --         vim.keymap.set({ 'x', 'o' }, '<leader>s', '<Plug>(leap-forward)')
        --         vim.keymap.set({ 'x', 'o' }, '<leader>S', '<Plug>(leap-backward)')
        --
        --         -- require('leap').opts.safe_labels = 'tfnut/FNLHMUGTZ?'
        --         -- require('leap').opts.labels = 'fnjklhodweimbuyvrgtaqpcxz/FNJKLHODWEIMBUYVRGTAQPCXZ?'
        --     end
        -- },
        -- {
        --     'brenoprata10/nvim-highlight-colors',
        --     config = function()
        --         require('nvim-highlight-colors').setup({})
        --     end,
        -- },
        {
            'lukas-reineke/indent-blankline.nvim',
            config = function()
                require("ibl").setup {
                    indent = { char = "│" },
                    scope = { char = "│", },
                    exclude = {
                        filetypes = { 'NvimTree' },
                    }
                }
            end,
        },

        {
            "nvim-telescope/telescope.nvim",
            dependencies = {
                "nvim-treesitter/nvim-treesitter",
                {
                    "nvim-telescope/telescope-frecency.nvim",
                    keys = {
                        { '<leader>fj', '<Cmd>Telescope <Cr>' },
                        { '<leader>fo', '<Cmd>Telescope frecency<Cr>' },
                        { '<leader>ff', '<Cmd>Telescope find_files<Cr>' },
                        { '<leader>fg', '<Cmd>Telescope live_grep<Cr>' },
                        { '<leader>ft', '<Cmd>Telescope themes<Cr>' },
                    },
                },
            },
            cmd = "Telescope",
            opts = {
                defaults = {
                    prompt_prefix = "   ",
                    selection_caret = " ",
                    entry_prefix = " ",
                    sorting_strategy = "ascending",
                    layout_config = {
                        horizontal = {
                            prompt_position = "top",
                            preview_width = 0.55,
                        },
                        width = 0.87,
                        height = 0.80,
                    },
                },

                extensions_list = { 'frecency', 'themes' },
                extensions = {},
            },
            config = function(_, opts)
                local telescope = require "telescope"
                telescope.setup(opts)

                -- load extensions
                for _, ext in ipairs(opts.extensions_list) do
                    telescope.load_extension(ext)
                end
            end,
        },

        -- {
        --     'voldikss/vim-floaterm',
        --     init = function()
        --         vim.g.floaterm_width = 0.69
        --         vim.g.floaterm_height = 0.69
        --         vim.g.floaterm_titleposition = 'right'
        --         vim.g.floaterm_title = '终端($1/$2)'
        --         vim.g.floaterm_borderchars = '  ─     ' -- ◢◣◥◤
        --         vim.g.floaterm_keymap_toggle = '<A-o>'
        --         vim.g.floaterm_keymap_hide = '<A-t>h'
        --         vim.g.floaterm_keymap_show = '<A-t>s'
        --         vim.g.floaterm_keymap_new = '<A-t>w'
        --         vim.g.floaterm_keymap_kill = '<A-t>k'
        --         vim.g.floaterm_keymap_prev = '<A-t>p'
        --         vim.g.floaterm_keymap_next = '<A-t>n'
        --     end,
        --     config = function()
        --         vim.cmd [[
        --         "hi Floaterm guibg=#1a1a1a
        --         hi FloatermBorder guibg=None guifg=#b19cd9
        --         hi FloatermNC guibg=#0c0c0c
        --         ]]
        --     end
        -- },

        {
            'akinsho/toggleterm.nvim',
            version = "*",
            config = function()
                require("toggleterm").setup {
                    open_mapping = [[<A-o>]],
                    -- direction = 'float',
                }
            end
        },
        {
            'https://gitlab.com/HiPhish/rainbow-delimiters.nvim.git',
            config = function()
                local rainbow_delimiters = require 'rainbow-delimiters'
                require('rainbow-delimiters.setup').setup {
                    strategy = {
                        [''] = rainbow_delimiters.strategy['global'],
                        vim = rainbow_delimiters.strategy['local'],
                    },
                    query = {
                        [''] = 'rainbow-delimiters',
                        lua = 'rainbow-blocks',
                    },
                    priority = {
                        [''] = 110,
                        lua = 210,
                    },
                    highlight = {
                        'RainbowDelimiterRed',
                        'RainbowDelimiterYellow',
                        'RainbowDelimiterBlue',
                        'RainbowDelimiterOrange',
                        'RainbowDelimiterGreen',
                        'RainbowDelimiterViolet',
                        'RainbowDelimiterCyan',
                    },
                }
            end
        },

        {
            "folke/trouble.nvim",
            opts = {
                modes = {
                    diagnostics = {
                        -- preview = {
                        --     type = 'float',
                        --     relative = "editor",
                        --     border = "rounded",
                        --     title = "这里有错误",
                        --     title_pos = "left",
                        --     position = { 0.2 * vim.o.lines, 0.2 * vim.o.columns },
                        --     size = { width = 0.6, height = 0.5 },
                        --     zindex = 200,
                        -- },
                        focus = true,
                        auto_close = true, -- auto close when there are no items
                        -- auto_open = true,
                    },
                }
            }, -- for default options, refer to the configuration section for custom setup.
            commands = { 'trouble' },
            keys = {
                {
                    "<A-i>",
                    "<cmd>Trouble diagnostics toggle<cr>",
                    desc = "Diagnostics (Trouble)",
                },
                -- {
                --     "<leader>eE",
                --     "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
                --     desc = "Buffer Diagnostics (Trouble)",
                -- },
                -- {
                --     "<leader>cs",
                --     "<cmd>Trouble symbols toggle focus=false<cr>",
                --     desc = "Symbols (Trouble)",
                -- },
                -- {
                --     "<leader>cl",
                --     "<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
                --     desc = "LSP Definitions / references / ... (Trouble)",
                -- },
                -- {
                --     "<leader>el",
                --     "<cmd>Trouble loclist toggle<cr>",
                --     desc = "Location List (Trouble)",
                -- },
                -- {
                --     "<leader>eq",
                --     "<cmd>Trouble qflist toggle<cr>",
                --     desc = "Quickfix List (Trouble)",
                -- },
            },
            config = function(_, opts)
                vim.api.nvim_create_autocmd("BufEnter", {
                    group = vim.api.nvim_create_augroup("TroubleClose", { clear = true }),
                    pattern = '{}',
                    callback = function()
                        if vim.opt_local.filetype:get() == "trouble" then
                            local layout = vim.api.nvim_call_function("winlayout", {})
                            if layout[1] == "leaf" and vim.api.nvim_get_option_value("filetype", { buf = vim.api.nvim_win_get_buf(layout[2]) }) == "trouble" and layout[3] == nil then
                                vim.cmd("confirm quit")
                            end
                        end
                    end
                })

                require('trouble').setup(opts)
            end,
        },
        {
            "j-hui/fidget.nvim",
            opts = {},
        },
        {
            "rcarriga/nvim-notify",
            config = function()
                vim.notify = require("notify")
            end
        },
        -- {
        --     "folke/noice.nvim",
        --     event = "VeryLazy",
        --     dependencies = {
        --         "MunifTanjim/nui.nvim",
        --         "rcarriga/nvim-notify",
        --     },
        --     config = function()
        --         require("noice").setup({
        --             lsp = {
        --                 override = {
        --                     ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
        --                     ["vim.lsp.util.stylize_markdown"] = true,
        --                     ["cmp.entry.get_documentation"] = true, -- requires hrsh7th/nvim-cmp
        --                 },
        --             },
        --             presets = {
        --                 bottom_search = true,         -- use a classic bottom cmdline for search
        --                 command_palette = true,       -- position the cmdline and popupmenu together
        --                 long_message_to_split = true, -- long messages will be sent to a split
        --                 inc_rename = false,           -- enables an input dialog for inc-rename.nvim
        --                 lsp_doc_border = true,        -- add a border to hover docs and signature help
        --             },
        --         })
        --     end
        -- },

        {
            'mfussenegger/nvim-dap',
            config = function()
                local dap = require('dap')
                dap.adapters = {
                    lldb = {
                        type = 'executable',
                        command = '/opt/homebrew/bin/lldb-dap', -- adjust as needed, must be absolute path
                        name = 'lldb'
                    }

                }
                dap.configurations = {
                    cpp = {
                        {
                            name = 'Launch',
                            type = 'lldb',
                            request = 'launch',
                            program = function()
                                return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
                            end,
                            cwd = '${workspaceFolder}',
                            stopOnEntry = false,
                            args = {},
                            runInTerminal = false,
                        }
                    }
                }
            end
        },
        {
            'airblade/vim-rooter',
            init = function()
                vim.g.rooter_targets = { '*', 'CMakeLists.txt', '*.go', '*.cc', '*.hh', '*.cpp', '*.hpp', 'go.mod',
                    '*.lua' }
                vim.g.rooter_buftypes = { '' }
                vim.g.rooter_patterns = { 'LICENSE', 'build/CMakeCache.txt', '.git', 'Makefile', 'go.mod', 'init.lua' }
                -- vim.g.rooter_cd_cmd = 'tcd'
            end
        },
        ------------------------------
    },
    install = { colorscheme = { "default" } },
    checker = { enabled = true },
})



vim.cmd [[
    augroup vimStartup
	autocmd!
	autocmd BufReadPost *
	\ let line = line("'\"")
	\ | if line >= 1 && line <= line("$") && &filetype !~# 'commit'
	\      && index(['xxd', 'gitrebase'], &filetype) == -1
	\ |   execute "normal! g`\""
	\ | endif

    augroup END

    command -nargs=0 Config e $MYVIMRC

    cnoremap <C-A>		<Home>
    cnoremap <C-B>		<Left>
    cnoremap <C-D>		<Del>
    cnoremap <C-E>		<End>
    cnoremap <C-F>		<Right>
    cnoremap <C-N>		<Down>
    cnoremap <C-P>		<Up>
    cnoremap <Esc><C-B>	<S-Left>
    cnoremap <Esc><C-F>	<S-Right>

    inoremap <C-E>		<End>

    hi DiagnosticUnderlineError gui=undercurl
    hi DiagnosticUnderlineWarn gui=undercurl
    hi DiagnosticUnderlineInfo gui=undercurl
    hi DiagnosticUnderlineHint gui=undercurl
    hi DiagnosticUnderlineOk gui=undercurl
]]


-- nvchad base46 highlight
-- local load_highlights = function(highlights_list)
--     for _, highlights in ipairs(highlights_list) do
--         for key, value in pairs(highlights) do
--             vim.api.nvim_set_hl(0, key, value)
--         end
--     end
-- end
--
-- local base16 = require("base46.themes.gruvbox").base_16
-- local colors = require("base46.themes.gruvbox").base_30
-- local colorize = require("base46.colors").change_hex_lightness
--
-- local lsp_highlights = {
--     LspReferenceText = { fg = colors.darker_black, bg = colors.white },
--     LspReferenceRead = { fg = colors.darker_black, bg = colors.white },
--     LspReferenceWrite = { fg = colors.darker_black, bg = colors.white },
--
--     -- Lsp Diagnostics
--     DiagnosticHint = { fg = colors.purple },
--     DiagnosticError = { fg = colors.red },
--     DiagnosticWarn = { fg = colors.yellow },
--     DiagnosticInfo = { fg = colors.green },
--     LspSignatureActiveParameter = { fg = colors.black, bg = colors.green },
--
--     RenamerTitle = { fg = colors.black, bg = colors.red },
--     RenamerBorder = { fg = colors.red },
--
--     LspInlayHint = {
--         bg = colorize(colors.black2, vim.o.bg == "dark" and 0 or 3),
--         fg = colors.light_grey,
--     },
--
-- }
--
-- local black2_l = colorize(colors.black2, 6)
-- local cmp_highlights = {
--     CmpItemAbbr = { fg = colors.white },
--     CmpItemAbbrMatch = { fg = colors.blue, bold = true },
--     CmpItemAbbrMatchFuzzy = { link = 'CmpItemAbbrMatch' },
--     CmpDoc = { bg = colors.darker_black },
--     CmpDocBorder = { fg = colors.darker_black, bg = colors.darker_black },
--     CmpSel = { link = "PmenuSel", bold = true },
--     CmpPmenu = { bg = colors.black2, },
--     CmpItemMenu = { fg = colors.light_grey, italic = true },
--
--     CmpItemKindConstant = { fg = base16.base09, bg = black2_l },
--     CmpItemKindFunction = { fg = base16.base0D, bg = black2_l },
--     CmpItemKindIdentifier = { fg = base16.base08, bg = black2_l },
--     CmpItemKindField = { fg = base16.base08, bg = black2_l },
--     CmpItemKindVariable = { fg = base16.base0E, bg = black2_l },
--     CmpItemKindSnippet = { fg = colors.red, bg = black2_l },
--     CmpItemKindText = { fg = base16.base0B, bg = black2_l },
--     CmpItemKindStructure = { fg = base16.base0E, bg = black2_l },
--     CmpItemKindType = { fg = base16.base0A, bg = black2_l },
--     CmpItemKindKeyword = { fg = base16.base07, bg = black2_l },
--     CmpItemKindMethod = { fg = base16.base0D, bg = black2_l },
--     CmpItemKindConstructor = { fg = colors.blue, bg = black2_l },
--     CmpItemKindFolder = { fg = base16.base07, bg = black2_l },
--     CmpItemKindModule = { fg = base16.base0A, bg = black2_l },
--     CmpItemKindProperty = { fg = base16.base08, bg = black2_l },
--     CmpItemKindEnum = { fg = colors.blue, bg = black2_l },
--     CmpItemKindUnit = { fg = base16.base0E, bg = black2_l },
--     CmpItemKindClass = { fg = colors.teal, bg = black2_l },
--     CmpItemKindFile = { fg = base16.base07, bg = black2_l },
--     CmpItemKindInterface = { fg = colors.green, bg = black2_l },
--     CmpItemKindColor = { fg = colors.white, bg = black2_l },
--     CmpItemKindReference = { fg = base16.base05, bg = black2_l },
--     CmpItemKindEnumMember = { fg = colors.purple, bg = black2_l },
--     CmpItemKindStruct = { fg = base16.base0E, bg = black2_l },
--     CmpItemKindValue = { fg = colors.cyan, bg = black2_l },
--     CmpItemKindEvent = { fg = colors.yellow, bg = black2_l },
--     CmpItemKindOperator = { fg = base16.base05, bg = black2_l },
--     CmpItemKindTypeParameter = { fg = base16.base08, bg = black2_l },
--     CmpItemKindCopilot = { fg = colors.green, bg = black2_l },
--     CmpItemKindCodeium = { fg = colors.vibrant_green, bg = black2_l },
--     CmpItemKindTabNine = { fg = colors.baby_pink, bg = black2_l },
--     CmpItemKindSuperMaven = { fg = colors.yellow, bg = black2_l },
-- }
--
-- local ibl_highlights = {
--     IblChar = { fg = colors.line },
--     IblScopeChar = { fg = colors.grey },
--     ["@ibl.scope.underline.1"] = { bg = colors.black2 },
--     ["@ibl.scope.underline.2"] = { bg = colors.black2 },
--     ["@ibl.scope.underline.3"] = { bg = colors.black2 },
--     ["@ibl.scope.underline.4"] = { bg = colors.black2 },
--     ["@ibl.scope.underline.5"] = { bg = colors.black2 },
--     ["@ibl.scope.underline.6"] = { bg = colors.black2 },
--     ["@ibl.scope.underline.7"] = { bg = colors.black2 },
-- }
--
-- local syntax_highlights = {
--     Boolean = { fg = base16.base09 },
--     Character = { fg = base16.base08 },
--     Conditional = { fg = base16.base0E },
--     Constant = { fg = base16.base08 },
--     Define = { fg = base16.base0E, sp = "none" },
--     Delimiter = { fg = base16.base0F },
--     Float = { fg = base16.base09 },
--     Variable = { fg = base16.base05 },
--     Function = { fg = base16.base0D },
--     Identifier = { fg = base16.base08, sp = "none" },
--     Include = { fg = base16.base0D },
--     Keyword = { fg = base16.base0E },
--     Label = { fg = base16.base0A },
--     Number = { fg = base16.base09 },
--     Operator = { fg = base16.base05, sp = "none" },
--     PreProc = { fg = base16.base0A },
--     Repeat = { fg = base16.base0A },
--     Special = { fg = base16.base0C },
--     SpecialChar = { fg = base16.base0F },
--     Statement = { fg = base16.base08 },
--     StorageClass = { fg = base16.base0A },
--     String = { fg = base16.base0B },
--     Structure = { fg = base16.base0E },
--     Tag = { fg = base16.base0A },
--     Todo = { fg = base16.base0A, bg = base16.base01 },
--     Type = { fg = base16.base0A, sp = "none" },
--     Typedef = { fg = base16.base0A },
-- }
--
-- local telescope_highlights = function(style)
--     local tele_highlights = {
--         TelescopePromptPrefix = {
--             fg = colors.red,
--             bg = colors.black2,
--         },
--         TelescopeNormal = { bg = colors.darker_black },
--         TelescopePreviewTitle = {
--             fg = colors.black,
--             bg = colors.green,
--         },
--         TelescopePromptTitle = {
--             fg = colors.black,
--             bg = colors.red,
--         },
--         TelescopeSelection = { bg = colors.black2, fg = colors.white },
--         TelescopeResultsDiffAdd = { fg = colors.green },
--         TelescopeResultsDiffChange = { fg = colors.yellow },
--         TelescopeResultsDiffDelete = { fg = colors.red },
--         TelescopeMatching = { bg = colors.one_bg, fg = colors.blue },
--     }
--     local borderstyle = {
--         borderless = {
--             TelescopeBorder = { fg = colors.darker_black, bg = colors.darker_black },
--             TelescopePromptBorder = { fg = colors.black2, bg = colors.black2 },
--             TelescopePromptNormal = { fg = colors.white, bg = colors.black2 },
--             TelescopeResultsTitle = { fg = colors.darker_black, bg = colors.darker_black },
--             TelescopePromptPrefix = { fg = colors.red, bg = colors.black2 },
--         },
--         bordered = {
--             -- TelescopeBorder = { fg = colors.one_bg3 },
--             -- TelescopePromptBorder = { fg = colors.one_bg3 },
--             -- TelescopePromptNormal = { bg = colors.black },
--             TelescopeResultsTitle = { fg = colors.black, bg = colors.green },
--             -- TelescopePromptPrefix = { fg = colors.red, bg = colors.black },
--             TelescopePromptBorder = { fg = colors.black2, bg = colors.black2 },
--             TelescopePromptNormal = { fg = colors.white, bg = colors.black2 },
--             -- TelescopeResultsTitle = { fg = colors.darker_black, bg = colors.darker_black },
--             TelescopePromptPrefix = { fg = colors.red, bg = colors.black2 },
--
--             TelescopePreviewTitle = { fg = colors.black, bg = colors.blue },
--             TelescopeNormal = { bg = colors.black },
--         }
--     }
--     return vim.tbl_deep_extend('force', tele_highlights, borderstyle[style])
-- end
--
-- load_highlights({ lsp_highlights, cmp_highlights, ibl_highlights, telescope_highlights("bordered"), })
--
-- local loadtheme = function(thm)
--     local g = vim.g
--     local cache_path = vim.g.base46_cache
--     local theme = thm
--     local integrations = {
--         "blankline",
--         "cmp",
--         "defaults",
--         "devicons",
--         "git",
--         "lsp",
--         "mason",
--         "nvimtree",
--         "syntax",
--         "treesitter",
--         "tbline",
--         "telescope",
--     }
--     local M = {}
--
--     M.get_theme_tb = function(type)
--         local name = theme
--         local present1, default_theme = pcall(require, "base46.themes." .. name)
--
--         if present1 then
--             return default_theme[type]
--         else
--             error "No such theme!"
--         end
--     end
--     M.merge_tb = function(...)
--         return vim.tbl_deep_extend("force", ...)
--     end
--
--     local lighten = require("base46.colors").change_hex_lightness
--     local mixcolors = require("base46.colors").mix
--
--     M.extend_default_hl = function(highlights, integration_name)
--         local polish_hl = M.get_theme_tb "polish_hl"
--
--         if polish_hl and polish_hl[integration_name] then
--             highlights = M.merge_tb(highlights, polish_hl[integration_name])
--         end
--
--         return highlights
--     end
--
--     M.get_integration = function(name)
--         local highlights = require("base46.integrations." .. name)
--         return M.extend_default_hl(highlights, name)
--     end
--
--     -- convert table into string
--     M.tb_2str = function(tb)
--         local result = ""
--
--         for hlgroupName, v in pairs(tb) do
--             local hlname = "'" .. hlgroupName .. "',"
--             local hlopts = ""
--
--             for optName, optVal in pairs(v) do
--                 local valueInStr = ((type(optVal)) == "boolean" or type(optVal) == "number") and tostring(optVal)
--                     or '"' .. optVal .. '"'
--                 hlopts = hlopts .. optName .. "=" .. valueInStr .. ","
--             end
--
--             result = result .. "vim.api.nvim_set_hl(0," .. hlname .. "{" .. hlopts .. "})"
--         end
--
--         return result
--     end
--
--     M.str_to_cache = function(filename, str)
--         -- Thanks to https://github.com/nullchilly and https://github.com/EdenEast/nightfox.nvim
--         -- It helped me understand string.dump stuff
--         local lines = "return string.dump(function()" .. str .. "end, true)"
--         local file = io.open(cache_path .. filename, "wb")
--
--         if file then
--             file:write(loadstring(lines)())
--             file:close()
--         end
--     end
--
--     M.compile = function()
--         if not vim.uv.fs_stat(vim.g.base46_cache) then
--             vim.fn.mkdir(cache_path, "p")
--         end
--
--         M.str_to_cache("term", require "base46.term")
--         M.str_to_cache("colors", require "base46.color_vars")
--
--         for _, name in ipairs(integrations) do
--             local hl_str = M.tb_2str(M.get_integration(name))
--
--             if name == "defaults" then
--                 hl_str = "vim.o.tgc=true vim.o.bg='" .. M.get_theme_tb "type" .. "' " .. hl_str
--             end
--
--             M.str_to_cache(name, hl_str)
--         end
--     end
--
--     M.load_all_highlights = function()
--         require("plenary.reload").reload_module "base46"
--         M.compile()
--
--         dofile(vim.g.base46_cache .. "all")
--
--         -- update blankline
--         pcall(function()
--             require("ibl").update()
--         end)
--     end
--
--     return M
-- end
--
-- loadtheme('onedark').load_all_highlights()
-- dofile(vim.g.base46_cache .. "defaults")
