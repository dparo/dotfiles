local M = {}

local navic = require "nvim-navic"

function M.on_attach(client, bufnr)
    local buf_set_keymap = vim.api.nvim_buf_set_keymap
    local buf_set_option = vim.api.nvim_buf_set_option

    buf_set_option(bufnr, "formatexpr", "v:lua.vim.lsp.formatexpr()")
    buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")
    buf_set_option(bufnr, "tagfunc", "v:lua.vim.lsp.tagfunc")

    -- print("Client name: " .. client.name)

    -- Mappings.
    local opts = { noremap = true, silent = true }

    buf_set_keymap(bufnr, "n", "<C-t>", "<Cmd>Telescope lsp_workspace_symbols<CR>", opts)
    buf_set_keymap(bufnr, "n", "<leader>ls", "<Cmd>Telescope lsp_workspace_symbols<CR>", opts)
    buf_set_keymap(bufnr, "n", "gD", "<Cmd>lua vim.lsp.buf.declaration()<CR>", opts)
    buf_set_keymap(bufnr, "n", "<leader>lD", "<Cmd>lua vim.lsp.buf.declaration()<CR>", opts)
    buf_set_keymap(bufnr, "n", "gd", "<Cmd>Telescope lsp_definitions theme=ivy<CR>", opts)
    buf_set_keymap(bufnr, "n", "<leader>ld", "<Cmd>Telescope lsp_definitions theme=ivy<CR>", opts)
    buf_set_keymap(bufnr, "n", "gt", "<Cmd>Telescope lsp_type_definitions theme=ivy<CR>", opts)
    buf_set_keymap(bufnr, "n", "<leader>lt", "<Cmd>Telescope lsp_type_definitions theme=ivy<CR>", opts)
    buf_set_keymap(bufnr, "n", "gi", "<cmd>Telescope lsp_implementations theme=ivy<CR>", opts)
    buf_set_keymap(bufnr, "n", "<leader>li", "<cmd>Telescope lsp_implementations theme=ivy<CR>", opts)
    buf_set_keymap(bufnr, "n", "gr", "<cmd>Telescope lsp_references theme=ivy<CR>", opts)
    buf_set_keymap(bufnr, "n", "<leader>lr", "<cmd>Telescope lsp_references theme=ivy<CR>", opts)
    buf_set_keymap(bufnr, "n", "<C-LeftMouse>", "<Cmd>Telescope lsp_definitions theme=ivy<CR>", opts)
    buf_set_keymap(bufnr, "n", "<leader>D", "<cmd>Telescope lsp_definitions theme=ivy<CR>", opts)
    buf_set_keymap(bufnr, "n", "<S-LeftMouse>", "<Cmd>Telescope lsp_references theme=ivy<CR>", opts)
    buf_set_keymap(bufnr, "n", "<M-CR>", "<cmd>lua vim.lsp.buf.code_action()<CR>", opts)
    buf_set_keymap(bufnr, "n", "<C-1>", "<cmd>lua vim.lsp.buf.code_action()<CR>", opts)
    buf_set_keymap(bufnr, "n", "<leader>a", "<cmd>lua vim.lsp.buf.code_action()<CR>", opts)
    buf_set_keymap(bufnr, "n", "<leader>la", "<cmd>lua vim.lsp.buf.code_action()<CR>", opts)
    buf_set_keymap(bufnr, "n", "<leader>e", "<cmd>lua user.utils.lsp.show_line_diagnostics()<CR>", opts)
    buf_set_keymap(bufnr, "n", "[d", "<cmd>lua vim.diagnostic.goto_prev()<CR>", opts)
    buf_set_keymap(bufnr, "n", "]d", "<cmd>lua vim.diagnostic.goto_next()<CR>", opts)

    buf_set_keymap(bufnr, "n", "K", "<Cmd>lua vim.lsp.buf.hover()<CR>", opts)
    buf_set_keymap(bufnr, "n", "<leader>lhh", "<cmd>lua vim.lsp.buf.hover()<CR>", opts)
    buf_set_keymap(bufnr, "n", "<leader>lhs", "<cmd>lua vim.lsp.buf.signature_help()<CR>", opts)
    buf_set_keymap(bufnr, "n", "<C-j>", "<cmd>lua vim.lsp.buf.signature_help()<CR>", opts)
    buf_set_keymap(bufnr, "i", "<C-j>", "<cmd>lua vim.lsp.buf.signature_help()<CR>", opts)
    buf_set_keymap(bufnr, "n", "<leader>lwa", "<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>", opts)
    buf_set_keymap(bufnr, "n", "<leader>lwr", "<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>", opts)
    buf_set_keymap(bufnr, "n", "<leader>lwl", "<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>", opts)
    buf_set_keymap(bufnr, "n", "<leader>lq", "<cmd>lua vim.diagnostic.set_loclist()<CR>", opts)

    -- JDTLS specific binds
    if client.name == "jdtls" then
        buf_set_keymap(bufnr, "n", "<leader>ljo", "<Cmd>lua require('jdtls').organize_imports()<CR>", opts)

        buf_set_keymap(bufnr, "n", "<leader>ljo", "<Cmd>lua require('jdtls').organize_imports()<CR>", opts)

        buf_set_keymap(bufnr, "n", "<leader>ljev", "<Cmd>lua require('jdtls').extract_variable()<CR>", opts)
        buf_set_keymap(bufnr, "v", "<leader>ljev", "<Cmd>lua require('jdtls').extract_variable(true)<CR>", opts)

        buf_set_keymap(bufnr, "n", "<leader>ljec", "<Cmd>lua require('jdtls').extract_constant()<CR>", opts)
        buf_set_keymap(bufnr, "v", "<leader>ljec", "<Cmd>lua require('jdtls').extract_constant(true)<CR>", opts)

        buf_set_keymap(bufnr, "v", "<leader>ljem", "<Cmd>lua require('jdtls').extract_method(true)<CR>", opts)

        -- DAP
        buf_set_keymap(bufnr, "n", "<leader>djtc", "<Cmd>lua require('jdtls').test_class()<CR>", opts)
        buf_set_keymap(bufnr, "n", "<leader>djtm", "<Cmd>lua require('jdtls').test_nearest_method()<CR>", opts)

        buf_set_keymap(bufnr, "n", "<leader>djs", "<Cmd>lua require('jdtls.dap').setup_dap_main_class_configs()<CR>", opts)
    end

    buf_set_keymap(bufnr, "n", "<F2>", "<cmd>lua vim.lsp.buf.rename()<CR>", opts)
    buf_set_keymap(bufnr, "n", "<leader>r", "<cmd>lua vim.lsp.buf.rename()<CR>", opts)

    local augroup = vim.api.nvim_create_augroup("USER_LSP", { clear = true })
    vim.api.nvim_create_autocmd({ "CursorHold" }, {
        group = augroup,
        buffer = bufnr,
        callback = function()
            user.utils.lsp.show_line_diagnostics()
        end,
    })

    -- Set some keybinds conditional on server capabilities
    if client.server_capabilities.documentFormattingProvider then
        if vim.fn.has "nvim-0.8" == 1 then
            buf_set_keymap(bufnr, "n", "<leader>lf", "<cmd>lua vim.lsp.buf.format()<CR>", opts)
        else
            buf_set_keymap(bufnr, "n", "<leader>lf", "<cmd>lua vim.lsp.buf.formatting_sync()<CR>", opts)
        end
    end

    if client.server_capabilities.documentRangeFormattingProvider then
        if vim.fn.has "nvim-0.8" == 1 then
            buf_set_keymap(bufnr, "v", "<leader>lf", "<cmd>lua vim.lsp.buf.format()<CR>", opts)
        else
            buf_set_keymap(bufnr, "v", "<leader>lf", "<cmd>lua vim.lsp.buf.range_formatting()<CR>", opts)
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

    -- Enable formatting on save
    if
        client.server_capabilities.documentFormattingProvider
        and (vim.env.NVIM_LSP_FORMAT_ON_SAVE == nil or vim.env.NVIM_LSP_FORMAT_ON_SAVE ~= "0")
    then
        vim.api.nvim_create_autocmd({ "BufWritePre" }, {
            group = augroup,
            buffer = bufnr,
            callback = function()
                vim.lsp.buf.format()
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
    if client.name == "jdtls" then
        -- With `hotcodereplace = 'auto' the debug adapter will try to apply code changes
        -- you make during a debug session immediately.
        -- Remove the option if you do not want that.
        require("jdtls").setup_dap { hotcodereplace = "auto" }
    end

    if client.server_capabilities.documentSymbolProvider then
        navic.attach(client, bufnr)
    end
end

return M
