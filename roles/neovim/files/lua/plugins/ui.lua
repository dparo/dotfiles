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
        "iamcco/markdown-preview.nvim",
        cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
        ft = { "markdown", "plantuml", "dot" },
        -- build = function()
        --     vim.fn["mkdp#util#install"]()
        -- end,
        build = "cd app && yarn install",
        init = function()
            vim.g.mkdp_filetypes = { "markdown", "plantuml", "dot" }
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
        enabled = true,
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = function()
            require("lualine").setup {
                options = {
                    -- theme = "tokyonight",
                    theme = "auto",
                    -- enable global statusline (have a single statusline at bottom of neovim instead of one for  every window)
                    globalstatus = true,
                },
                sections = {
                    lualine_a = {'mode'},
                    lualine_b = {'branch', 'diff', 'diagnostics'},
                    lualine_c = { { 'filename', path = 1} },
                    lualine_x = {'encoding', 'fileformat', 'filetype'},
                    lualine_y = {'progress'},
                    lualine_z = {'location'}
                },
                winbar = {
                    lualine_c = {
                        {
                            function()
                                return require("nvim-navic").get_location()
                            end,
                            cond = function()
                                return require("nvim-navic").is_available()
                            end
                        },
                    }
                }
            }
        end,
    },

    {
        "folke/which-key.nvim",
        config = function()
            require("which-key").setup {
                icons = {
                    breadcrumb = "»", -- symbol used in the command line area that shows your active key combo
                    separator = "➜", -- symbol used between a key and it's label
                    group = "+", -- symbol prepended to a group
                },
                spelling = {
                    enabled = true,
                },
                keys = {
                    scroll_down = "<c-d>", -- binding to scroll down inside the popup
                    scroll_up = "<c-u>", -- binding to scroll up inside the popup
                },

                win = {
                    border = "none", -- none/single/double/shadow
                },

                layout = {
                    spacing = 3, -- spacing between columns
                },
            }
        end,
    },

    {
        "stevearc/oil.nvim",
        config = function()
            require("oil").setup {
                columns = {
                    "permissions",
                    "size",
                    "mtime",
                    "icon",
                },
                view_options = {
                    -- Show files and directories that start with "."
                    show_hidden = true,
                },
            }
            vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })
            vim.keymap.set("n", "<leader>-", "<CMD>Oil<CR>", { desc = "Open parent directory" })
        end,
    },
    {
        "nvim-tree/nvim-tree.lua",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = function()
            require("nvim-tree").setup {
                disable_netrw = false,
                hijack_netrw = false,
                hijack_directories = {
                    enable = false,
                    auto_open = true,
                },
                sort = {
                    sorter = "case_sensitive",
                },
                view = {
                    adaptive_size = true,
                    width = "33%",
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
        enabled = false,
        config = function()
            require("bufferline").setup {}
        end,
    },

    -- Dashboard startup page
    {
        "nvimdev/dashboard-nvim",
        event = "VimEnter",
        enabled = false,
        config = function()
            require("dashboard").setup {
                change_to_vcs_root = true,
                config = {
                    shortcut = {

                        {
                            desc = "  New file ",
                            action = "enew",
                            group = "@string",
                            key = "n",
                        },
                        {
                            desc = " 󰚰  Update ",
                            action = "Lazy sync",
                            group = "@string",
                            key = "u",
                        },
                        {
                            desc = "   File/path ",
                            action = "Telescope find_files find_command=rg,--hidden,--files",
                            group = "@string",
                            key = "f",
                        },
                        {
                            desc = " 󰩈  Quit ",
                            action = "q!",
                            group = "@macro",
                            key = "q",
                        },
                    },
                    week_header = {
                        enable = true,
                    },
                },
            }
        end,
        dependencies = { { "nvim-tree/nvim-web-devicons" } },
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

    {
        "folke/noice.nvim",
        enabled = false,
        event = "VeryLazy",
        config = function()
            require("noice").setup {
                lsp = {
                    -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
                    override = {
                        ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
                        ["vim.lsp.util.stylize_markdown"] = true,
                        ["cmp.entry.get_documentation"] = true,
                    },
                },
                -- you can enable a preset for easier configuration
                presets = {
                    bottom_search = true, -- use a classic bottom cmdline for search
                    command_palette = true, -- position the cmdline and popupmenu together
                    long_message_to_split = true, -- long messages will be sent to a split
                    inc_rename = false, -- enables an input dialog for inc-rename.nvim
                    lsp_doc_border = false, -- add a border to hover docs and signature help
                },
            }
        end,
        opts = {},
        dependencies = {
            "MunifTanjim/nui.nvim",
            "rcarriga/nvim-notify",
        },
    },
}
