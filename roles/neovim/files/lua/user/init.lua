local M = {}
_G.user = M

M.utils = require "user.utils"
require "user.options"
require "user.mappings"

-- Setup lazy.nvim
local running_headless = next(vim.api.nvim_list_uis()) == nil -- If dictionaries of UIs is empty => headless mode

local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"

if not running_headless and not vim.loop.fs_stat(lazypath) then
    vim.api.nvim_set_hl(0, "NormalFloat", { bg = "#1e222a" })
    print "Cloning lazy.nvim .."

    vim.fn.system {
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", -- latest stable release
        lazypath,
    }

    vim.fn.system {
        "rm",
        "-rf",
        vim.env.HOME .. "/.config/nvim/plugin/packer_compiled.lua",
    }
end

vim.opt.rtp:prepend(lazypath)
require("lazy").setup(require("user.plugins"), {})
require "user.theme"
require "user.autocommands"
require "user.abbreviations"
