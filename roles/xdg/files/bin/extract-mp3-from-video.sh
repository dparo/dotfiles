#!/usr/bin/env bash
# -*- coding: utf-8 -*-

cd "$(dirname "$0")" || exit 1

fullfile="$1"
dirname="$(dirname -- "$fullfile")"
filename=$(basename -- "$fullfile")
filename="${filename%.*}"

set -x
exec ffmpeg -i "$fullfile" -vn -acodec libmp3lame "$dirname/$filename.mp3"
