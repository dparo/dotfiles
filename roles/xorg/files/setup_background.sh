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


xsetroot -cursor_name left_ptr

set_wallpaper \
    /usr/share/backgrounds/gnome/adwaita-l.* \
    /usr/share/backgrounds/f40/default/f*-01-night.png \
    "${XDG_DATA_HGOME:-"$HOME/.local/share"}/backgrounds/fedora.jpeg" \
    /usr/share/backgrounds/gnome/adwaita-d.* \
    /usr/share/backgrounds/gnome/adwaita-l.* \
    /usr/share/backgrounds/fedora-workstation/montclair_dark.webp \
    /usr/share/backgrounds/gnome/adwaita-l.* \
    || xsetroot -solid darkgray
