#!/usr/bin/env bash
# -*- coding: utf-8 -*-

cd "$(dirname "$0")" || exit 1

set -x

touchpad_setup() {
    for input in "Elan Touchpad" "MSFT0001:01 06CB:CE2D Touchpad"; do
        xinput --set-prop "$input" 'libinput Accel Speed' 0
        xinput --set-prop "$input" "Device Accel Profile" 0

        xinput --set-prop "$input" "libinput Tapping Enabled" 1
        xinput --set-prop "$input" "libinput Middle Emulation Enabled" 1
        xinput --set-prop "$input" "libinput Disable While Typing Enabled" 1
        xinput --set-prop "$input" "libinput Natural Scrolling Enabled" 1 # Reverse scrolling
    done
}

touchpad_setup 1>/dev/null 2>/dev/null

[[ -f "/etc/X11/xinit/.Xresources" ]] && xrdb -merge "/etc/X11/xinit/.Xresources"
[[ -f "$XDG_CONFIG_HOME/xorg/.Xresources" ]] && xrdb -merge "$XDG_CONFIG_HOME/xorg/.Xresources"

xset -b # disable bell

xset r rate 300 30

# Set keyboard layout, and compose international chars with R-Alt
# setxkbmap -layout us -option compose:ralt,terminate:ctrl_alt_bksp
setxkbmap -layout us -option compose:ralt,terminate:ctrl_alt_bksp,ctrl:nocaps      # Remaps also CapsLock to Ctrl
