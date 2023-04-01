return {
    {
        "TimUntersberger/neogit",
        dependencies = "nvim-lua/plenary.nvim",
        config = function()
            local neogit = require "neogit"

            neogit.setup {}
        end,
    },

    { "tpope/vim-fugitive" },
    {
        "kdheepak/lazygit.nvim",
        lazy = true,
        cmd = { "LazyGit" },
        dependencies = { "nvim-telescope/telescope.nvim", "nvim-lua/plenary.nvim" },
        config = function()
            require("telescope").load_extension "lazygit"
        end,
    },

    {
        "sindrets/diffview.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
        config = function()
            require("diffview").setup {}
        end,
    },
    {
        "lewis6991/gitsigns.nvim",
        config = function()
            require("gitsigns").setup {
                current_line_blame = true,
            }
        end,
    },
}