-- NOTE(d.paro): Using i_CTRL-O command to execute normal mode commands
--               while remaining in insert mode is highly discouraged if possible.
--               It exists insert mode, executes autocommands, runs the key sequence,
--               and goes back to insert mode.
--               Running the autocommands can be quite expensive, so use with care.
--               Prefer :exec normal! if possible

-- TODO(dparo)  11 June 2022
-- Should rewrite this entire file to use the new
--   vim.keymap API available from NVIM 0.7
--      - vim.keymap.set()
--      - vim.keymap.del()
--  See: https://github.com/nanotee/nvim-lua-guide#vimkeymap

_G.user = _G.user or {}
_G.user.binds = _G.user.binds or {}

local default_opts = { remap = false, silent = true }
local remappable_opts = vim.tbl_deep_extend("force", default_opts, { remap = true })
local term_opts = { silent = true }

local function fn_key(key)
    return "<F" .. tostring(key) .. ">"
end

local function shift_fn_key(key)
    return { "<S-F" .. tostring(key) .. ">", "<F" .. tostring(key + 12) .. ">" }
end

local function ctrl_fn_key(key)
    return { "<C-F" .. tostring(key) .. ">", "<F" .. tostring(key + 24) .. ">" }
end

local function keymap(mode, lhs, rhs, opts)
    if opts == nil then
        opts = default_opts
    end
    if type(lhs) == "table" then
        for _, v in ipairs(lhs) do
            vim.keymap.set(mode, v, rhs, opts)
        end
    else
        vim.keymap.set(mode, lhs, rhs, opts)
    end
end

local function unmap(mode, lhs)
    vim.keymap.del(mode, lhs)
end

local function map(lhs, rhs, opts)
    keymap("", lhs, rhs, opts)
end

local function vmap(lhs, rhs, opts)
    keymap("v", lhs, rhs, opts)
    keymap("s", lhs, rhs, opts)
end

local function nmap(lhs, rhs, opts)
    keymap("n", lhs, rhs, opts)
end

local function imap(lhs, rhs, opts)
    keymap("i", lhs, rhs, opts)
end

local function cmap(lhs, rhs, opts)
    keymap("c", lhs, rhs, opts)
end

local function nimap(lhs, rhs, opts)
    nmap(lhs, rhs, opts)
    imap(lhs, rhs, opts)
end

local function nvmap(lhs, rhs, opts)
    nmap(lhs, rhs, opts)
    vmap(lhs, rhs, opts)
end

local function nvimap(lhs, rhs, opts)
    nimap(lhs, rhs, opts)
    vmap(lhs, rhs, opts)
end

local function exec_lua(func)
    return "<Cmd> lua " .. func .. "<CR>"
end

local function exec_cmd(cmd)
    return "<Cmd> " .. cmd .. "<CR>"
end

local function exec_keepjumps(key)
    local escaped_key = user.utils.escape(key, [['\]])
    local preamble = "exec 'keepjumps normal! "
    return exec_cmd(preamble .. escaped_key .. "'")
end

local function exec_normal(key)
    local escaped_key = user.utils.escape(key, [['\]])
    local preamble = "exec 'normal! "
    return exec_cmd(preamble .. escaped_key .. "'")
end

--
-- Global lua bindings function
--
function user.binds.beginning_of_line()
    local line = vim.fn.getline "."
    local col = vim.fn.col "."
    local allblanks = true
    for i = col - 1, 1, -1 do
        local t = line:sub(i, i)
        local isblank = t == " " or t == "\t" or t == "\v"
        if not isblank then
            allblanks = false
            break
        end
    end

    if not allblanks or col == 1 then
        vim.fn.execute "keepjumps normal! ^"
    else
        vim.fn.execute "keepjumps normal! 0"
    end
end

local function setup_unbinds()
    --
    -- Unbind all function keys by default for insert mode
    --
    for i = 1, 12, 1 do
        imap(fn_key(i), "")
        imap(shift_fn_key(i), "")
        imap(ctrl_fn_key(i), "")
    end
    nvmap("<S-Up>", "")
    nvmap("<S-Down>", "")
    nvmap("<S-Right>", "")
    nvmap("<S-Left>", "")
    vmap("<C-z>", "")
end

local function setup_cursor_movements()
    ----
    ---- Cursor movements
    ----
    -- @NOTE: :keepjumps modifier command allows to execute the motion command without changing the jump list.
    -- @NOTE: The exclamation mark '!' in `normal` (eg `normal!`) means do not recursively expand
    --        the provided keybind in the rhs (eg use the default keybind representation)
    cmap("<C-a>", "<Home>", { noremap = false, silent = false })
    -- Begininning and of line
    nvimap("<C-a>", exec_lua "user.binds.beginning_of_line()")
    nvimap("<C-e>", "<End>")
    cmap("<C-e>", "<End>")

    -- Ctrl+Arrow keys to jump paragraphs and by words.
    nvmap("<C-Up>", exec_keepjumps "{zz")
    nvmap("<C-Down>", exec_keepjumps "}zz")
    nvmap("<C-Right>", "w")
    nvmap("<C-Left>", "b")

    imap("<C-Up>", exec_keepjumps "{zz")
    imap("<C-Down>", exec_keepjumps "}zz")
    imap("<C-Right>", "<S-Right>")
    imap("<C-Left>", "<S-Left>")

    -- Refresh screen and show where i am, and redraw the screen
    nvmap("<C-l>", "zz:redraw!<CR>")
    imap("<C-l>", "<C-O>zz<C-O>:redraw!<CR>")

    -- Visual block remapped to M-v
    nmap("<M-v>", "<C-V>")
end

local function setup_basic_functionalities()
    ----
    ---- Save, Undo, Redo, Copy, Cut, Delete, Search, Replace, Indent
    ----

    nmap("<leader>fw", exec_cmd "w")
    nmap("<leader>q", exec_cmd "q")

    nmap("<C-s>", "<Cmd>update<CR>")
    imap("<C-s>", "<Esc><Cmd>update<CR>gi")

    nmap("<C-z>", "u")
    imap("<C-z>", exec_normal "u")

    nmap({ "<C-S-z>", "<C-y>", "U" }, "<C-R>")
    imap({ "<C-S-z>", "<C-y>" }, exec_normal "<C-R>")
    nmap("<C-c>", "yy")
    imap("<C-c>", "<C-O>yy")
    vmap("<C-c>", "y")
    nmap({ "<C-v>", "<S-Insert>" }, "gP")
    imap({ "<C-v>", "<S-Insert>" }, "<C-R><C-P>+", { silent = false })
    cmap({ "<C-v>", "<S-Insert>" }, "<C-R>+", { silent = false })
    vmap({ "<C-v>", "<S-Insert>", "p" }, '"_dgP') -- When pasting over selected region, do not yank replaced region

    imap("<C-BS>", "<C-w>", { silent = true, noremap = false })
    imap("<C-h>", "<C-w>", { silent = true, noremap = false })

    cmap({ "<C-BS>", "<C-h>" }, "<C-w>")

    vmap({ "x", "d", "<C-w>", "<C-BS>", "<BS>", "<Del>" }, "d")
    nmap("<C-x>", "dd")
    imap("<C-x>", exec_normal "dd")
    vmap("<C-x>", "d")

    -- Kill line
    nimap("<C-k>", exec_normal '"_D')

    -- Indent, unindent
    vmap({ ">", "<Tab>" }, ">gv")
    vmap({ "<", "<S-Tab>" }, "<gv")
    imap("<S-Tab>", "<C-d>")

    -- Pressing backspace and delete in normal mode deletes and switches to insert mode
    nmap("<BS>", '"_Xi')
    nmap("<Del>", '"_xi')

    vmap("<Space>", "c")
    -- Pressing leader 2 times enters insert mode
    nmap("<leader><leader>", "i")

    -- Join lines
    vmap("<C-j>", "gq")

    --- Repeat q recorded macro
    nmap(",", "@q")
end

local function setup_window_controls()
    ----
    ---- Window controls
    ----
    nmap({ "<C-w>h", "<C-w>-", "<C-w>_" }, exec_cmd "split")
    nmap({ "<C-w>v", "<C-w>\\", "<C-w>|", "<C-w><CR>" }, exec_cmd "vsplit")
    nmap({ "<M-Left>", "<leader><Left>" }, exec_cmd "TmuxNavigateLeft")
    nmap({ "<M-Right>", "<leader><Right>" }, exec_cmd "TmuxNavigateRight")
    nmap({ "<M-Up>", "<leader><Up>" }, exec_cmd "TmuxNavigateUp")
    nmap({ "<M-Down>", "<leader><Down>" }, exec_cmd "TmuxNavigateDown")

    -- Create new tab
    nmap("<leader>fn", exec_cmd "enew")
    nmap("<leader>e", exec_cmd "enew")
    nmap({ "<leader>w|", "<leader>wh" }, exec_cmd "vsplit")
    nmap({ "<leader>w-", "<leader>w_", "<leader>wv" }, exec_cmd "split")
    --- Maximize current window
    nmap("<leader>wz", "<C-W>_<C-W>|")
end

local function setup_saner_defaults()
    ----
    ---- More saner defaults
    ----

    -- Unbind some keys that i always press by mistake, or that do behaviour that i don't want
    nmap("Q", "")
    nmap("gQ", "")

    --- Goto next, previous matches centers the line
    nvmap("n", exec_normal "nzzzv")
    nvmap("N", exec_normal "Nzzzv")
    nmap("J", exec_normal "mzJ`z")

    -- Remap <C-v> to <C-q> to test what nvim receives from the terminal
    imap("<C-q>", "<C-v>")

    -- Allow gf to open non existing files
    nmap("gf", exec_cmd "edit <cfile>")

    nmap("[[", "[[zz")
    nmap("]]", "]]zz")
    nmap("g[", "<C-^>")

    -- Better undo break points, so when pressing undo, vim doesn't undo way too much typing like it usually does
    for _, v in ipairs { ",", ".", "!", "?", ":", ":", "'", '"', "(", ")", "[", "]", "{", "}", "<Space>" } do
        imap(v, v .. "<C-g>u")
    end

    -- Avoid polluting the clipboard when changing text
    for _, v in ipairs { "c", "C" } do
        vmap(v, '"_' .. v, nil)
        nmap(v, '"_' .. v, nil)
    end
end

local function setup_commands()
    ----
    ---- Commands
    ----
    nimap(fn_key(1), exec_cmd "noh")
    nmap({ "<leader>cc", fn_key(7) }, exec_lua "user.utils.build()")
    nmap({ "<leader>c<F2>", "<leader>ce", "<leader>cr", unpack(shift_fn_key(7)) }, exec_lua "user.utils.set_makeprg()")
    nmap("<leader>/", exec_lua "user.utils.project_wide_search()")

    -- Jump to errors
    nimap(fn_key(6), exec_cmd "cfirst")
    nimap(shift_fn_key(6), exec_cmd "cw")
    nmap({ "<leader>n", "<leader>cn", fn_key(8) }, exec_cmd "cnext")
    nmap({ "<leader>p", "<leader>cp", unpack(shift_fn_key(8)) }, exec_cmd "cprev")

    -- Copy releative path of file to clipboard
    vim.keymap.set("n", "yp", function()
        vim.fn.execute [[let @+ = expand("%")]]
    end)
end

local function setup_plugins()
    ----
    ---- Plugins
    ----
    nimap("<C-b>", exec_cmd "Telescope buffers theme=ivy")

    vim.keymap.set("n", "<leader>ff", function()
        require("telescope.builtin").find_files {
            find_command = {
                "rg",
                "-S",
                "--files",
                "--hidden",
                "-g",
                "!.ccls-cache",
                "-g",
                "!.git",
                "-g",
                "!.vcs",
                "-g",
                "!.svn",
            },
        }
    end, { desc = "[F]ind [F]iles" })

    nmap("<C-r>", exec_cmd "Telescope command_history")
    nmap("<M-x>", exec_cmd "Telescope commands")
    nmap({ "<C-\\>", "<leader><leader>" }, exec_cmd "NvimTreeFindFileToggle")
    nmap("<M-q>", exec_cmd "TroubleToggle document_diagnostics")

    -- Toggle between C source file and H header files
    -- nimap(fn_key(12), exec_cmd "ClangdSwitchSourceHeader")
    nmap("<leader>u", exec_cmd "UndotreeToggle")
    -- Move lines up and down
    vmap("K", "<Plug>MoveBlockUp", remappable_opts)
    vmap("J", "<Plug>MoveBlockDown", remappable_opts)
    vmap("L", "<Plug>MoveBlockRight", remappable_opts)
    vmap("H", "<Plug>MoveBlockLeft", remappable_opts)
    vmap("<S-PageUp>", "<Plug>MoveBlockHalfPageUp", remappable_opts)
    vmap("<S-PageDown>", "<Plug>MoveBlockHalfPageDown", remappable_opts)

    nimap({ "<M-p>" }, exec_cmd 'lua require("telescope").extensions.neoclip.default()')

    -- Align text
    nvmap("ga", "<Plug>(EasyAlign)", remappable_opts)

    -- Trouble plugin

    nmap({ "<leader>xx", "<leader>lx" }, exec_cmd "TroubleToggle")
    nmap("<leader>xw", exec_cmd "TroubleToggle lsp_workspace_diagnostics")
    nmap("<leader>xd", exec_cmd "TroubleToggle lsp_document_diagnostics")
    nmap("<leader>xq", exec_cmd "TroubleToggle quickfix")
    nmap("<leader>xl", exec_cmd "TroubleToggle loclist")
    nmap("gR", exec_cmd "TroubleToggle lsp_references")

    -- Spectre
    vim.keymap.set("n", "<leader>S", function()
        require("spectre").open()
    end)
    vim.keymap.set("n", "<leader>sw", function()
        require("spectre").open_visual { select_word = true }
    end)
    -- Spectre
    vim.keymap.set("v", "<leader>s", function()
        require("spectre").open_visual()
    end)

    -- SSR: Structurale search and replace
    vim.keymap.set({ "n", "x" }, "<leader>sr", function()
        require("ssr").open()
    end)

    -- Git
    nmap("<leader>gG", exec_cmd "Neogit")
    nmap("<leader>gg", exec_cmd "LazyGit")
    nmap("<leader>g?", exec_cmd "Git blame")
    nmap("<leader>gb", exec_cmd "Git blame")
    nmap("<leader>gd", exec_cmd "Gdiffsplit")
    nmap("<leader>gs", exec_cmd "Git status")
    nmap("<leader>gp", exec_cmd "Git push")
    nmap("<leader>gP", exec_cmd "Git pull")
    nmap("<leader>gc", exec_cmd "Git commit")
    nmap("<leader>gw", exec_cmd "Git commit -n")
    nmap("<leader>ga", exec_cmd "Git add %")

    vim.keymap.set("n", "<leader>rr", function()
        vim.fn.execute "source ~/.config/nvim/init.lua"
    end, { silent = false })
end

setup_unbinds()
setup_cursor_movements()
setup_basic_functionalities()
setup_window_controls()
setup_saner_defaults()
setup_commands()
setup_plugins()

local t = function(str)
    return vim.api.nvim_replace_termcodes(str, true, true, true)
end

local neovim_native_completion_is_candidate_selected = function()
    local result = vim.fn.complete_info { "selected" }
    return result["selected"] >= 0
end

local has_words_before = function()
    local line, col = unpack(vim.api.nvim_win_get_cursor(0))
    return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match "%s" == nil
end

local feedkey = function(key, mode)
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(key, true, true, true), mode, true)
end
