#!/usr/bin/env bash
# -*- coding: utf-8 -*-

while true; do
    find ./ -type f -name 'Makefile' -o -name "*.adoc" -o -name "*.png" -o -name ".svg" -o -name "*.jpg" -o -name "*.jpeg" \
        ! -path "./.git/*" ! -path "node_modules/*" |
        entr -r -d asciidoctor -a allow-uri-read -r asciidoctor-pdf -b pdf "$1"
    sleep 0.5
done
