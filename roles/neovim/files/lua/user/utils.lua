vim.cmd [[
com! GetHighlightUnderCursor echo {l,c,n ->
\   'hi<'    . synIDattr(synID(l, c, 1), n)             . '> '
\  .'trans<' . synIDattr(synID(l, c, 0), n)             . '> '
\  .'lo<'    . synIDattr(synIDtrans(synID(l, c, 1)), n) . '> '
\ }(line("."), col("."), "name")


" Show highlight of group under cursor
function s:SynStack()
    if !exists("*synstack")
        return
    endif
    echo map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")')
endfunction

command! SyntaxQuery call s:SynStack()
]]

local M = {}
M.lsp = M.lsp or {}

M.update_tbl = function(tbl, other)
    for k, v in pairs(other) do
        tbl[k] = v
    end
end

function M.filename_escape(p)
    return vim.api.nvim_call_function("fnameescape", { p })
end

function M.escape(p, chars)
    return vim.api.nvim_call_function("escape", { p, chars })
end

function M.escape_termcodes(str)
    return vim.api.nvim_replace_termcodes(str, true, true, true)
end

local function getftype(p)
    return vim.api.nvim_call_function("getftype", {
        M.filename_escape(p),
    })
end

local function getcwd()
    return vim.api.nvim_call_function("getcwd", {})
end

-- Input function: use vim.ui if available, otherwise roll-out our own
if vim.ui ~= nil and vim.ui.input ~= nil then
    M.input = vim.ui.input
else
    M.input = function(dictionary, callback)
        local result = vim.fn.input(dictionary)
        callback(result)
    end
end

M.getqflist = function()
    local result = vim.api.nvim_call_function("getqflist", {
        { all = 0 },
    })
    return result
end

M.file_readable = function(p)
    return vim.api.nvim_call_function("filereadable", {
        M.filename_escape(p),
    })
end

M.file_exists = function(p)
    local r = getftype(p)
    if r == "file" then
        return true
    end
    return false
end

M.dir_exists = function(p)
    local r = getftype(p)
    if r == "dir" then
        return true
    end
    return false
end

local function get_makeprg(p)
    local command = ""

    p = p or getcwd()

    local cmake = M.file_exists(p .. "/CMakeLists.txt")
    local meson = M.file_exists(p .. "/meson.build")
    local cargo = M.file_exists(p .. "/Cargo.toml")
    local latexmkrc = M.file_exists(p .. "/.latexmkrc")
    local make = M.file_exists(p .. "/Makefile")
    local zig = M.file_exists(p .. "/build.zig")
    local package_json = M.file_exists(p .. "/package.json")
    local maven = M.file_exists(p .. "/pom.xml")
    local gradle = M.file_exists(p .. "/build.gradle")
    local gradle_w = M.file_exists(p .. "/gradlew")
    local build_dot_sh = M.file_exists(p .. "/build.sh")

    if build_dot_sh then
        command = "bash '" .. p .. "/build.sh'"
    elseif (cmake or meson) and M.file_exists(p .. "/build/Debug/build.ninja") then
        command = "ninja -C '" .. p .. "/build/Debug' all"
    elseif (cmake or meson) and M.file_exists(p .. "/build/build.ninja") then
        command = "ninja -C '" .. p .. "/build' all"
    elseif make then
        command = "make -j 8 all"
    elseif cmake and M.dir_exists(p .. "/build/Debug") then
        command = "cmake --build '" .. p .. "/build/Debug' --config Debug -j 8"
    elseif cmake and M.dir_exists(p .. "/build") then
        command = "cmake --build '" .. p .. "/build' --config Debug -j 8"
    elseif cargo then
        command = "cargo build --manifest-path '" .. p .. "/Cargo.toml'"
    elseif package_json then
        command = "npx npm build"
    elseif zig then
        command = "zig build"
    elseif latexmkrc then
        command = "latexmk -pdf"
    elseif maven then
        vim.cmd [[ compiler! maven ]]
        command =
            "mvn --offline --no-snapshot-updates -T1C -Dparallel=all -DperCoreThreadCount=false -DthreadCount=4 -Dmaven.compiler.debug=true -Dmaven.compiler.debuglevel=lines,vars,source -Dmaven.test.skip=true -Dmaven.javadoc.skip=true -DskipTests=true --also-make-dependents compile"
    elseif gradle and gradle_w then
        command = p .. "/gradlew build"
    elseif gradle and not gradle_w then
        command = "gradle build"
    else
        -- Default in case nothing was matched
        command = "make"
    end

    return command
end

M.update_makeprg = function(p)
    vim.o.makeprg = get_makeprg(p)
end

M.set_makeprg = function(p)
    local command = nil

    local invalid_previous_makeprg = (
        vim.o.makeprg == nil
        or vim.o.makeprg == ""
        or vim.startswith(vim.o.makeprg, " ")
        or vim.startswith(vim.o.makeprg, "\n")
        or vim.startswith(vim.o.makeprg, "#")
    )

    if invalid_previous_makeprg then
        command = get_makeprg(p)
    else
        command = vim.o.makeprg
    end
    local opts = {
        prompt = "Set build command: ",
        default = command,
    }

    local callback = function(param)
        if param ~= nil then
            vim.o.makeprg = param
        end
    end

    M.input(opts, callback)
end

M.project_wide_search = function(p)
    local opts = {
        prompt = "Search term: ",
        default = p,
    }
    local callback = function(param)
        if param ~= nil then
            local command = [[:Rg ]] .. param
            vim.fn.execute(command)
        end
    end
    M.input(opts, callback)
end

M.lsp.show_line_diagnostics = function()
    local opts = {
        focusable = false,
        close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
        border = "rounded",
        source = "always", -- show source in diagnostic popup window
        prefix = " ",
    }
    vim.diagnostic.open_float(nil, opts)
end

M.load_color_scheme = function(colorscheme)
    -- Try to load colorscheme if it exists, without throwing millions of errors
    -- and breaking the user config if the colorscheme does not exist
    local status_ok, _ = pcall(vim.cmd, "colorscheme " .. colorscheme)
    if not status_ok then
        vim.notify("colorscheme " .. colorscheme .. " not found!")
    end
    return status_ok
end

M.post_build = function()
    local qflist = M.getqflist()
    local items = qflist.items

    local ntotal = 0
    local nerrs = 0
    local nwarns = 0

    for _, v in ipairs(items) do
        if v.bufnr > 0 and v.valid == 1 then
            ntotal = ntotal + 1
            -- If the entry's type is set, then use it
            if v.type == "E" then
                nerrs = nerrs + 1
            elseif v.type == "W" then
                nwarns = nwarns + 1
            else
                -- If the type is not set, then resort back to a very naive/crude
                -- string find method. Ideally we should use the errorformat
                -- string here to know exactly the type of the error message.
                local low = string.lower(vim.trim(v.text))

                local is_err = vim.startswith(low, "error:")
                local is_warn = vim.startswith(low, "warn:") or vim.startswith(low, "warning:")

                if is_err then
                    nerrs = nerrs + 1
                elseif is_warn then
                    nwarns = nwarns + 1
                end
            end
        end
    end

    if ntotal >= 1 then
        vim.fn.execute "normal! :copen\n"
        vim.fn.execute "normal! :cw\n"
        vim.fn.execute "normal! :crewind\n"
        vim.fn.execute "normal! :cnext\n"
    else
        vim.fn.execute "normal! :cclose\n"
    end

    local msg = vim.o.makeprg .. "\n" .. tostring(nerrs) .. " errors, " .. tostring(nwarns) .. " warnings"
    local notifylvl = nil

    if nerrs >= 1 then
        notifylvl = "error"
    elseif ntotal >= 1 then
        notifylvl = "warn"
    else
        notifylvl = "info"
    end

    require "notify"(msg, notifylvl, { title = "Build status", timeout = 1000 })
end

M.build = function()
    if vim.o.makeprg == nil or vim.o.makeprg == "" then
        M.update_makeprg()
    end
    print(vim.o.makeprg)

    vim.fn.execute "normal! :wa\n"
    vim.fn.execute "normal! :silent Make\n\n"
end

function M.get_selection()
    -- does not handle rectangular selection
    local s_start = vim.fn.getpos "'<"
    local s_end = vim.fn.getpos "'>"
    local n_lines = math.abs(s_end[2] - s_start[2]) + 1
    local lines = vim.api.nvim_buf_get_lines(0, s_start[2] - 1, s_end[2], false)
    lines[1] = string.sub(lines[1], s_start[3], -1)
    if n_lines == 1 then
        lines[n_lines] = string.sub(lines[n_lines], 1, s_end[3] - s_start[3] + 1)
    else
        lines[n_lines] = string.sub(lines[n_lines], 1, s_end[3])
    end
    return lines
end

function M.eval_lua()
    local str = "pcall(function()\n"
    local t = M.get_selection()
    for _, v in ipairs(t) do
        str = "    " .. str .. v .. "\n"
    end
    str = str .. "\nend)\n"

    -- print(str)
    vim.api.nvim_eval(str)
end

return M
