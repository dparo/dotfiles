local path = require "core.os.path"

-- Get the config file path containing the init.lua
local configPath = path.get_nvim_config_path()
local dataPath = path.get_nvim_data_path()
local cachePath = path.get_nvim_cache_path()

vim.o.shell = "zsh"

local leaderkey = " "
vim.g.mapleader = leaderkey
vim.g.maplocalleader = leaderkey

-- The shada file remembers the last state of vim: command line history, search history, file marks
vim.o.shadafile = path.concat {cachePath, "shada" }
vim.o.undodir = path.concat { cachePath, "nvim", "undo" }

vim.cmd [[
    filetype indent on
    filetype plugin on
    syntax enable
]]

-- Setup the LUA package path so that require-ing works
package.path = configPath .. "/?.lua;" .. package.path
