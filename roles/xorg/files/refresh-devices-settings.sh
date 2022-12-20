#!/usr/bin/env bash
# -*- coding: utf-8 -*-

cd "$(dirname "$0")" || exit 1

touchpad_setup() {
	xinput --set-prop "Elan Touchpad" 'libinput Accel Speed' 0
	xinput --set-prop "Elan Touchpad" "Device Accel Profile" 0

	xinput --set-prop "Elan Touchpad" "libinput Tapping Enabled" 1
	xinput --set-prop "Elan Touchpad" "libinput Middle Emulation Enabled" 1
	xinput --set-prop "Elan Touchpad" "libinput Disable While Typing Enabled" 1
	xinput --set-prop "Elan Touchpad" "libinput Natural Scrolling Enabled" 1 # Reverse scrolling
}

touchpad_setup 1> /dev/null 2> /dev/null


xset -b # disable bell

xset r rate 300 30

# Set keyboard layout, and compose international chars with R-Alt
setxkbmap -layout us -option ctrl:nocaps,compose:ralt -option terminate:ctrl_alt_bksp
