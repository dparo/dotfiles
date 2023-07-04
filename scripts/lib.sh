#!/usr/bin/env bash
# -*- coding: utf-8 -*-

git_exclude() {
    for f in "$PWD/vault_pass.txt" "$PWD/roles/zsh/files/.localenv" "$PWD/roles/zsh/files/.localprofile" "$PWD/keepassxc_pass.txt" "$PWD/keepass_pass.txt"; do
        local base_f
        base_f="$(basename "$f")"
        git config core.excludesFile "$f"
        grep -qxE "$base_f" "$PWD/.git/info/exclude" || echo "$base_f" >>"$PWD/.git/info/exclude"
    done
}

ask_vault_pass() {
    set +x
    if ! test -f "$PWD/vault_pass.txt"; then
        read -r -s -p "ANSIBLE VAULT PASS: " vault_password
        echo "$vault_password" >"$PWD/vault_pass.txt"
    fi
}
