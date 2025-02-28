local function theme_overrides()
    vim.o.guicursor =
    [[n:block-Cursor,v:hor10-vCursor,i:ver100-iCursor,n-c-ci-cr-sm-v:blinkon0,i:blinkon10,i:blinkwait10,c-ci-cr:block-cCursor,c:block-cCursor]]

    -- Default to the background color configured for the terminal
    if false then
        vim.api.nvim_set_hl(0, "Normal", { ctermbg = "none", bg = "none" })
    end

    vim.api.nvim_set_hl(0, "Cursor", { bg = "#00ff7f", fg = "#000002" })
    vim.api.nvim_set_hl(0, "Todo", { bg = "none" })
    vim.api.nvim_set_hl(0, "Fixme", { bg = "none" })
    vim.api.nvim_set_hl(0, "XXX", { bg = "none" })

    if true then
        vim.api.nvim_set_hl(0, "Visual", { fg = "#ffffff", bg = "#0000ff", ctermbg = "blue", ctermfg = "white" })
    end

    if false then
        -- Avoid thick lines in vertical split generated by some themes
        vim.api.nvim_set_hl(0, "VertSplit",
            { link = "default", fg = "none", bg = "none", ctermfg = "none", ctermbg = "none" })
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

        vim.api.nvim_set_hl(0, "DiagnosticUnderlineError", {
            cterm = { undercurl = true },
            ctermbg = "none",
            ctermfg = "none",
            undercurl = true,
            sp = "#FF0000",
            fg = "none",
            bg = "none",
        })
        vim.api.nvim_set_hl(0, "DiagnosticUnderlineWarning", {
            cterm = { undercurl = true },
            ctermbg = "none",
            ctermfg = "none",
            undercurl = true,
            sp = "#FFFF00",
            fg = "none",
            bg = "none",
        })
        vim.api.nvim_set_hl(0, "DiagnosticUnderlineInformation", {
            cterm = { undercurl = true },
            ctermbg = "none",
            ctermfg = "none",
            undercurl = true,
            sp = "#FFFF00",
            fg = "none",
            bg = "none",
        })
        vim.api.nvim_set_hl(0, "DiagnosticUnderlineHint", {
            cterm = { undercurl = true },
            ctermbg = "none",
            ctermfg = "none",
            undercurl = true,
            sp = "#AAFFAA",
            fg = "none",
            bg = "none",
        })
    end

    -- Vscode colors for Cmp Completion window, Some themes do not set good defaults for this
    if false then
        vim.api.nvim_set_hl(0, "CmpItemAbbrDeprecated", { strikethrough = true, bg = "none", fg = "#808080" })
        vim.api.nvim_set_hl(0, "CmpItemAbbrMatch", { bg = "none", fg = "#569CD6" })
        vim.api.nvim_set_hl(0, "CmpItemAbbrMatchFuzzy", { bg = "none", fg = "#569CD6" })
        vim.api.nvim_set_hl(0, "CmpItemKindVariable", { bg = "none", fg = "#9CDCFE" })
        vim.api.nvim_set_hl(0, "CmpItemKindInterface", { bg = "none", fg = "#9CDCFE" })
        vim.api.nvim_set_hl(0, "CmpItemKindText", { bg = "none", fg = "#9CDCFE" })
        vim.api.nvim_set_hl(0, "CmpItemKindFunction", { bg = "none", fg = "#C586C0" })
        vim.api.nvim_set_hl(0, "CmpItemKindMethod", { bg = "none", fg = "#C586C0" })
        vim.api.nvim_set_hl(0, "CmpItemKindKeyword", { bg = "none", fg = "#D4D4D4" })
        vim.api.nvim_set_hl(0, "CmpItemKindProperty", { bg = "none", fg = "#D4D4D4" })
        vim.api.nvim_set_hl(0, "CmpItemKindUnit", { bg = "none", fg = "#D4D4D4" })
    end

    -- Nvim Web DevIcons might need to be re-called in a `Colorscheme`
    -- to re-apply cleared highlights if the color scheme changes
    local status_ok, nvim_web_devicons = pcall(require, "nvim-web-devicons")
    if status_ok then
        nvim_web_devicons.setup {}
    end
end

core.utils.augroup("USER_THEME_OVERRIDES", {
    { { "ColorScheme" }, { pattern = "*", callback = theme_overrides } },
})

local signs = {
    { name = "DiagnosticSignError", text = "", numhl = "" },
    { name = "DiagnosticSignWarn", text = "", numhl = "" },
    { name = "DiagnosticSignHint", text = "", numhl = "" },
    { name = "DiagnosticSignInfo", text = "", numhl = "" },
    { name = "DapBreakpoint", text = "", numhl = "DapBreakpoint" },
    { name = "DapStopped", text = "", numhl = "DapStopped" },
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

---
local theme = vim.env.NVIM_THEME or "catppuccin"
---

local theme_list = {
    default = {
        name = "default"
    },
    catppuccin = {
        repo = "catppuccin/nvim",
        dependencies = {},
        colorscheme = "catppuccin-macchiato",
        config = function()
            require("catppuccin").setup({
                flavour = "macchiato",
                transparent_background = true,
            })
        end,
    },
    rosepine = {
        repo = "rose-pine/neovim",
        dependencies = {},
        name = "rosepine",
        colorscheme = "rose-pine",
    },
    onedark = {
        repo = "navarasu/onedark.nvim",
        dependencies = {},
        colorscheme = "onedark",
        config = function()
            require("onedark").setup {
                style = "darker",
            }
        end,
    },
    onedarkpro = {
        repo = "olimorris/onedarkpro.nvim",
        dependencies = {},
        colorscheme = "onedark",
        config = function()
            require("onedarkpro").setup {}
        end,
    },
    gruvbuddy = {
        repo = "tjdevries/gruvbuddy.nvim",
        dependencies = { "tjdevries/colorbuddy.nvim" },
        load = function()
            require("colorbuddy").colorscheme "gruvbuddy"
        end,
        config = function() end,
    },
    tokyonight = {
        repo = "folke/tokyonight.nvim",
        dependencies = {},
        colorscheme = "tokyonight",
        config = function()
            require("tokyonight").setup {
                style = "night",
                light_style = "day",
            }
        end,
    },
    gruvbox = {
        repo = "ellisonleao/gruvbox.nvim",
        dependencies = {},
        colorscheme = "gruvbox",
        config = function()
            vim.g.gruvbox_inverse = 0
            require("gruvbox").setup {
                inverse = false,
                contrast = "hard",
            }
        end,
    },
    jellybeans = {
        repo = "metalelf0/jellybeans-nvim",
        dependencies = {},
        colorscheme = "jellybeans",
        config = function() end,
    },
    material = {
        repo = "marko-cerovac/material.nvim",
        dependencies = {},
        colorscheme = "material",
        config = function()
            vim.g.material_style = "darker"
            require("material").setup {
                custom_highlights = {
                    Special = "#FFFFFF",
                    SpecialChar = "#FFFFFF",
                    cSpecialCharacter = "#FFFFFF",
                    TSStringEscape = "#FFFFFF",
                    TSStringSpecial = "#FFFFFF",
                },
            }
        end,
    },
    nightfox = {
        repo = "EdenEast/nightfox.nvim",
        dependencies = {},
        colorscheme = "nightfox",
        config = function()
            require("nightfox").setup {
                options = {
                    dim_inactive = true,
                },
            }
        end,
    },
    kanagawa = {
        repo = "rebelot/kanagawa.nvim",
        dependencies = {},
        colorscheme = "kanagawa",
        config = function()
            require("kanagawa").setup {
                undercurl = true, -- enable undercurls
                commentStyle = { italic = false },
                functionStyle = {},
                keywordStyle = { italic = false },
                statementStyle = { bold = false },
                typeStyle = {},
                variablebuiltinStyle = { italic = false },
                specialReturn = true,    -- special highlight for the return keyword
                specialException = true, -- special highlight for exception handling keywords
                transparent = false,     -- do not set background color
                dimInactive = false,     -- dim inactive window `:h hl-NormalNC`
                globalStatus = false,    -- adjust window separators highlight for laststatus=3
                terminalColors = true,   -- define vim.g.terminal_color_{0,17}
                theme = "default",       -- Load "default" theme or the experimental "light" theme
            }
        end,
    },
    everforest = {
        repo = "sainnhe/everforest",
        dependencies = {},
        colorscheme = "everforest",
        config = function()
            vim.g.everforest_background = "hard"
        end,
    },
    gruvbox_material = {
        repo = "sainnhe/gruvbox-material",
        dependencies = {},
        colorscheme = "gruvbox-material",
        config = function()
            vim.g.gruvbox_material_background = "hard"
        end,
    },
}

---
---
---

local t = theme_list[theme]
if t ~= nil and t.name ~= "default" then
    t.name = theme
    t.colorscheme = t.colorscheme or t.name

    return {

        --
        -- Run `TermcolorsShow` to dump neovim theme to a kitty.conf compatible theme file
        --
        {
            t.repo,
            lazy = false,
            priority = 1000,
            name = theme,
            dependencies = t.dependencies,
            config = function()
                if t.config ~= nil and type(t.config) == "function" then
                    t.config()
                end

                if vim.o.termguicolors == true then
                    if t.load ~= nil and type(t.load) == "function" then
                        t.load()
                    elseif t.colorscheme ~= nil and t.colorscheme ~= "" then
                        vim.cmd([[colorscheme ]] .. t.colorscheme)
                    end
                end
            end,
        },
    }
end
