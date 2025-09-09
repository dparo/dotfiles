-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This will hold the configuration.
local config = wezterm.config_builder()

config.automatically_reload_config = false

config.default_prog = { "/usr/bin/fish" }


config.enable_tab_bar = false
config.hide_tab_bar_if_only_one_tab = true
config.window_decorations = "NONE"

config.font_size = 10
config.font = wezterm.font 'BlexMono Nerd Font'
config.color_scheme = 'tokyonight_storm'

return config

