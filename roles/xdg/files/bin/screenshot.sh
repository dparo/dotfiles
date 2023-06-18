#!/usr/bin/env bash

set -e

mkdir -p "$HOME/Pictures/Screenshots/"
location="$HOME/Pictures/Screenshots/Screenshot$(date +%Y-%m-%d_%H:%M:%S).png"
maim -m 9 -s "$location"
mpv --keep-open=no /usr/share/sounds/freedesktop/stereo/screen-capture.oga 1> /dev/null 2> /dev/null &
xclip -selection clipboard -t "image/png" < "$location"
dunstify -i camera-photo-symbolic "Screenshot taken" "Screenshot saved into clipboard!"
