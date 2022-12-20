local config = require("user.plugins.configs.lsp.servers").get_config "jdtls"
config = require("user.plugins.configs.lsp.utils").update_server_config(config)

-- This starts a new client & server,
-- or attaches to an existing client & server depending on the `root_dir`.
local jdtls = require "jdtls"
pcall(jdtls.start_or_attach, config)
