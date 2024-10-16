local del_cmd = vim.api.nvim_del_user_command
local new_cmd = vim.api.nvim_create_user_command

del_cmd("Nvdash")
del_cmd("NvCheatsheet")

new_cmd("Cheatsheet", function()
    require("nvchad.cheatsheet." .. require "nvconfig".cheatsheet.theme)()
end, {})
