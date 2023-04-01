return {

    {
        "junegunn/fzf.vim",
        dependencies = {
            { "junegunn/fzf", dir = vim.env.HOME .. "/opt/fzf" },
        },
        config = function()
            vim.g.fzf_buffers_jump = 1
            vim.g.fzf_commits_log_options = '--graph --color=always --format="%C(auto)%h%d %s %C(black)%C(bold)%cr"'
            vim.g.fzf_tags_command = "ctags -R"
            vim.g.fzf_commands_expect = "alt-enter,ctrl-x"
            --vim.g.fzf_layout = { window = { width = 0.8, height = 0.8 } }
            vim.g.fzf_layout = { down = "~80%" }
            vim.g.fzf_action = {
                ["ctrl-h"] = "split",
                ["ctrl-q"] = vim.NIL,
                ["ctrl-t"] = "tab split",
                ["ctrl-v"] = "vsplit",
            }

            -- Changes default command line options for Ripgre and Ag
            vim.cmd [[
                function! RipgrepFzf(query, fullscreen)
                    let command_fmt = 'rg --follow --hidden --glob=!.git/ --column --line-number --no-heading --color=always --smart-case -- %s || true'
                    let initial_command = printf(command_fmt, shellescape(a:query))
                    let reload_command = printf(command_fmt, '{q}')
                    let spec = {'options': ['--phony', '--query', a:query, '--bind', 'change:reload:'.reload_command]}
                    call fzf#vim#grep(initial_command, 1, fzf#vim#with_preview(spec), a:fullscreen)
                endfunction

                function! AgFzf(query, fullscreen)
                    let command_fmt = 'ag --nobreak --nogroup --follow --no-heading --hidden --ignore .git/ --column --line-number --color --smart-case %s || true'
                    let initial_command = printf(command_fmt, shellescape(a:query))
                    let reload_command = printf(command_fmt, '{q}')
                    let spec = {'options': ['--phony', '--query', a:query, '--bind', 'change:reload:'.reload_command]}
                    call fzf#vim#grep(initial_command, 1, fzf#vim#with_preview(spec), a:fullscreen)
                endfunction

                command! -nargs=* -bang Rg call RipgrepFzf(<q-args>, <bang>0)
                command! -nargs=* -bang Ag call AgFzf(<q-args>, <bang>0)
            ]]
        end,
    },

    {
        "nvim-telescope/telescope.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
        config = function()
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

        end,
    },

    {
        "nvim-telescope/telescope-fzf-native.nvim",
        dependencies = { "nvim-telescope/telescope.nvim" },
        build = "make",
        cond = vim.fn.executable "make" == 1,
        config = function()
            pcall(require("telescope").load_extension, "fzf")
        end,
    },
}