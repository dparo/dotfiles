#!/usr/bin/env bash


cat \
    | egrep -i -o '("|^)/watch.*("|$)' \
    | uniq \
    | sed 's/^"//g' | sed 's/&amp;list=.*$//g' \
    | xargs -I {} echo "yt:https://www.youtube.com/{}" \
    | xargs -l512 -I {} mpc add {}
