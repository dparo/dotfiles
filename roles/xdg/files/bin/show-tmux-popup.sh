#!/usr/bin/env bash
# -*- coding: utf-8 -*-

session="_popup_$(tmux display -p '#S')"
has_session=1

if ! tmux has -t "$session" 2> /dev/null; then
  session_id="$(tmux new-session -dP -s "$session" -F '#{session_id}')"
  tmux set-option -s -t "$session_id" key-table popup
  tmux set-option -s -t "$session_id" status off
  tmux set-option -s -t "$session_id" prefix None
  session="$session_id"
  has_session=0
fi


if [ $# -eq 0 ]; then
  # No arguments → just attach
  tmux attach -t "$session"
else
  # With arguments → create new window running command
  tmux attach -t "$session" \; new-window $@
fi
