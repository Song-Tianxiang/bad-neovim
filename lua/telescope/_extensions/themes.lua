local pickers = require "telescope.pickers"
local finders = require "telescope.finders"
local previewers = require "telescope.previewers"

local conf = require("telescope.config").values
local actions = require "telescope.actions"
local action_set = require "telescope.actions.set"
local action_state = require "telescope.actions.state"

local function reload_theme(name)
    -- require("nvconfig").ui.theme = name
    local base46tb = vim.g.base46
    base46tb.theme = name
    vim.g.base46 = base46tb
    require("base46").load_all_highlights()
    vim.api.nvim_exec_autocmds("User", { pattern = "ThemeReload" })
end

vim.g.old_old_theme = vim.g.base46.theme

local function switcher()
    local bufnr = vim.api.nvim_get_current_buf()

    -- show current buffer content in previewer
    local previewer = previewers.new_buffer_previewer {
        define_preview = function(self, _)
            -- add content
            local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
            vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, lines)

            -- add syntax highlighting in previewer
            local ft = (vim.filetype.match { buf = bufnr } or "diff"):match "%w+"
            require("telescope.previewers.utils").highlighter(self.state.bufnr, ft)
        end,
    }

    local thms = function()
        local default_themes = vim.fn.readdir(vim.fn.stdpath "data" .. "/lazy/base46/lua/base46/themes")
        for index, theme in ipairs(default_themes) do
            default_themes[index] = theme:match "(.+)%..+"
        end
        return default_themes
    end

    -- our picker function: colors
    local picker = pickers.new {
        prompt_title = "󱥚 Select A Theme",
        previewer = previewer,
        finder = finders.new_table {
            results = thms()
        },
        sorter = conf.generic_sorter(),

        attach_mappings = function(prompt_bufnr)
            -- reload theme while typing
            vim.schedule(function()
                vim.api.nvim_create_autocmd("TextChangedI", {
                    buffer = prompt_bufnr,
                    callback = function()
                        if action_state.get_selected_entry() then
                            reload_theme(action_state.get_selected_entry()[1])
                        end
                    end,
                })
            end)
            -- reload theme on cycling
            actions.move_selection_previous:replace(function()
                action_set.shift_selection(prompt_bufnr, -1)
                reload_theme(action_state.get_selected_entry()[1])
            end)
            actions.move_selection_next:replace(function()
                action_set.shift_selection(prompt_bufnr, 1)
                reload_theme(action_state.get_selected_entry()[1])
            end)

            ------------ save theme to chadrc on enter ----------------
            actions.select_default:replace(function()
                if action_state.get_selected_entry() then
                    local vimrc = vim.fn.stdpath "config" .. "/init.lua"
                    local old_theme = vim.g.old_old_theme
                    vim.g.old_old_theme = action_state.get_selected_entry()[1]
                    old_theme = '"' .. old_theme .. '"'

                    local theme = '"' .. action_state.get_selected_entry()[1] .. '"'

                    local file = io.open(vimrc, "r")
                    local added_pattern = string.gsub(old_theme, "-", "%%-") -- add % before - if exists
                    local new_content = file:read("*all"):gsub(added_pattern, theme)

                    file = io.open(vimrc, "w")
                    file:write(new_content)
                    file:close()

                    actions.close(prompt_bufnr)
                end
            end)
            return true
        end,
    }

    picker:find()
end

return require("telescope").register_extension {
    exports = { themes = switcher },
}
