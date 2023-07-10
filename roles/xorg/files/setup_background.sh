#!/usr/bin/env bash

set -x

set_wallpaper() {
    for v in "$@"; do
        if [ "$v" != "" ] && [ -f "$v" ]; then
            (feh --no-fehbg --bg-fill "$v" || nitrogen --set-zoom-fill "$v") && return 0
        fi
    done
    return 1
}

set_wallpaper \
    /usr/share/backgrounds/gnome/adwaita-d.webp \
    /usr/share/backgrounds/default* \
    /usr/share/backgrounds/f38/default/f38-01-day.png  \
    /usr/share/backgrounds/f37/default/f37.webp  \
    /usr/share/backgrounds/gnome/adwaita-d.webp \
    /usr/share/backgrounds/fedora-workstation/glasscurtains_dark.webp \
    || xsetroot -solid darkgray
