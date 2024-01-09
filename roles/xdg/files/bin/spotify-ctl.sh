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

spotifyd_pid="$(pidof spotifyd)"
if test "$?" -eq 0; then
    mediaplayer="spotifyd.instance${spotifyd_pid}"
fi


dbus_send() {
    arg1="$1"
    shift 1
    # https://specifications.freedesktop.org/mpris-spec/2.2/Player_Interface.html
    exec dbus-send --print-reply --dest="org.mpris.MediaPlayer2.${mediaplayer}" /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player."$arg1" "$@"
}


arg1="$1"
shift 1
case "$arg1" in
    play)
        dbus_send Play "$@";;
    pause)
        dbus_send Pause "$@";;
    play-pause|toggle)
        dbus_send PlayPause "$@";;
    stop)
        dbus_send Stop "$@";;
    next)
        dbus_send Next "$@";;
    prev|previous)
        dbus_send Previous "$@";;
    volume-up)
        dbus_send VolumeUp ;;
    volume-down)
        dbus_send VolumeDown ;;
esac
