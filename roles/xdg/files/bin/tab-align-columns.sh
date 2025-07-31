#!/usr/bin/env bash

# Usage:
#   tab-align-columns.sh [separator_regex] [filename]
#   If no separator_regex is given, defaults to ' +' (one or more spaces).
#   If no filename is given, reads from stdin.

SEP_CHAR=""
SEP_REGEX="${SEP_CHAR} +"

# Check if the first argument looks like a regex or a file
if [ $# -eq 0 ]; then
    # No args: use default sep, read from stdin
    sed -E "s/${SEP_REGEX}/${SEP_CHAR}\t/g" | column -t -s $'\t'
elif [ $# -eq 1 ]; then
    # One arg: could be a file or separator
    if [ -f "$1" ]; then
        # It's a file
        sed -E "s/${SEP_REGEX}/${SEP_CHAR}\t/g" "$1" | column -t -s $'\t'
    else
        # It's a custom separator
        SEP_CHAR="$1"
        SEP_REGEX="${SEP_CHAR} +"
        sed -E "s/${SEP_REGEX}/${SEP_CHAR}\t/g" | column -t -s $'\t'
    fi
elif [ $# -eq 2 ]; then
    SEP_REGEX="$1"
    sed -E "s/${SEP_REGEX}/${SEP_CHAR}\t/g" "$2" | column -t -s $'\t'
else
    echo "Usage: $0 [separator_regex] [filename]" >&2
    exit 1
fi
