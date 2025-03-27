return {
    {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    ---@type snacks.Config
    opts = {
      -- your configuration comes here
      -- or leave it empty to use the default settings
      -- refer to the configuration section below
      bigfile = { enabled = true },
      dashboard = { enabled = false },
      indent = { enabled = false },
      input = { enabled = true },
      notifier = { enabled = true },
      quickfile = { enabled = true },
      scroll = { enabled = false },
      statuscolumn = { enabled = false },
      words = { enabled = true },
    },
  },
    -- A high-performance #RRGGBB format color highlighter for Neovim which has no external dependencies! Written in performant Luajit
    {
        "NvChad/nvim-colorizer.lua",
        config = function()
            require("colorizer").setup {}
        end,
    },
    { "echasnovski/mini.nvim", version = false },

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
                        return os.date "%Y-%m-%dT%H-%M-%SZ"
                    end, -- Example result: "2021-04-13-10-04-18"
                },
                asciidoc = {
                    img_dir = "assets/img",
                    img_dir_txt = "",
                },
            }
        end,
    },
    -- {
    --     "supermaven-inc/supermaven-nvim",
    --     config = function()
    --         require("supermaven-nvim").setup {
    --             disable_keymaps = true
    --         }
    --     end,
    -- },

    --- Trim trailing whitespaces
    {
        "cappyzawa/trim.nvim",
        enabled = function()
            -- From neovim 0.9, editor-config support is built-in.
            --     From nvim-0.9 trailing whitespaces are automatically removed on save if configured in .editorconfig file,
            --     making this plugin redundant
            return vim.fn.has "nvim-0.9" == 0
        end,
        config = function()
            require("trim").setup {
                ft_blocklist = {},
                patterns = {
                    [[%s/\s\+$//e]], -- Trim trailing
                    [[%s/\%^\n\+//]], -- Trim first line
                    [[%s/\($\n\s*\)\+\%$//]], -- Trim last line
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
        enabled = false,
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
        enabled = function()
            -- From neovim 0.9, editor-config support is built-in (no plugin required)
            return vim.fn.has "nvim-0.9" == 0
        end,
    },

    {
        "epwalsh/obsidian.nvim",
        enabled = false,
        version = "*",  -- recommended, use latest release instead of latest commit
        lazy = true,
        ft = "markdown",
        -- Replace the above line with this if you only want to load obsidian.nvim for markdown files in your vault:
        -- event = {
        --   -- If you want to use the home shortcut '~' here you need to call 'vim.fn.expand'.
        --   -- E.g. "BufReadPre " .. vim.fn.expand "~" .. "/my-vault/**.md"
        --   "BufReadPre path/to/my-vault/**.md",
        --   "BufNewFile path/to/my-vault/**.md",
        -- },
        dependencies = {
          -- Required.
          "nvim-lua/plenary.nvim",

          -- see below for full list of optional dependencies 👇
        },
        opts = {
          workspaces = {
            {
              name = "work",
              path = "~/Documents/Obsidian Vaults/Work",
            },
          },

          -- see below for full list of options 👇
        },
  }
}
