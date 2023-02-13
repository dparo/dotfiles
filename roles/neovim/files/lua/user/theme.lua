vim.o.background = "dark"
vim.o.guifont = "JetBrainsMono Nerd Font:h10.0"

local signs = {
    { name = "DiagnosticSignError", text = "" },
    { name = "DiagnosticSignWarn", text = "" },
    { name = "DiagnosticSignHint", text = "" },
    { name = "DiagnosticSignInfo", text = "" },
}

vim.diagnostic.config {
    underline = true,
    virtual_text = true,
    signs = signs,
    severity_sort = true,
}

for _, sign in ipairs(signs) do
    vim.fn.sign_define(sign.name, { texthl = sign.name, text = sign.text, numhl = "" })
end

if vim.regex([[^\(linux\|rxvt\|interix\|putty\)\(-.*\)\?$]]):match_str(vim.env.TERM) then
    vim.o.termguicolors = true
elseif vim.regex([[^\(tmux\|screen\|iterm\|xterm\|vte\|gnome\|xterm-kitty\|kitty\|alacritty\)\(-.*\)\?$]]):match_str(vim.env.TERM) then
    vim.o.termguicolors = true

    -- require('colorbuddy').colorscheme('gruvbuddy')
    -- user.utils.load_color_scheme 'nightfox'
    vim.g.material_style = "darker"
    -- user.utils.load_color_scheme "material"

    -- user.utils.load_color_scheme "tokyonight-storm"
    user.utils.load_color_scheme "catppuccin-mocha"
end

local function theme_overrides()
    vim.o.guicursor =
        [[n:block-Cursor,v:hor10-vCursor,i:ver100-iCursor,n-c-ci-cr-sm-v:blinkon0,i:blinkon10,i:blinkwait10,c-ci-cr:block-cCursor,c:block-cCursor]]

    vim.api.nvim_set_hl(0, "Todo", { bg = "none" })
    vim.api.nvim_set_hl(0, "Fixme", { bg = "none" })
    vim.api.nvim_set_hl(0, "XXX", { bg = "none" })
    -- vim.api.nvim_set_hl(0, "Visual", { fg = "#ffffff", bg = "#0000ff", ctermbg = "blue", ctermfg = "white" })

    if false then
        -- Avoid thick lines in vertical split generated by some themes
        vim.api.nvim_set_hl(0, "VertSplit", { link = "default", fg = "none", bg = "none", ctermfg = "none", ctermbg = "none" })
    end

    if false then
        vim.api.nvim_set_hl(0, "DiagnosticSignError", { ctermfg = "red", fg = "#FF9999" })
        vim.api.nvim_set_hl(0, "DiagnosticSignWarning", { ctermfg = "yellow", fg = "#FFFF99" })
        vim.api.nvim_set_hl(0, "DiagnosticSignInformation", { ctermfg = "yellow", fg = "#FFFF99" })
        vim.api.nvim_set_hl(0, "DiagnosticSignHint", { ctermfg = "green", fg = "#99FF99" })

        vim.api.nvim_set_hl(0, "DiagnosticUnderlineError", { link = "DiagnosticSignError" })
        vim.api.nvim_set_hl(0, "DiagnosticUnderlineWarning", { link = "DiagnosticSignWarning" })
        vim.api.nvim_set_hl(0, "DiagnosticUnderlineInformation", { link = "DiagnosticSignInformation" })
        vim.api.nvim_set_hl(0, "DiagnosticUnderlineHint", { link = "DiagnosticSignHint" })

        vim.api.nvim_set_hl(
            0,
            "DiagnosticUnderlineError",
            { cterm = { undercurl = true }, ctermbg = "none", ctermfg = "none", undercurl = true, sp = "#FF0000", fg = "none", bg = "none" }
        )
        vim.api.nvim_set_hl(
            0,
            "DiagnosticUnderlineWarning",
            { cterm = { undercurl = true }, ctermbg = "none", ctermfg = "none", undercurl = true, sp = "#FFFF00", fg = "none", bg = "none" }
        )
        vim.api.nvim_set_hl(
            0,
            "DiagnosticUnderlineInformation",
            { cterm = { undercurl = true }, ctermbg = "none", ctermfg = "none", undercurl = true, sp = "#FFFF00", fg = "none", bg = "none" }
        )
        vim.api.nvim_set_hl(
            0,
            "DiagnosticUnderlineHint",
            { cterm = { undercurl = true }, ctermbg = "none", ctermfg = "none", undercurl = true, sp = "#AAFFAA", fg = "none", bg = "none" }
        )
    end

    -- Vscode colors for Cmp Completion window, Some themes do not set good defaults for this
    if false then
        vim.api.nvim_set_hl(0, "CmpItemAbbrDeprecated", { default, strikethrough = true, bg = "none", fg = "#808080" })
        vim.api.nvim_set_hl(0, "CmpItemAbbrMatch", { default, bg = "none", fg = "#569CD6" })
        vim.api.nvim_set_hl(0, "CmpItemAbbrMatchFuzzy", { default, bg = "none", fg = "#569CD6" })
        vim.api.nvim_set_hl(0, "CmpItemKindVariable", { default, bg = "none", fg = "#9CDCFE" })
        vim.api.nvim_set_hl(0, "CmpItemKindInterface", { default, bg = "none", fg = "#9CDCFE" })
        vim.api.nvim_set_hl(0, "CmpItemKindText", { default, bg = "none", fg = "#9CDCFE" })
        vim.api.nvim_set_hl(0, "CmpItemKindFunction", { default, bg = "none", fg = "#C586C0" })
        vim.api.nvim_set_hl(0, "CmpItemKindMethod", { default, bg = "none", fg = "#C586C0" })
        vim.api.nvim_set_hl(0, "CmpItemKindKeyword", { default, bg = "none", fg = "#D4D4D4" })
        vim.api.nvim_set_hl(0, "CmpItemKindProperty", { default, bg = "none", fg = "#D4D4D4" })
        vim.api.nvim_set_hl(0, "CmpItemKindUnit", { default, bg = "none", fg = "#D4D4D4" })
    end

    -- Nvim Web DevIcons might need to be re-called in a `Colorscheme`
    -- to re-apply cleared highlights if the color scheme changes
    local status_ok, nvim_web_devicons = pcall(require, "nvim-web-devicons")
    if status_ok then
        nvim_web_devicons.setup {}
    end
end

theme_overrides()

--- Autocommand for theme overrides
core.utils.augroup("USER_THEME_OVERRIDES", {
    { { "ColorScheme" }, { group = theme_overrides_aucmd, pattern = "*", callback = theme_overrides } },
})
