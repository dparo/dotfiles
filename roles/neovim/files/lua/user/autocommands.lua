--
-- Associate to specific path patterns a filetype
--

do
    local status_ok, _ = pcall(require, "filetype")
    if status_ok then
        require("filetype").setup {
            overrides = {
                complex = {
                    [".*.mutt-.*"] = "mail",
                    [".*/.config/i3/config"] = "i3config",
                    [".envrc$"] = "sh",
                    [".direnvrc$"] = "sh",
                    ["direnvrc$"] = "sh",
                    [".*.curl$"] = "sh",
                    [".*.httpie$"] = "sh",
                    [".*.properties$"] = "config",
                    [".*.socket$"] = "systemd",
                    [".*.service$"] = "systemd",
                    [".*.session$"] = "systemd",
                    [".*.target$"] = "systemd",
                },
            },
        }
    end
end

-- Skeletons for new files
core.utils.augroup("USER_SKELETONS", {
    { "BufNewFile", { pattern = "*.{h}", command = [[0r ~/.config/nvim/skeletons/c.h]] } },
    { "BufNewFile", { pattern = "*.{hpp}", command = [[0r ~/.config/nvim/skeletons/c.hpp]] } },
    { "BufNewFile", { pattern = "*.{js}", command = [[0r ~/.config/nvim/skeletons/js.js]] } },
    { "BufNewFile", { pattern = "*.{sh,bash}", command = [[0r ~/.config/nvim/skeletons/sh.sh]] } },
    { "BufNewFile", { pattern = "*.{http}", command = [[0r ~/.config/nvim/skeletons/http.http]] } },
    { "BufNewFile", { pattern = "*.{py}", command = [[0r ~/.config/nvim/skeletons/python.py]] } },
    { "BufNewFile", { pattern = "*.{html}", command = [[0r ~/.config/nvim/skeletons/html.html]] } },
    { "BufNewFile", { pattern = "*.{xhtml}", command = [[0r ~/.config/nvim/skeletons/xhtml.xhtml]] } },
    { "BufNewFile", { pattern = ".envrc,.direnvrc,direnvrc", command = [[0r ~/.config/nvim/skeletons/.envrc]] } },
    { "BufNewFile", { pattern = "Makefile", command = [[0r ~/.config/nvim/skeletons/Makefile]] } },
    { "BufNewFile", { pattern = ".editorconfig", command = [[0r ~/.config/nvim/skeletons/.editorconfig]] } },
    { "BufNewFile", { pattern = "*.desktop", command = [[0r ~/.config/nvim/skeletons/desktop.desktop]] } },
    { "BufNewFile", { pattern = "*.vue", command = [[0r ~/.config/nvim/skeletons/vue.vue]] } },
    { "BufNewFile", { pattern = "*.svelte", command = [[0r ~/.config/nvim/skeletons/svelte.svelte]] } },
    { "BufNewFile", { pattern = "*.{adoc,asciidoc}", command = [[0r ~/.config/nvim/skeletons/adoc.adoc]] } },
    { "BufNewFile", { pattern = "pom.xml", command = [[0r ~/.config/nvim/skeletons/pom.xml]] } },

    {
        "BufNewFile",
        { pattern = ".pre-commit-config.yaml", command = [[0r ~/.config/nvim/skeletons/.pre-commit-config.yaml]] },
    },
})

-- Filetypes autocommand
core.utils.augroup("USER_FILETYPES", {
    {
        { "FileType" },
        {
            pattern = { "gitcommit", "gitrebase", "gitconfig" },
            callback = function()
                vim.bo.bufhidden = "delete"
            end,
        },
    },
    { { "FileType" }, {
        pattern = "gitcommit",
        callback = function()
            vim.w.wrap = true
        end,
    } },
    { { "FileType" }, {
        pattern = "gitcommit,markdown",
        callback = function()
            vim.w.spell = true
        end,
    } },
    -- Stop comment continuation when entering a new line inside a comment
    { { "BufWritePost" }, { pattern = "*", command = [[ setlocal formatoptions-=cro ]] } },

    -- Resource specific configuration files for external programs
    {
        { "BufWritePost" },
        { pattern = { "*.config/i3/config", "*.config/i3/config.d/*" }, command = [[ silent !i3-msg restart ]] },
    },
    { { "BufWritePost" }, { pattern = "*.config/sxhkd/sxhkdrc", command = [[ silent !pkill -USR1 -x sxhkd ]] } },
})

core.utils.augroup("USER_GENERIC", {
    -- Reload the buffer if it was changed externally
    {
        { "FocusGained", "BufEnter", "CursorHold", "CursorHoldI" },
        { pattern = "*", command = [[if mode() != 'c' | checktime | endif]] },
    },

    -- Notification after file change
    {
        { "FileChangedShellPost" },
        {
            pattern = "*",
            command = [[ echohl WarningMsg | echo "File changed on disk. Buffer reloaded." | echohl None ]],
        },
    },

    -- Readjusts window dimension when vim changes size
    { { "VimResized" }, { pattern = "*", command = [[tabdo wincmd =]] } },

    -- Cursorline enable/disable
    { { "WinEnter" }, {
        pattern = "*",
        callback = function()
            vim.wo.cursorline = true
        end,
    } },
    { { "WinLeave" }, {
        pattern = "*",
        callback = function()
            vim.wo.cursorline = false
        end,
    } },

    -- Create parent directory of file when saving if it does not exist
    { { "BufWritePre" }, { pattern = "*", command = [[call mkdir(expand("<afile>:p:h"), "p")]] } },

    -- Flash yanked region
    {
        { "TextYankPost" },
        { pattern = "*", command = [[silent! lua require('vim.highlight').on_yank({higroup = 'Search', timeout = 200})]] },
    },

    -- Post build
    { { "QuickfixCmdPost" }, { pattern = "make", callback = user.utils.post_build } },

    -- When editing a file, always jump to the last known cursor position.
    -- Don't do it when the position is invalid, when inside an event handler
    -- (happens when dropping a file on gvim) and for a commit message (it's
    --  likely a different one than last time).
    -- NOTE(dparo): 5 Jan 2022:
    --     Disabled, since it conflicts with cmdline syntax `$> nvim +{line} <file>`
    --     and thus I cannot spawn neovim from the command line at a specific line location
    --     (eg useful when using gdb, or external shell scripts)
    {
        { "BufReadPre" },
        {
            pattern = "*",
            command = [[if line("'\"") >= 1 && line("'\"") <= line("$") && &ft !~# 'commit' | exe "normal! g`\"" | endif ]],
        },
    },

    -- Chezmoi
    {
        { "BufWritePost" },
        { pattern = vim.env.HOME .. "/.local/share/chezmoi/src/*", command = [[! chezmoi apply --source-path "%"]] },
    },
})
