#!/usr/bin/env bash
# Update Fedora's OS packages, Flatpaks, firmware, and (if installed) Snaps.
# Run as your normal desktop user, not with sudo.

set -uo pipefail

declare -a FAILURES=()

if [[ ${EUID} -eq 0 ]]; then
    printf 'Run this script as your normal user (without sudo).\n' >&2
    printf 'It invokes sudo only for system-wide operations so user Flatpaks update correctly.\n' >&2
    exit 2
fi

if [[ -r /etc/os-release ]]; then
    # shellcheck disable=SC1091
    source /etc/os-release
    if [[ ${ID:-} != "fedora" && ${ID_LIKE:-} != *"fedora"* ]]; then
        printf 'Warning: this script targets Fedora; detected %s.\n\n' "${PRETTY_NAME:-an unknown OS}" >&2
    fi
fi

section() {
    printf '\n==> %s\n' "$1"
}

run_step() {
    local label=$1
    shift

    section "$label"
    if "$@"; then
        printf 'Done: %s\n' "$label"
    else
        local status=$?
        printf 'FAILED (%d): %s\n' "$status" "$label" >&2
        FAILURES+=("$label")
    fi
}

have() {
    command -v "$1" >/dev/null 2>&1
}

if ! have sudo; then
    printf 'Error: sudo is required for system-wide updates.\n' >&2
    exit 2
fi

section "Authenticate for system-wide updates"
if ! sudo -v; then
    printf 'Error: sudo authentication failed.\n' >&2
    exit 1
fi

# Keep sudo's timestamp alive while long downloads run. The background process
# exits when this script exits and never extends authorization beyond its life.
while true; do
    sudo -n true 2>/dev/null || exit
    sleep 50
done &
SUDO_KEEPALIVE_PID=$!
cleanup() {
    kill "$SUDO_KEEPALIVE_PID" 2>/dev/null || true
}
trap cleanup EXIT
trap 'exit 130' INT
trap 'exit 143' TERM

# Fedora Workstation uses DNF. Atomic Fedora variants instead use rpm-ostree.
if [[ -e /run/ostree-booted ]] && have rpm-ostree; then
    run_step "Fedora base system (rpm-ostree)" sudo rpm-ostree upgrade
elif have dnf5; then
    run_step "Fedora RPM packages (DNF5)" sudo dnf5 --refresh upgrade --assumeyes
elif have dnf; then
    run_step "Fedora RPM packages (DNF)" sudo dnf --refresh upgrade --assumeyes
else
    printf '\nSkipped: neither dnf, dnf5, nor rpm-ostree was found.\n' >&2
    FAILURES+=("Fedora RPM/base-system updates (tool not found)")
fi

if have flatpak; then
    # These are separate installations; using sudo for both would accidentally
    # update root's per-user Flatpaks instead of the desktop user's Flatpaks.
    run_step "System-wide Flatpaks" \
        sudo flatpak update --system --assumeyes --noninteractive
    run_step "Per-user Flatpaks" \
        flatpak update --user --assumeyes --noninteractive
else
    printf '\nSkipped: Flatpak is not installed.\n'
fi

if have fwupdmgr; then
    run_step "Firmware metadata (fwupd/LVFS)" sudo fwupdmgr refresh --force
    # fwupdmgr may stage some updates for the next reboot. -y accepts normal
    # confirmation prompts but does not enable unsupported or unsafe releases.
    run_step "Device firmware (fwupd/LVFS)" sudo fwupdmgr update -y
else
    printf '\nSkipped: fwupdmgr is not installed.\n'
fi

# Not part of a default Fedora install, but GNOME Software can expose Snaps when
# its Snap support is installed, so refresh them when the command exists.
if have snap; then
    run_step "Snap packages" sudo snap refresh
fi

section "Update summary"
if ((${#FAILURES[@]})); then
    printf 'Completed with %d failed component(s):\n' "${#FAILURES[@]}" >&2
    printf '  - %s\n' "${FAILURES[@]}" >&2
    printf 'Review the messages above; successful components are already updated.\n' >&2
    exit 1
fi

printf 'All detected update sources completed successfully.\n'
if [[ -e /run/ostree-booted ]]; then
    printf 'Reboot to start the newly deployed Fedora base system.\n'
elif have rpm && have uname; then
    running_kernel=$(uname -r)
    newest_kernel=$(rpm -q --qf '%{VERSION}-%{RELEASE}.%{ARCH}\n' kernel-core 2>/dev/null \
        | sort -V | tail -n 1)
    if [[ -n $newest_kernel && $newest_kernel != "$running_kernel" ]]; then
        printf 'A newer kernel is installed (%s); reboot when convenient.\n' "$newest_kernel"
    fi
fi



# Check reboot state without refreshing or downloading DNF metadata. These
# commands use nonzero statuses as normal results, so do not use run_step.
section "Restart checks"
if [[ -e /run/ostree-booted ]]; then
    REBOOT_REASONS+=("a new rpm-ostree deployment may be pending")
elif have dnf5; then
    sudo dnf5 --cacheonly --quiet needs-restarting >/dev/null 2>&1
    restart_status=$?
    case $restart_status in
        0) printf 'DNF5: no reboot required.\n' ;;
        1) REBOOT_REASONS+=("DNF5 reports updated system components") ;;
        *) printf 'DNF5 restart check unavailable (status %d).\n' "$restart_status" >&2 ;;
    esac
elif have dnf; then
    sudo dnf --cacheonly --quiet needs-restarting --reboothint >/dev/null 2>&1
    restart_status=$?
    case $restart_status in
        0) printf 'DNF: no reboot required.\n' ;;
        1) REBOOT_REASONS+=("DNF reports updated system components") ;;
        *) printf 'DNF restart check unavailable (status %d).\n' "$restart_status" >&2 ;;
    esac
fi

if have fwupdmgr; then
    # JSON mode prevents the interactive "Restart now?" prompt. fwupdmgr uses
    # status 0 when a reboot action is pending and 2 for "nothing to do".
    sudo fwupdmgr check-reboot-needed --json >/dev/null 2>&1
    restart_status=$?
    case $restart_status in
        0) REBOOT_REASONS+=("fwupd reports a pending firmware reboot") ;;
        2) printf 'fwupd: no reboot required.\n' ;;
        *) printf 'fwupd restart check unavailable (status %d).\n' "$restart_status" >&2 ;;
    esac
fi

section "Update summary"
if ((${#REBOOT_REASONS[@]})); then
    printf 'Restart recommended:\n'
    printf '  - %s\n' "${REBOOT_REASONS[@]}"
else
    printf 'No restart is currently indicated by the available checks.\n'
fi

if ((${#FAILURES[@]})); then
    printf 'Completed with %d failed component(s):\n' "${#FAILURES[@]}" >&2
    printf '  - %s\n' "${FAILURES[@]}" >&2
    printf 'Review the messages above; successful components are already updated.\n' >&2
    exit 1
fi

printf 'All detected update sources completed successfully.\n'
