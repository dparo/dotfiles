local M = {}

local navic = require "nvim-navic"


local conform_require_ok, conform = pcall(require, "conform")
local LSP_FORMATTING_ENABLED = not conform_require_ok

local augroup = vim.api.nvim_create_augroup("USER_LSP", { clear = true })

-- NOTE(d.paro): on_attach gets called N times, where N is the number of
--               lsp client that will be attached to this buffer.
--               To share resources between clients (such as augroup),
--               declare such resources outside
function M.on_attach(client, bufnr)
    local buf_set_option = vim.api.nvim_buf_set_option

    if LSP_FORMATTING_ENABLED then
        buf_set_option(bufnr, "formatexpr", "v:lua.vim.lsp.formatexpr()")
    else
        buf_set_option(bufnr, "formatexpr", "v:lua.require'conform'.formatexpr()")
    end
    buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")
    buf_set_option(bufnr, "tagfunc", "v:lua.vim.lsp.tagfunc")

    -- print("Client name: " .. client.name)

    -- Mappings.
    local keymap_opts = { noremap = true, silent = true, buffer = bufnr }

    vim.keymap.set("n", "<C-t>", function()
        require("telescope.builtin").lsp_workspace_symbols()
    end, keymap_opts)
    vim.keymap.set("n", "<leader>ls", function()
        require("telescope.builtin").lsp_workspace_symbols()
    end, keymap_opts)
    vim.keymap.set("n", "gD", function()
        vim.lsp.buf.declaration()
    end, keymap_opts)
    vim.keymap.set("n", "<leader>lD", function()
        vim.lsp.buf.declaration()
    end, keymap_opts)
    vim.keymap.set("n", "gd", function()
        require("telescope.builtin").lsp_definitions(require("telescope.themes").get_ivy {})
    end, keymap_opts)
    vim.keymap.set("n", "<leader>ld", function()
        require("telescope.builtin").lsp_definitions(require("telescope.themes").get_ivy {})
    end, keymap_opts)
    vim.keymap.set("n", "gt", function()
        require("telescope.builtin").lsp_type_definitions(require("telescope.themes").get_ivy {})
    end, keymap_opts)
    vim.keymap.set("n", "<leader>lt", function()
        require("telescope.builtin").lsp_type_definitions(require("telescope.themes").get_ivy {})
    end, keymap_opts)
    vim.keymap.set("n", "gi", function()
        require("telescope.builtin").lsp_implementations(require("telescope.themes").get_ivy {})
    end, keymap_opts)
    vim.keymap.set("n", "<leader>li", function()
        require("telescope.builtin").lsp_implementations(require("telescope.themes").get_ivy {})
    end, keymap_opts)
    vim.keymap.set("n", "gr", function()
        require("telescope.builtin").lsp_references(require("telescope.themes").get_ivy {})
    end, keymap_opts)
    vim.keymap.set("n", "<leader>lr", function()
        require("telescope.builtin").lsp_references(require("telescope.themes").get_ivy {})
    end, keymap_opts)
    vim.keymap.set("n", "<C-LeftMouse>", function()
        require("telescope.builtin").lsp_definitions(require("telescope.themes").get_ivy {})
    end, keymap_opts)
    vim.keymap.set("n", "<leader>D", function()
        require("telescope.builtin").lsp_definitions(require("telescope.themes").get_ivy {})
    end, keymap_opts)
    vim.keymap.set("n", "<S-LeftMouse>", function()
        require("telescope.builtin").lsp_references(require("telescope.themes").get_ivy {})
    end, keymap_opts)
    vim.keymap.set("n", "<M-CR>", function()
        vim.lsp.buf.code_action()
    end, keymap_opts)
    vim.keymap.set("n", "<C-1>", function()
        vim.lsp.buf.code_action()
    end, keymap_opts)
    vim.keymap.set("n", "<leader>a", function()
        vim.lsp.buf.code_action()
    end, keymap_opts)
    vim.keymap.set("n", "<leader>la", function()
        vim.lsp.buf.code_action()
    end, keymap_opts)
    vim.keymap.set("n", "<leader>e", function()
        user.utils.lsp.show_line_diagnostics()
    end, keymap_opts)
    vim.keymap.set("n", "[d", function()
        vim.diagnostic.goto_prev()
    end, keymap_opts)
    vim.keymap.set("n", "]d", function()
        vim.diagnostic.goto_next()
    end, keymap_opts)

    vim.keymap.set("n", "K", function()
        vim.lsp.buf.hover()
    end, keymap_opts)
    vim.keymap.set("n", "<leader>lhh", function()
        vim.lsp.buf.hover()
    end, keymap_opts)
    vim.keymap.set("n", "<leader>lhs", function()
        vim.lsp.buf.signature_help()
    end, keymap_opts)
    vim.keymap.set({ "n", "i" }, "<C-j>", function()
        vim.lsp.buf.signature_help()
    end, keymap_opts)
    vim.keymap.set("n", "<leader>lwa", function()
        vim.lsp.buf.add_workspace_folder()
    end, keymap_opts)
    vim.keymap.set("n", "<leader>lwr", function()
        vim.lsp.buf.remove_workspace_folder()
    end, keymap_opts)
    vim.keymap.set("n", "<leader>lq", function()
        vim.diagnostic.set_loclist()
    end, keymap_opts)

    -- JDTLS specific binds
    if client.name == "jdtls" then
        vim.keymap.set("n", "<leader>ljo", function()
            require("jdtls").organize_imports()
        end, keymap_opts)

        vim.keymap.set("n", "<leader>ljo", function()
            require("jdtls").organize_imports()
        end, keymap_opts)

        vim.keymap.set("n", "<leader>ljev", function()
            require("jdtls").extract_variable()
        end, keymap_opts)
        vim.keymap.set("v", "<leader>ljev", function()
            require("jdtls").extract_variable { visual = true }
        end, keymap_opts)

        vim.keymap.set("n", "<leader>ljec", function()
            require("jdtls").extract_constant()
        end, keymap_opts)
        vim.keymap.set("v", "<leader>ljec", function()
            require("jdtls").extract_constant { visual = true }
        end, keymap_opts)

        vim.keymap.set("v", "<leader>ljem", function()
            require("jdtls").extract_method { visual = true }
        end, keymap_opts)

        -- DAP
        vim.keymap.set("n", "<leader>djtc", function()
            require("jdtls").test_class()
        end, keymap_opts)
        vim.keymap.set("n", "<leader>djtm", function()
            require("jdtls").test_nearest_method()
        end, keymap_opts)

        vim.keymap.set("n", "<leader>djs", function()
            require("jdtls.dap").setup_dap_main_class_configs()
        end, keymap_opts)
    end

    vim.keymap.set("n", "<F2>", function()
        vim.lsp.buf.rename()
    end, keymap_opts)
    vim.keymap.set("n", "<leader>r", function()
        vim.lsp.buf.rename()
    end, keymap_opts)
    vim.keymap.set("n", "<leader>lc", function()
        vim.lsp.codelens.run()
    end, keymap_opts)

    vim.api.nvim_create_autocmd({ "CursorHold" }, {
        group = augroup,
        buffer = bufnr,
        callback = function()
            user.utils.lsp.show_line_diagnostics()
        end,
    })

    if false then
        if client.supports_method "textDocument/codeLens" --[[ client.server_capabilities.codeLensProvider  ]] then
            vim.api.nvim_create_autocmd({
                "BufEnter",
                "InsertLeave", --[[ "CursorHold"  ]]
            }, {
                group = augroup,
                buffer = bufnr,
                callback = function()
                    vim.lsp.codelens.refresh()
                end,
            })
        end
    end

    -- Set some keybinds conditional on server capabilities
    if LSP_FORMATTING_ENABLED and client.server_capabilities.documentFormattingProvider then
        if vim.fn.has "nvim-0.8" == 1 then
            vim.keymap.set("n", "<leader>lf", function()
                vim.lsp.buf.format { timeout_ms = 4000, bufnr = bufnr }
            end, keymap_opts)
        else
            vim.keymap.set("n", "<leader>lf", function()
                vim.lsp.buf.formatting_sync()
            end, keymap_opts)
        end
    end

    -- Setup highlight references of word under cursor using lsp
    if client.name ~= "null-ls" and client.server_capabilities.documentHighlightProvider then
        vim.api.nvim_create_autocmd({ "CursorHold" }, {
            group = augroup,
            buffer = bufnr,
            callback = function()
                pcall(vim.lsp.buf.document_highlight)
            end,
        })
        vim.api.nvim_create_autocmd({ "CursorMoved" }, {
            group = augroup,
            buffer = bufnr,
            callback = function()
                pcall(vim.lsp.buf.clear_references)
            end,
        })
    end

    if false and client.name ~= "null-ls" and client.server_capabilities.hoverProvider then
        vim.api.nvim_create_autocmd({ "CursorHold" }, {
            group = augroup,
            buffer = bufnr,
            callback = function()
                vim.lsp.buf.hover()
            end,
        })
    end

    if false and client.name ~= "null-ls" and client.server_capabilities.signatureHelpProvider then
        vim.api.nvim_create_autocmd({ "CursorHold" }, {
            group = augroup,
            buffer = bufnr,
            callback = function()
                pcall(vim.lsp.buf.signature_help)
            end,
        })
    end

    if false then
        vim.api.nvim_create_autocmd({ "CursorHold" }, {
            group = augroup,
            buffer = bufnr,
            callback = function()
                if require("dap").status() ~= nil and require("dap").status() ~= "" then
                    pcall(function()
                        require("dap.ui.widgets").preview()
                    end)
                end
            end,
        })
    end

    if false then
        if (client.server_capabilities.inlayHintProvider or client.supports_method "textDocument/inlayHint") and vim.lsp.inlay_hint ~= nil then
            vim.api.nvim_create_autocmd("InsertEnter", {
                group = augroup,
                buffer = bufnr,
                callback = function()
                    vim.lsp.buf.inlay_hint(bufnr, true)
                end,
            })
            vim.api.nvim_create_autocmd("InsertLeave", {
                group = augroup,
                buffer = bufnr,
                callback = function()
                    vim.lsp.buf.inlay_hint(bufnr, false)
                end,
            })
        end
    end

    -- Enable formatting on save
    if
        LSP_FORMATTING_ENABLED
        and (client.server_capabilities.documentFormattingProvider or client.supports_method "textDocument/formatting")
        and (vim.env.NVIM_LSP_FORMAT_ON_SAVE == nil or vim.env.NVIM_LSP_FORMAT_ON_SAVE ~= "0")
    then
        vim.api.nvim_create_autocmd({ "BufWritePre" }, {
            group = augroup,
            buffer = bufnr,
            desc = "LSP Format on save autocommand",
            callback = function()
                vim.lsp.buf.format { timeout_ms = 4000, bufnr = bufnr, id = client.id }
            end,
        })

        -- Automatically organize imports for java code
        -- NOTE(dparo): 24 Aug 2022:
        -- `require("jdtls").organize_imports()` is an async function,
        -- and unfortunately it does not provide a sync equivalent, so it cannot
        -- be used in this context.
        -- I've tried to implement my `organize_imports_sync()` function.
        -- It worked, but I needed to hack the `client_id` since there was no clear way
        -- to retrieve it due to the structure of the `nvim-jdlts` source code
        if false and client.name == "jdtls" then
            vim.api.nvim_create_autocmd({ "BufWritePre" }, {
                group = augroup,
                buffer = bufnr,
                callback = function()
                    require("jdtls").organize_imports()
                end,
            })
        end
    end

    -- Setup DAP for java code
    -- See: https://github.com/mfussenegger/nvim-jdtls#nvim-dap-setup
    --       NOTE(d.paro): Since commit 0261cf5a76cf2ef807c4ae0ede18fc9d791ebf02, jdtls automatically setups nvim-dap configurations if it's installed
    --                     So the below code is not anymore required and therefore it has been disabled
    if false and client.name == "jdtls" then
        -- With `hotcodereplace = 'auto' the debug adapter will try to apply code changes
        -- you make during a debug session immediately.
        -- Remove the option if you do not want that.
        require("jdtls").setup_dap { config_overrides = {}, hotcodereplace = "auto" }
    end

    if client.server_capabilities.documentSymbolProvider then
        navic.attach(client, bufnr)
    end
end

return M
