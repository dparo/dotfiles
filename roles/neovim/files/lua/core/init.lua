local M = {}
_G.core = M

require "core.options"
M.utils = require "core.utils"

M.init = function()
    local packer_is_bootstrapped = require "core.packer"
    return packer_is_bootstrapped
end

return M
