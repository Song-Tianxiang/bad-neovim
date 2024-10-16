local hl_set = vim.api.nvim_set_hl
local colors = require("base46").get_theme_tb "base_30"

hl_set(0, "DiagnosticUnderlineError", {
    sp = colors.red,
    undercurl = true,
})

hl_set(0, "DiagnosticUnderlineWarn", {
    sp = colors.yellow,
    undercurl = true,
})

hl_set(0, "DiagnosticUnderlineInfo", {
    sp = colors.green,
    undercurl = true,
})

hl_set(0, "DiagnosticUnderlineHint", {
    sp = colors.purple,
    undercurl = true,
})
