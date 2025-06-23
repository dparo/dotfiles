#!/usr/bin/env bash

# Usage:
#   tab-align-columns.sh [filename]

# If no filename is given, reads from stdin.

if [ $# -eq 0 ]; then
    # No arguments; read from stdin
    sed -E 's/ +/\t/g' | column -t -s $'\t'
elif [ $# -eq 1 ]; then
    # One argument; treat as filename
    sed -E 's/ +/\t/g' "$1" | column -t -s $'\t'
else
    echo "Usage: $0 [filename]" >&2
    exit 1
fi

