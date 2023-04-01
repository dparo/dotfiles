return {
    -- Theme configurations/generators
    { "rktjmp/lush.nvim" },
    { "tjdevries/colorbuddy.nvim" },

    { "dracula/vim", name = "dracula" },
    { "metalelf0/jellybeans-nvim", dependencies = { "rktjmp/lush.nvim" } },
    { "tjdevries/gruvbuddy.nvim", dependencies = { "tjdevries/colorbuddy.nvim" } },
    { "Th3Whit3Wolf/spacebuddy", dependencies = { "tjdevries/colorbuddy.nvim" } },
    { "catppuccin/nvim", name = "catppuccin" },
    {
        "marko-cerovac/material.nvim",
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
    { "navarasu/onedark.nvim" },

    { "arcticicestudio/nord-vim" },
    {
        "sainnhe/everforest",
        config = function()
            vim.g.everforest_background = "hard"
        end,
    },

    { "sainnhe/sonokai" },
    {
        "sainnhe/gruvbox-material",
        config = function()
            vim.g.gruvbox_material_background = "hard"
        end,
    },
    {
        "EdenEast/nightfox.nvim",
        config = function()
            require("nightfox").setup {
                options = {
                    dim_inactive = true,
                },
            }
        end,
    },

    { "tomasiser/vim-code-dark" },

    { "tomasr/molokai" },
    {
        "ellisonleao/gruvbox.nvim",
        config = function()
            vim.g.gruvbox_inverse = 0
            vim.g.gruvbox_contrast_dark = "hard"
            vim.g.gruvbox_contrast_light = "hard"
        end,
    },
    {
        "ayu-theme/ayu-vim",
        config = function()
            vim.g.ayucolor = "dark"
        end,
    },
    { "mhartington/oceanic-next" },
    {
        "folke/tokyonight.nvim",
        config = function()
            vim.g.tokyonight_style = "storm"
        end,
    },

    { "Everblush/everblush.nvim" },

    {
        "rebelot/kanagawa.nvim",

        config = function()
            require("kanagawa").setup {
                undercurl = true, -- enable undercurls
                commentStyle = { italic = false },
                functionStyle = {},
                keywordStyle = { italic = false },
                statementStyle = { bold = false },
                typeStyle = {},
                variablebuiltinStyle = { italic = false },
                specialReturn = true, -- special highlight for the return keyword
                specialException = true, -- special highlight for exception handling keywords
                transparent = false, -- do not set background color
                dimInactive = false, -- dim inactive window `:h hl-NormalNC`
                globalStatus = false, -- adjust window separators highlight for laststatus=3
                terminalColors = true, -- define vim.g.terminal_color_{0,17}
                theme = "default", -- Load "default" theme or the experimental "light" theme
            }
        end,
    },
}