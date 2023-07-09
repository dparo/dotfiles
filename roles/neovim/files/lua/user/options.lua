-- Spell checking
vim.o.encoding = "utf-8"
vim.o.spelllang = "en"
vim.o.title = true
vim.o.ignorecase = true
vim.o.lazyredraw = false
vim.o.history = 4096

vim.o.selection = "exclusive"

vim.o.background = "dark"
vim.o.guifont = "JetBrainsMono Nerd Font Mono:h10.5"

vim.o.list = true
-- vim.o.listchars = "tab:› ,eol:¬,trail:⋅
vim.o.listchars = "tab:› ,trail:⋅"

vim.o.statusline = "%f %h%w%m%r%=%y %{&fileformat} %{&fileencoding?&fileencoding:&encoding}    %-14.(%l,%c%V%) %P"

vim.o.swapfile = false
vim.o.backup = false
vim.o.undofile = true
vim.o.writebackup = false

vim.o.wrap = false
vim.o.showbreak = "↳"

vim.o.signcolumn = "auto:3"

vim.o.showmode = false
vim.o.cursorline = true
vim.o.scrolloff = 4
vim.o.sidescrolloff = 8
vim.o.hlsearch = true
vim.o.number = true
vim.o.ruler = true
vim.o.autoindent = true
vim.o.backspace = "indent,eol,start"
vim.o.incsearch = true
vim.o.gdefault = true -- When on, the :substitute flag 'g' is default on. This means that all matches in a line are substituted instead of one
vim.o.showcmd = true
vim.o.cmdheight = 1 -- Number of screen lines to use for the command-line.  Helps avoiding |hit-enter| prompts if raised.
vim.o.tabstop = 4
vim.o.softtabstop = 4
vim.o.expandtab = true
vim.o.shiftwidth = 4
vim.o.smarttab = true
vim.o.smartindent = true
vim.o.smartcase = true
vim.o.cindent = true
vim.o.breakindent = true
-- Show live results of search and replace.
vim.o.inccommand = "nosplit"

vim.o.hidden = true
vim.o.wildmode = "longest,list,full"
vim.o.wildmenu = true
vim.o.wildignore = ".git,.hg,.svn,*~,*.png,*.jpg,*.gif,*.settings,Thumbs.db,*.min.js,*.swp,publish/*,intermediate/*,*.o,*.hi,Zend,vendor"

vim.o.completeopt = "menuone,noinsert,noselect"
-- Avoid showing message extra message when using completion
vim.o.shortmess = vim.o.shortmess .. "c"
vim.o.pumheight = 16

vim.o.mouse = "a"
vim.o.errorbells = false
vim.o.conceallevel = 0
vim.o.whichwrap = "b,s,<,>,[,]"
vim.o.clipboard = "unnamedplus"

-- Global status line
vim.o.laststatus = 3

vim.o.belloff = "all"

vim.o.splitbelow = true
vim.o.splitright = true

-- Automatically updates the file on external changes
vim.o.autoread = true

-- Remove the `c` from formatoptions to avoid continuining
-- comments when creating a newline
vim.o.formatoptions = "tcqj"

-- Timeout used to resolve ambiguity about key sequence presses
-- That is if `<C-x><C-s>` and `<C-x>` alone are both mapped to
-- 2 different commands, nvim waits timeoutlen (if timeout is set)
-- for a following keystroke before determining that the user really
-- wanted to type <C-x> alone
vim.o.timeout = true
vim.o.timeoutlen = 1000

-- Same concept of timeout above, but for terminal escape sequences. Due to
-- latency when VIM finds an escape key it needs to wait a little bit to
-- determine if the user really typed <Escape>, or a keychord combination.
-- The higher, the less false positives but less usable when using escape.
-- If too low and the connection is slow (example SSH or even TMUX since it
-- adds latency), keychords combination may be incorrectly classified as
-- <Escape> keys
vim.o.ttimeout = true
vim.o.ttimeoutlen = 20

-- Number of milliseconds before triggering a cursorhold autocommand
vim.o.updatetime = 250

-- Winbar support nvim version 0.8 and above
if vim.fn.has "nvim-0.8" == 1 then
    vim.o.winbar = "=%=%m %f"
    vim.o.laststatus = 2
    vim.o.cmdheight = 1

    vim.o.spell = false
end

vim.o.makeprg = ""

if vim.fn.executable "rg" then
    vim.o.grepprg = "rg --smart-case --follow --hidden --vimgrep --glob=!.git/ $*"
    vim.o.grepformat = "%f:%l:%c:%m"
elseif vim.fn.executable "ag" then
    vim.o.grepprg = "ag --smart-case --follow --hidden --vimgrep --ignore .git/ $*"
    vim.o.grepformat = "%f:%l:%c:%m"
end

vim.g.termdebug_wide = 1
vim.g.tex_flavor = "latex" -- Sometimes .tex files are opened in vim as ft=plaintex. This defaults to open all .tex files with ft=tex

-- Load native gdb plugin bundled with neovim, use TermdebugCommand to start debugging with GDB
vim.cmd [[ packadd termdebug ]]
