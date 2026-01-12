#!/usr/bin/env bash
# -*- coding: utf-8 -*-

set -x

##
## Under the hood uses DBUS org.mpris.MediaPlayer2 interface
##
# playerctl -p spotify pause
# playerctl -p spotify play-pause
# playerctl -p spotify play-pause
# playerctl -p spotify stop
# playerctl -p spotify stop
# playerctl -p spotify next
# playerctl -p spotify next
# playerctl -p spotify previous
# playerctl -p spotify previous
# playerctl -p spotify volume 0.05+
# playerctl -p spotify volume 0.05-


mediaplayer="spotify"

playerctl -l | grep -Ei '^spotify$'
spotify_app_running=$?

if test "$spotify_app_running" -ne 0; then
    spotifyd_pid="$(pidof spotifyd)"
    if test "$?" -eq 0; then
        mediaplayer="spotifyd.instance${spotifyd_pid}"
    fi
fi


dbus_send() {
    arg1="$1"
    shift 1
    # https://specifications.freedesktop.org/mpris-spec/2.2/Player_Interface.html
    dbus-send --print-reply --dest="org.mpris.MediaPlayer2.${mediaplayer}" /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player."$arg1" "$@"
}


arg1="$1"
shift 1
case "$arg1" in
    play)
        dbus_send Play "$@" || playerctl -p "$mediaplayer" play || playerctl play;;
    pause)
        dbus_send Pause "$@" || playerctl -p "$mediaplayer" pause || playerctl pause;;
    play-pause|toggle)
        dbus_send PlayPause "$@" || playerctl -p "$mediaplayer" play-pause || playerctl play-pause;;
    stop)
        dbus_send Stop "$@" || playerctl -p "$mediaplayer" stop || playerctl stop;;
    next)
        dbus_send Next "$@" || playerctl -p "$mediaplayer" next || playerctl next;;
    prev|previous|prior)
        dbus_send Previous "$@" || playerctl -p "$mediaplayer" previous || playerctl previous;;
    mute)
        dbus_send Volume 0.0 "$@" || playerctl -p "$mediaplayer" volume 0.0 || playerctl volume 0.0;;
    volume-up)
        dbus_send VolumeUp || playerctl -p "$mediaplayer" volume 0.05+ || playerctl volume 0.05+;;
    volume-down)
        dbus_send VolumeDown || playerctl -p "$mediaplayer" volume 0.05- || playerctl volume 0.05-;;
esac
