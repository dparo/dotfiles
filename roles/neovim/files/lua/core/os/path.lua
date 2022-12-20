local M = {}


M.separator = (function()
    ---@diagnostic disable-next-line: undefined-global
    if jit then
        local os = require("core.os").name
        if os == "linux" or os == "osx" or os == "bsd" then
            return "/"
        else
            return "\\"
        end
    else
        return string.sub(package.config, 1, 1)
    end
end)()


function M.split(inputString)
    local fields = {}

    local pattern = string.format("([^%s]+)", M.separator)
    local _ = string.gsub(inputString, pattern, function(c)
      fields[#fields + 1] = c
    end)

    return fields
  end


function M.concat(path_components)
    return table.concat(path_components, M.separator)
end


-- NOTE: Needs testing. Might use M.concat for better compatibility
function M.join(...)
    local args = {...}
    if #args == 0 then
      return ""
    end

    local all_parts = {}
    if type(args[1]) == "string" and args[1]:sub(1, 1) == M.separator then
      all_parts[1] = ""
    end

    for _, arg in ipairs(args) do
      arg_parts = M.split(arg, M.separator)
      vim.list_extend(all_parts, arg_parts)
    end

    return M.concat(all_parts, M.separator)
end

function M.get_nvim_config_path()
    return vim.api.nvim_call_function("stdpath", { "config" })
end


function M.get_nvim_data_path()
    return vim.api.nvim_call_function("stdpath", { "data" })
end

function M.get_nvim_cache_path()
    return vim.api.nvim_call_function("stdpath", { "cache" })
end


return M