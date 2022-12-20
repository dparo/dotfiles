local actions = require "telescope.actions"

require("telescope").setup {
    defaults = {
        color_devicons = true,
        winblend = 0,
        border = {},
        borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
        prompt_prefix = "   ",
        selection_caret = "  ",
        entry_prefix = "  ",
        initial_mode = "insert",
        selection_strategy = "reset",
        sorting_strategy = "ascending",
        layout_strategy = "horizontal",
        layout_config = {
            horizontal = {
                prompt_position = "top",
                preview_width = 0.55,
                results_width = 0.8,
            },
            vertical = {
                mirror = false,
            },
            width = 0.87,
            height = 0.80,
            preview_cutoff = 120,
        },


        vimgrep_arguments = {
            "rg",
            "--color=never",
            "--no-heading",
            "--with-filename",
            "--line-number",
            "--column",
            "--smart-case",
        },
        mappings = {
            n = {
                ["q"] = actions.close,
            },
            i = {
                ["<Esc>"] = actions.close,
                ["<C-c>"] = actions.close,
                ["<C-q>"] = actions.send_to_qflist + actions.open_qflist,
            },
        }
    },
}
