local M = {}

M.name = (function()
---@diagnostic disable-next-line: undefined-global
    if jit then
        ---@diagnostic disable-next-line: undefined-global
        local os = string.lower(jit.os)
        return os
    else
        if vim.fn.has "mac" == 1 then
            return "osx"
        elseif vim.fn.has "unix" == 1 or vim.fn.has "linux" then
            return "linux"
        elseif vim.fn.has "win32" == 1 or vim.fn.has "win64" then
            return "windows"
        else
            print "Unsupported system for sumneko"
        end
    end
end)()


return M
