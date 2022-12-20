local M = {}

function M.augroup(group_name, map)
    local group = vim.api.nvim_create_augroup(group_name, { clear = true })

    for _, tbl in ipairs(map) do
        local event = tbl[1]
        local opts = tbl[2]
        opts.group = group
        vim.api.nvim_create_autocmd(event, opts)
    end
end

return M