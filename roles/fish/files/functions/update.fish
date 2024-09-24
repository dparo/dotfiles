status is-interactive; or exit 0

function update --wraps=dnf --description 'alias update=dnf'
    sudo dnf upgrade --refresh && flatpak update -y && flatpak uninstall --unused -y
end

