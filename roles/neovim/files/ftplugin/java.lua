local config = require("lsp.servers").get_config "jdtls"
if config ~= nil then
    config = require("lsp.utils").update_server_config(config)

    -- This starts a new client & server,
    -- or attaches to an existing client & server depending on the `root_dir`.
    local jdtls = require "jdtls"
    pcall(jdtls.start_or_attach, config)
end
