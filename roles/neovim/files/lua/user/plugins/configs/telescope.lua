local actions = require "telescope.actions"

require("telescope").setup {
    pickers = {
        find_files = {
            theme = "ivy",
        },
    },
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
        sorting_strategy = "descending",
        layout_strategy = "horizontal",
        layout_config = {
            prompt_position = "top",
            mirror = false,
            width = 0.80,
            height = 0.80,
            preview_cutoff = 120,
            preview_width = 0.35,
        },

        find_command = { "rg", "-S", "--files", "--hidden", "-g", "!.ccls-cache", "-g", "!.git", "-g", "!.vcs", "-g", "!.svn" },
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
        },
    },
}
