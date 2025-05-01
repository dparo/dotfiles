#!/usr/bin/env bash
# -*- coding: utf-8 -*-

# Upgrade Ansible to latest with pipx
pipx upgrade --include-injected ansible

show_all_facts() {
    # Dumps all the ansible facts / variables available
    ansible localhost -m ansible.builtin.setup
}

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

cd "$(dirname "$0")/../" || exit 1

set -e

source ./roles/zsh/files/.zshenv
source ./roles/zsh/files/.zprofile

mkdir -p "${XDG_CONFIG_HOME:-$HOME/.config}/ansible"
echo "vault_pass.txt" >"${XDG_CONFIG_HOME:-$HOME/.config}/ansible/.gitignore"

echo "ANSIBLE_HOME: $ANSIBLE_HOME"
echo "ANSIBLE_GALAXY_CACHE_DIR: $ANSIBLE_GALAXY_CACHE_DIR"
echo "ANSIBLE_LOCAL_TEMP: $ANSIBLE_LOCAL_TEMP"

git_exclude

set +x

if ! test "${RUNNING_INSIDE_DOCKER:-0}" -ne 1; then
    ask_vault_pass
fi

if grep -qE 'hypervisor' /proc/cpuinfo; then
    export RUNNING_INSIDE_VM=1
fi

if [[ -f "$PWD/requirements.yml" ]]; then
    # ansible-galaxy install -r "$PWD/requirements.yml"
    true
fi

set -x

if test "${RUNNING_INSIDE_DOCKER:-0}" -eq 1; then
    ansible-playbook "$PWD/site.yml" "$@"
elif test -f "$PWD/vault_pass.txt"; then
    ansible-playbook "$PWD/site.yml" -e "@$PWD/secrets_file.enc" --vault-password-file "$PWD/vault_pass.txt" "$@"
else
    ansible-playbook "$PWD/site.yml" -e "@$PWD/secrets_file.enc" --ask-vault-pass "$@"
fi

rc=$?

if test "$USER" = "dparo"; then
    git config user.email "dparo@outlook.it"
    if test "$rc" -eq 0; then
        git remote set-url origin 'git@github.com:dparo/dotfiles.git'
        git remote add origin-https 'https://github.com:dparo/dotfiles' || true
    fi
fi

rm -rf "$HOME/.ansible"
rm -rf "$HOME/.bash_history"

if test -n "$ANSIBLE_LOCAL_TEMP" && test -d "$ANSIBLE_LOCAL_TEMP"; then
    rm -rf "$ANSIBLE_LOCAL_TEMP"
fi

if test -n "$ANSIBLE_HOME/tmp" && test -d "$ANSIBLE_HOME/tmp"; then
    rm -rf "$ANSIBLE_HOME/tmp"
fi

if command -v pre-commit 1> /dev/null 2> /dev/null; then
    pre-commit install
fi

