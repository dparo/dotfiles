return {
    -- A high-performance #RRGGBB format color highlighter for Neovim which has no external dependencies! Written in performant Luajit
    {
        "NvChad/nvim-colorizer.lua",
        config = function()
            require("colorizer").setup {}
        end,
    },

    -- Better quickfix window in Neovim, polish old quickfix window.
    { "kevinhwang91/nvim-bqf" },

    -- A search panel for neovim: Find the enemy and replace them with dark power
    { "windwp/nvim-spectre" },

    -- Treesitter based structural search and replace plugin for Neovim.
    {
        "cshuaimin/ssr.nvim",
        config = function()
            require("ssr").setup {}
        end,
    },
    {
        -- "ekickx/clipboard-image.nvim",
        "postfen/clipboard-image.nvim", -- This fork contains fixes to vim.health support provided in nvim 0.9
        config = function()
            require("clipboard-image").setup {
                -- Default configuration for all filetype
                default = {
                    img_dir = "assets/img",
                    img_dir_txt = "assets/img",
                    img_name = function()
                        return os.date "%Y-%m-%d-%H-%M-%S"
                    end, -- Example result: "2021-04-13-10-04-18"
                },
                asciidoc = {
                    img_dir = "assets/img",
                    img_dir_txt = "",
                },
            }
        end,
    },

    --- Trim trailing whitespaces
    {
        "cappyzawa/trim.nvim",
        config = function()
            require("trim").setup {
                ft_blocklist = {},
                patterns = {
                    [[%s/\s\+$//e]],          -- remove unwanted spaces
                    [[%s/\($\n\s*\)\+\%$//]], -- trim last line
                    [[%s/\%^\n\+//]],         -- trim first line
                },
            }
        end,
    },

    -- Many people really want to do tnoremap <Esc> <C-\><C-n>. However, there is a few command line utilities
    -- they rely on also use <Esc>.
    -- This is a plugin that let you map <Esc> to <C-\><C-n> except when these command line utilities are running in the terminal
    {
        "sychen52/smart-term-esc.nvim",
        config = function()
            require("smart-term-esc").setup {
                key = "<Esc>",
                except = { "nvim", "fzf", "lazygit" },
            }
        end,
    },

    { "mbbill/undotree" },

    -- Highlight todo in comments
    {
        "folke/todo-comments.nvim",
        dependencies = { "nvim-lua/plenary.nvim", "folke/trouble.nvim", "nvim-telescope/telescope.nvim" },
        config = function()
            require("todo-comments").setup {
                highlight = {
                    before = "",
                    keyword = "fg",
                    after = "",
                    pattern = [[.*<(KEYWORDS)>(\(.*\))?\s*:?]],
                },
                search = {
                    pattern = [[\b(KEYWORDS)\b(\(.*\))?\s*:?]],
                },
            }
        end,
    },

    {
        "lukas-reineke/indent-blankline.nvim",
        enabled = false,
        config = function()
            require("indent_blankline").setup {
                show_current_context = true,
                show_current_context_start = false,
                filetype_exclude = {
                    "lspinfo",
                    "checkhealth",
                    "help",
                    "man",
                    "startify",
                    "dashboard",
                    "packer",
                    "neogitstatus",
                    "NvimTree",
                    "Trouble",
                },
            }
        end,
    },

    -- Automatically close braces but only when pressing enter (more conservative approach)
    --      NOTE: It does not work since it collides with our custom <CR> key, and there's
    --            no way to tell the plugin, to not catch the <CR> key by default and let us
    --            handle it
    -- { 'rstacruz/vim-closer' }

    -- Easily move selected lines (visual mode) up, down, left and right
    {
        "matze/vim-move",
        config = function()
            vim.g.move_map_keys = 0
        end,
    },

    {
        "numToStr/Comment.nvim",
        config = function()
            require("Comment").setup {
                toggler = {
                    line = "gcc",
                    block = "gbc",
                },
                mappings = {
                    basic = true,
                    extra = true,
                    extended = false,
                },
            }
        end,
    },

    {
        "windwp/nvim-autopairs",
        config = function()
            require("nvim-autopairs").setup {
                disable_filetype = { "TelescopePrompt", "lua" },
                check_ts = true,
                fast_wrap = {
                    map = "<M-e>",
                    chars = { "{", "[", "(", '"', "'" },
                    pattern = [=[[%'%"%)%>%]%)%}%,]]=],
                    end_key = "$",
                    keys = "qwertyuiopzxcvbnmasdfghjkl",
                    check_comma = true,
                    highlight = "Search",
                    highlight_grey = "Comment",
                },
            }
        end,
    },

    ----
    ---- Plugins for cursor motion or for text editing
    ----
    { "junegunn/vim-easy-align" },

    { "tpope/vim-repeat" },

    -- "Jetpack" like movement within the buffer. Quickly jump where you want to go
    {
        "ggandor/leap.nvim",
        dependencies = {
            "tpope/vim-repeat",
        },
        config = function()
            require("leap").add_default_mappings()
        end,
    },

    -- Utils functions for common Unix like utilities such as mkdir, touch, mv inside of vim
    { "tpope/vim-eunuch" },
    { "tpope/vim-dispatch", lazy = true, cmd = { "Dispatch", "Make", "Focus", "Start" } },
    { "tpope/vim-surround" }, -- Surround.vim is all about "surroundings": parentheses, brackets, quotes, XML tags, and more

    -- Automatically detect shiftwidth and tabstop heuristically from file
    -- { "tpope/vim-sleuth" },
    {
        "editorconfig/editorconfig-vim",
        cond = function()
            -- From neovim 0.9, editor-config support is built-in (no plugin required)
            return vim.fn.has "nvim-0.9" == 0
        end,
    },

    { "nathom/filetype.nvim" },
}
