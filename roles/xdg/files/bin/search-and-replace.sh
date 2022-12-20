#!/usr/bin/env bash
# -*- coding: utf-8 -*-


delim="/"
sed_search_term="${1//${delim}/\\${delim}}"
sed_replace_term="${2//${delim}/\\${delim}}"
rg -0 --files-with-matches "$1" | xargs -0 -I {} sed --regexp-extended -i "s${delim}${sed_search_term}${delim}${sed_replace_term}${delim}g" {}
