#!/usr/bin/env bash

metadata="$1"
pdf_url="$2"

cd "$HOME/Documents/papers" || exit 1
tmpfile=$(mktemp ./paper.XXXXXX.pdf)
wget "$pdf_url" -O "$tmpfile"
papis add --no-edit --no-confirm "$tmpfile" --from doi "$metadata" --set metadata_url "$metadata"
rm "$tmpfile"
