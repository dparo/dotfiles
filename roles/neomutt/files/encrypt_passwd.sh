#!/usr/bin/env bash
# -*- coding: utf-8 -*-

cd "$(dirname "$0")" || exit

IFS= read -r -s -p "Password: " pwd
echo ""

echo "set my_pass='$pwd'" | gpg --default-recipient-self --encrypt -o passwd.gpg
