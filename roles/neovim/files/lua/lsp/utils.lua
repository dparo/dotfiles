local M = {}


function M.update_server_config(config)
    config = config or {}
    config = vim.deepcopy(config)

    if type(config) == "function" then
        config = config()
    end


    -- local capabilities = vim.lsp.protocol.make_client_capabilities()
    -- capabilities = vim.tbl_deep_extend("force", capabilities,  require("cmp_nvim_lsp").default_capabilities())

    -- NOTE(d.paro): require('blink.cmp').get_lsp_capabilities() includes the default capabilities by default
    local capabilities = require('blink.cmp').get_lsp_capabilities()

    config.capabilities = capabilities
    config.on_attach = require("lsp.events").on_attach
    config.flags = vim.tbl_deep_extend("force", config.flags or {}, { debounce_text_changes = 1000 })

    return config
end


return M
