return {
    {
        "neovim/nvim-lspconfig",
        dependencies = {
            "hrsh7th/nvim-cmp",
            "hrsh7th/cmp-nvim-lsp",
            "nvim-lua/lsp_extensions.nvim",
            "jose-elias-alvarez/null-ls.nvim",
            "nvim-lua/plenary.nvim",
            "williamboman/mason.nvim",
            "williamboman/mason-lspconfig.nvim",
            "SmiteshP/nvim-navic",
            "b0o/SchemaStore.nvim",
            "j-hui/fidget.nvim",
            "simrat39/rust-tools.nvim",
            "mfussenegger/nvim-jdtls",
            "scalameta/nvim-metals",
        },
        config = function()
            -- Portable package manager for Neovim that runs everywhere Neovim runs.
            -- Easily install and manage LSP servers, DAP servers, linters, and formatters.
            -- :help mason.nvim
            require("mason").setup {
                ui = {
                    icons = {
                        package_pending = " ",
                        package_installed = " ",
                        package_uninstalled = " ﮊ",
                    },
                    keymaps = {
                        toggle_server_expand = "<CR>",
                        install_server = "i",
                        update_server = "u",
                        check_server_version = "c",
                        update_all_servers = "U",
                        check_outdated_servers = "C",
                        uninstall_server = "X",
                        cancel_installation = "<C-c>",
                    },
                },

                max_concurrent_installers = 10,
            }

            -- Plugin to automatically install language servers registered to nvim-lspconfig

            require("mason-lspconfig").setup {
                ensure_installed = { "lua_ls", "rust_analyzer" },
                automatic_installation = false,
            }

            require("fidget").setup {}

            local lspconfig = require "lspconfig"

            for _, server in ipairs(require("lsp.servers").list) do
                local name = server.name
                local config = require("lsp.utils").update_server_config(server.config)

                if name == "rust_analyzer" then
                    -- `rust-tools` plugin plugin automatically sets up nvim-lspconfig for rust_analyzer for you,
                    --  so don't do that manually, as it causes conflicts.
                    -- NOTE(dparo): Rust tools seems to fuck around too much with our configuration just to get some inline type hints
                    -- require('rust-tools').setup({ tools = {hover_with_actions = false}, server = config })

                    -- @param server:  all the opts to send to nvim-lspconfig
                    -- these override the defaults set by rust-tools.nvim
                    require("rust-tools").setup {
                        tools = {
                            runnables = {
                                use_telescope = true,
                            },
                            inlay_hints = {
                                auto = true,
                                show_parameter_hints = false,
                                parameter_hints_prefix = "",
                                other_hints_prefix = "",
                            },
                        },
                        server = config,
                    }
                elseif name == "jdtls" then
                    -- NOTE(dparo): jdtls plugin is automatically started from an autocommand triggered from `ftplugin/java.lua`
                elseif name == 'metals' then
                    -- NOTE(dparo): metals plugin needs to be attached in another way
                else
                    lspconfig[name].setup(config)
                end
            end

            -- Null-ls is meant to fill the gaps for languages where either no language server exists,
            -- or where standalone linters,formatters,diagnostics provide better results
            -- than the available language server do.
            -- NOTE: Null-ls can be essentially conceptualized as an LSP server responding to LSP
            --       clients request, but instead of being in a separate process, lives inside neovim.
            --       Null-ls then delegates LSP request to external processes interpreting
            --       their outputs and providing diagnostics, ormatting and completion candidates.
            local null_ls = require "null-ls"

            null_ls.setup {
                on_attach = require("lsp.events").on_attach,
                sources = {
                    null_ls.builtins.diagnostics.codespell,
                    null_ls.builtins.diagnostics.misspell,
                    null_ls.builtins.diagnostics.gitlint,
                    null_ls.builtins.diagnostics.write_good,
                    null_ls.builtins.diagnostics.proselint,
                    null_ls.builtins.diagnostics.sqlfluff.with {
                        extra_args = { "--dialect", "oracle" },
                    },

                    null_ls.builtins.code_actions.proselint,

                    null_ls.builtins.completion.spell.with {
                        filetypes = {
                            "text",
                            "markdown",
                        },
                    },

                    -- NOTE(dparo): We use eslint-lsp server now (https://github.com/hrsh7th/vscode-langservers-extracted).
                    -- The server is hooked directly from nvim-lspconfig
                    -- null_ls.builtins.diagnostics.eslint,

                    -- A flexible JSON/YAML linter for creating automated style guides, with baked in support for OpenAPI v3.1, v3.0, and v2.0 as well as AsyncAPI v2.x.
                    -- null_ls.builtins.diagnostics.spectral,
                    --
                    --

                    -- Linting for css, scss, less, sass
                    null_ls.builtins.diagnostics.stylelint.with {
                        method = null_ls.methods.DIAGNOSTICS_ON_SAVE,
                    },

                    null_ls.builtins.formatting.google_java_format,

                    null_ls.builtins.diagnostics.semgrep.with {
                        args = { "--config", "auto", "-q", "--json", "$FILENAME" },
                    },


                    null_ls.builtins.formatting.prettier.with {
                        filetypes = {
                            "html",
                            "json",
                            "yaml",
                            "markdown",
                            "vue",
                            "javascript",
                            "typescript",
                            "typescriptreact",
                            "css",
                        },
                    },

                    -- XML, HTML
                    null_ls.builtins.formatting.tidy,
                    null_ls.builtins.diagnostics.tidy,

                    null_ls.builtins.formatting.shfmt.with {
                        args = { "--indent", "4", "-filename", "$FILENAME" }, -- Default to use 4 spaces for indentation
                    },
                    null_ls.builtins.diagnostics.shellcheck,
                    null_ls.builtins.formatting.shellharden,

                    null_ls.builtins.diagnostics.ansiblelint,

                    null_ls.builtins.formatting.stylua,

                    null_ls.builtins.diagnostics.hadolint,
                    null_ls.builtins.diagnostics.chktex,

                    null_ls.builtins.formatting.cmake_format,
                    null_ls.builtins.diagnostics.cppcheck,
                    null_ls.builtins.formatting.zigfmt,
                    null_ls.builtins.formatting.sqlfluff.with {
                        extra_args = { "--dialect", "oracle" },
                    },

                    -- null_ls.builtins.formatting.autopep8,
                    -- null_ls.builtins.diagnostics.pydocstyle,
                    -- Uncompromising Python code formatter.
                    -- null_ls.builtins.formatting.yapf,
                    null_ls.builtins.formatting.black, -- Black8 is too aggressive for my liking

                    -- python utility / library to sort imports alphabetically and automatically separate them into sections and by type.
                    null_ls.builtins.formatting.isort,
                    -- Mypy is an optional static type checker for Python that aims to combine the benefits of dynamic (or "duck") typing and static typing.
                    -- null_ls.builtins.diagnostics.mypy,
                    -- flake8 is a python tool that glues together pycodestyle, pyflakes, mccabe, and third-party plugins to check the style and quality of some python code
                    -- null_ls.builtins.diagnostics.flake8,

                    -- https://github.com/charliermarsh/ruff
                    null_ls.builtins.diagnostics.ruff,
                    null_ls.builtins.formatting.ruff,

                    null_ls.builtins.diagnostics.mypy.with {
                        method = null_ls.methods.DIAGNOSTICS_ON_SAVE,
                    },


                    -- Pylint is a Python static code analysis tool which looks for programming errors, helps enforcing a coding standard, sniffs for code smells and offers simple refactoring suggestions.
                    -- NOTE(dparo): Run pylint only on save due to its shitty performance
                    -- null_ls.builtins.diagnostics.pylint.with {
                    --     method = null_ls.methods.DIAGNOSTICS_ON_SAVE,
                    -- },
                },
            }

            require("lsp_extensions").inlay_hints {
                highlight = "Comment",
                prefix = " > ",
                aligned = false,
                only_current_line = false,
                enabled = { "ChainingHint" },
            }
        end,
    },
}
