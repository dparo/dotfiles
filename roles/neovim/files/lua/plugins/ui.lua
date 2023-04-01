return {

    { "nvim-lua/plenary.nvim" },
    {
        "rcarriga/nvim-notify",
        config = function()
            require("notify").setup {
                stages = "slide",
                background_colour = "#000000",
            }
        end,
    },
    { "nvim-lua/popup.nvim", dependencies = { "nvim-lua/plenary.nvim" } },

        --  With the release of Neovim 0.6 we were given the start of extensible core UI hooks
    -- (vim.ui.select and vim.ui.input). They exist to allow plugin authors
    -- to override them with improvements upon the default behavior,
    -- so that's exactly what this plugin does.
    {
        "https://github.com/stevearc/dressing.nvim",
        dependencies = { "nvim-telescope/telescope.nvim" },
        config = function()
            require("dressing").setup {}
        end,
    },

    {
        "folke/trouble.nvim",
        config = function()
            require("trouble").setup {}
        end,
    },
    -- Web dev icons, requires font support. Use NerdFonts in your terminal
    {
        "nvim-tree/nvim-web-devicons",
        config = function()
            require("nvim-web-devicons").setup {}
        end,
    },

    -- Better status line
    {
        "hoob3rt/lualine.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = function()
            -- Eviline config for lualine
            -- Author: shadmansaleh
            -- Credit: glepnir
            local lualine = require "lualine"

            -- Color table for highlights
            -- stylua: ignore
            local colors = {
                bg       = '#202328',
                fg       = '#bbc2cf',
                yellow   = '#ECBE7B',
                cyan     = '#008080',
                darkblue = '#081633',
                green    = '#98be65',
                orange   = '#FF8800',
                violet   = '#a9a1e1',
                magenta  = '#c678dd',
                blue     = '#51afef',
                red      = '#ec5f67',
            }

            local conditions = {
                buffer_not_empty = function()
                    return vim.fn.empty(vim.fn.expand "%:t") ~= 1
                end,
                hide_in_width = function()
                    return vim.fn.winwidth(0) > 80
                end,
                check_git_workspace = function()
                    local filepath = vim.fn.expand "%:p:h"
                    local gitdir = vim.fn.finddir(".git", filepath .. ";")
                    return gitdir and #gitdir > 0 and #gitdir < #filepath
                end,
            }

            -- Config
            local config = {
                options = {
                    globalstatus = true,
                    icons_enabled = true,
                    -- Disable sections and component separators
                    component_separators = "",
                    section_separators = "",
                    theme = {
                        -- We are going to use lualine_c an lualine_x as left and
                        -- right section. Both are highlighted by c theme .  So we
                        -- are just setting default looks o statusline
                        normal = { c = { fg = colors.fg, bg = colors.bg } },
                        inactive = { c = { fg = colors.fg, bg = colors.bg } },
                    },
                },
                sections = {
                    -- these are to remove the defaults
                    lualine_a = {},
                    lualine_b = {},
                    lualine_y = {},
                    lualine_z = {},
                    -- These will be filled later
                    lualine_c = {},
                    lualine_x = {},
                },
                inactive_sections = {
                    -- these are to remove the defaults
                    lualine_a = {},
                    lualine_b = {},
                    lualine_y = {},
                    lualine_z = {},
                    lualine_c = {},
                    lualine_x = {},
                },
            }

            -- Inserts a component in lualine_c at left section
            local function ins_left(component)
                table.insert(config.sections.lualine_c, component)
            end

            -- Inserts a component in lualine_x ot right section
            local function ins_right(component)
                table.insert(config.sections.lualine_x, component)
            end

            ins_left {
                function()
                    return "▊"
                end,
                color = { fg = colors.blue }, -- Sets highlighting of component
                padding = { left = 0, right = 1 }, -- We don't need space before this
            }

            ins_left {
                -- mode component
                function()
                    return ""
                end,
                color = function()
                    -- auto change color according to neovims mode
                    local mode_color = {
                        n = colors.red,
                        i = colors.green,
                        v = colors.blue,
                        [""] = colors.blue,
                        V = colors.blue,
                        c = colors.magenta,
                        no = colors.red,
                        s = colors.orange,
                        S = colors.orange,
                        [""] = colors.orange,
                        ic = colors.yellow,
                        R = colors.violet,
                        Rv = colors.violet,
                        cv = colors.red,
                        ce = colors.red,
                        r = colors.cyan,
                        rm = colors.cyan,
                        ["r?"] = colors.cyan,
                        ["!"] = colors.red,
                        t = colors.red,
                    }
                    return { fg = mode_color[vim.fn.mode()] }
                end,
                padding = { right = 1 },
            }

            ins_left {
                -- filesize component
                "filesize",
                cond = conditions.buffer_not_empty,
            }

            ins_left {
                "filename",
                cond = conditions.buffer_not_empty,
                color = { fg = colors.magenta, gui = "bold" },
            }

            ins_left { "location" }

            ins_left { "progress", color = { fg = colors.fg, gui = "bold" } }

            ins_left {
                "diagnostics",
                sources = { "nvim_diagnostic" },
                symbols = { error = " ", warn = " ", info = " " },
                diagnostics_color = {
                    color_error = { fg = colors.red },
                    color_warn = { fg = colors.yellow },
                    color_info = { fg = colors.cyan },
                },
            }

            -- Insert mid section. You can make any number of sections in neovim :)
            -- for lualine it's any number greater then 2
            ins_left {
                function()
                    return "%="
                end,
            }

            ins_left {
                -- Lsp server name .
                function()
                    local msg = "No Active Lsp"
                    local buf_ft = vim.api.nvim_buf_get_option(0, "filetype")
                    local clients = vim.lsp.get_active_clients()
                    if next(clients) == nil then
                        return msg
                    end
                    for _, client in ipairs(clients) do
                        local filetypes = client.config.filetypes
                        if filetypes and vim.fn.index(filetypes, buf_ft) ~= -1 then
                            return client.name
                        end
                    end
                    return msg
                end,
                icon = " LSP:",
                color = { fg = "#ffffff", gui = "bold" },
            }

            -- Add components to right sections
            ins_right {
                "o:encoding", -- option component same as &encoding in viml
                fmt = string.upper, -- I'm not sure why it's upper case either ;)
                cond = conditions.hide_in_width,
                color = { fg = colors.green, gui = "bold" },
            }

            ins_right {
                "fileformat",
                fmt = string.upper,
                icons_enabled = false, -- I think icons are cool but Eviline doesn't have them. sigh
                color = { fg = colors.green, gui = "bold" },
            }

            ins_right {
                "branch",
                icon = "",
                color = { fg = colors.violet, gui = "bold" },
            }

            ins_right {
                "diff",
                -- Is it me or the symbol for modified us really weird
                symbols = { added = " ", modified = "柳 ", removed = " " },
                diff_color = {
                    added = { fg = colors.green },
                    modified = { fg = colors.orange },
                    removed = { fg = colors.red },
                },
                cond = conditions.hide_in_width,
            }

            ins_right {
                function()
                    return "▊"
                end,
                color = { fg = colors.blue },
                padding = { left = 1 },
            }

            -- Now don't forget to initialize lualine
            lualine.setup(config)

        end,
    },

    {
        "folke/which-key.nvim",
        config = function()
            require("which-key").setup {
                icons = {
                    breadcrumb = "»", -- symbol used in the command line area that shows your active key combo
                    separator = "  ", -- symbol used between a key and it's label
                    group = "+", -- symbol prepended to a group
                },
                spelling = {
                    enabled = true,
                },
                popup_mappings = {
                    scroll_down = "<c-d>", -- binding to scroll down inside the popup
                    scroll_up = "<c-u>", -- binding to scroll up inside the popup
                },

                window = {
                    border = "none", -- none/single/double/shadow
                },

                layout = {
                    spacing = 3, -- spacing between columns
                },
            }
        end,
    },

    {
        "nvim-tree/nvim-tree.lua",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = function()
            require("nvim-tree").setup {
                hijack_netrw = false,
                disable_netrw = false,
                open_on_setup = false,
                hijack_directories = {
                    enable = false,
                    auto_open = false,
                },
                view = {
                    adaptive_size = true,
                    width = "40%",
                },
                actions = {
                    open_file = {
                        window_picker = {
                            enable = true,
                            chars = "123456780ABCDEFGHIJKLMNOPQRSTUVWXYXZ",
                        },
                    },
                },
            }
        end,
    },


    {
        "akinsho/bufferline.nvim",
        version = "v3.*",
        dependencies = "nvim-tree/nvim-web-devicons",
        config = function()
            require("bufferline").setup {}
        end,
    },


    -- Dashboard startup page
    {
        "goolord/alpha-nvim",
        config = function()
            require("alpha").setup(require("alpha.themes.dashboard").config)
        end,
    },

     ----
    ---- Plugins to manage windows
    ----
    {
        "christoomey/vim-tmux-navigator",
        config = function()
            vim.g.tmux_navigator_no_mappings = 1
        end,
    },
    {
        "akinsho/toggleterm.nvim",
        config = function()
            require("toggleterm").setup {
                -- size can be a number or function which is passed the current terminal
                size = function(term)
                    if term.direction == "horizontal" then
                        return 15
                    elseif term.direction == "vertical" then
                        return vim.o.columns * 0.4
                    end
                end,
                open_mapping = [[<F4>]],
                start_in_insert = true,
                insert_mappings = true, -- whether or not the open mapping applies in insert mode
                persist_size = true,
                direction = "horizontal",
                close_on_exit = true, -- close the terminal window when the process exits
                shell = vim.o.shell, -- change the default shell
                -- This field is only relevant if direction is set to 'float'
                float_opts = {
                    winblend = 3,
                    highlights = {
                        border = "Normal",
                        background = "Normal",
                    },
                },
            }
        end,
    },

    -- Clipboard manager neovim plugin with telescope integration
    {
        "AckslD/nvim-neoclip.lua",
        dependencies = {
            "nvim-telescope/telescope.nvim",
        },
        config = function()
            require("neoclip").setup {
                default_register = "+",
                keys = {
                    telescope = {
                        i = {
                            select = "<tab>",
                            paste = "<c-p>",
                            paste_behind = "<cr>",
                            replay = "<c-q>",
                            custom = {},
                        },
                        n = {
                            select = "<Tab>",
                            paste = "p",
                            paste_behind = "<cr>",
                            replay = "q",
                            custom = {},
                        },
                    },
                },
            }
        end,
    },

}