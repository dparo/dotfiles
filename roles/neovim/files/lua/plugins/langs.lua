return {
    { "dag/vim-fish" },
    { "mboughaba/i3config.vim" },
    {
        "plasticboy/vim-markdown",
        config = function()
            vim.g.vim_markdown_folding_disabled = 1
        end,
    },
    { "vim-crystal/vim-crystal" },
    { "ziglang/zig.vim" },
    {
        "rust-lang/rust.vim",
        config = function()
            vim.g.cargo_makeprg_params = "build"
        end,
    },

    {
        "alaviss/nim.nvim",
    },
    {
        "ray-x/go.nvim",
        dependencies = { -- optional packages
            "ray-x/guihua.lua",
            "neovim/nvim-lspconfig",
            "nvim-treesitter/nvim-treesitter",
        },
        config = function()
            require("go").setup()
        end,
        event = { "CmdlineEnter" },
        ft = { "go", "gomod" },
        build = ':lua require("go.install").update_all_sync()', -- if you need to install/update all binaries
    },

    ----
    ---- Language specific plugins, for syntax highlighting or working with the language
    ----
    {
        "nvim-treesitter/nvim-treesitter",
        branch = "master",
        build = function()
            vim.cmd [[:TSUpdateSync ]]
        end,
        dependencies = { "nvim-treesitter/playground", "p00f/nvim-ts-rainbow",
            -- "nvim-treesitter/nvim-treesitter-context"
        },
        config = function()
            require("nvim-treesitter.configs").setup {
                ensure_installed = {
                    "bash",
                    "lua",
                    "markdown",
                    "yaml",
                    "json",
                    "javascript",
                    "typescript",
                    "java",
                    "make",
                    "ninja",
                    "cmake",
                    "meson",
                    "c",
                    "cpp",
                    "rust",
                    "zig",
                    "go",
                    "regex",
                    "markdown_inline",
                    "sql",
                    "http",
                }, -- "all" or a list of languages
                sync_install = true,
                auto_install = true,
                highlight = {
                    enable = true, -- false will disable the whole extension
                    additional_vim_regex_highlighting = false,
                    -- disable = { "c", "rust" },  -- list of language that will be disabled
                },
                indent = {
                    enable = true,
                },
                incremental_selection = {
                    enable = true,
                    keymaps = {
                        init_selection = "<c-space>",
                        node_incremental = "<c-space>",
                        scope_incremental = "<c-s>",
                        node_decremental = "<c-backspace>",
                    },
                },
                rainbow = {
                    -- Default colors seems to suck, and the major colorschemes that I use do not
                    -- seem to support it yet, disable the rainbow for now
                    enable = false,
                    -- disable = { "jsx", "cpp" }, list of languages you want to disable the plugin for
                    extended_mode = false, -- Also highlight non-bracket delimiters like html tags, boolean or table: lang -> boolean
                    max_file_lines = nil, -- Do not enable for files with more than n lines, int
                    -- Setting colors
                    -- colors = {
                    -- }
                },
                playground = {
                    enable = true,
                },
                textobjects = {
                    select = {
                        enable = true,
                        lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
                        keymaps = {
                            -- You can use the capture groups defined in textobjects.scm
                            ["aa"] = "@parameter.outer",
                            ["ia"] = "@parameter.inner",
                            ["af"] = "@function.outer",
                            ["if"] = "@function.inner",
                            ["ac"] = "@class.outer",
                            ["ic"] = "@class.inner",
                        },
                    },
                    move = {
                        enable = true,
                        set_jumps = true, -- whether to set jumps in the jumplist
                        goto_next_start = {
                            ["]m"] = "@function.outer",
                            ["]]"] = "@class.outer",
                        },
                        goto_next_end = {
                            ["]M"] = "@function.outer",
                            ["]["] = "@class.outer",
                        },
                        goto_previous_start = {
                            ["[m"] = "@function.outer",
                            ["[["] = "@class.outer",
                        },
                        goto_previous_end = {
                            ["[M"] = "@function.outer",
                            ["[]"] = "@class.outer",
                        },
                    },
                    swap = {
                        enable = true,
                        swap_next = {
                            ["<leader>a"] = "@parameter.inner",
                        },
                        swap_previous = {
                            ["<leader>A"] = "@parameter.inner",
                        },
                    },
                },
            }
            -- require("treesitter-context").setup {
            --     enabled = false,
            --     max_lines = 8,
            --     trim_scope = "outer",
            -- }
        end,
    },

    {
        "m-demare/hlargs.nvim",
        dependencies = { "nvim-treesitter/nvim-treesitter" },
        config = function()
            require("hlargs").setup()
        end,
    },
    {"aklt/plantuml-syntax" },
    { "isobit/vim-caddyfile" },
}
