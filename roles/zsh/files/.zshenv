export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"
export XDG_MUSIC_DIR="$HOME/Music"

# To let the Application launcher (such as ROFI)
# find distribution specific application files (including snap/flatpak installed applications)
# it is important to populate the XDG_DATA_DIRS, which is analogue to
# the XDG_DATA_HOME but for system wide stuff
export XDG_DATA_DIRS="$XDG_DATA_HOME/flatpak/exports/share:/var/lib/flatpak/exports/share:/usr/share/ubuntu:/usr/share/gnome:/usr/local/share/:/usr/share/:/var/lib/snapd/desktop"


export USER_DOTFILES_LOCATION="${XDG_DATA_HOME}/dotfiles"
export EDITOR=nvim
export VISUAL=nvim
export MANROFFOPT="-c"
export MANPAGER="sh -c 'col -bx | bat -l man -p --paging always'"


# https://git-scm.com/docs/merge-options?ref=blog.mergify.com#Documentation/merge-options.txt---no-edit
export GIT_MERGE_AUTOEDIT=no

export GPG_TTY="$(tty)"


# Run flutter and dart through brave-browser
#
if builtin type brave-browser 1>/dev/null 2>/dev/null; then
    export CHROME_EXECUTABLE="$(which brave-browser)"
fi


# @NOTE: Path prepends WIN over standard /usr/bin and /usr/local/bin paths
# @NOTE: Path adds have LOWER precedence compared to standard /usr/bin and /usr/local/bin paths

pathadd() {
    # Forward iteration of function's args
    local p
    for p in "$@"; do
        PATH="${PATH:+"$PATH:"}$p"
    done
    export PATH
}

pathprepend() {
    # Iterate args to function in reversed, C-style indexing
    local i
    local p
    for ((i = $#; i > 0; i--)); do
        # Expands to p=$i where is the current parameter index
        eval local p="\${$i}"
        PATH="$p${PATH:+":$PATH"}"
    done
    export PATH
}


# pathprepend: Inserts higher precedence paths
pathprepend \
    "$XDG_DATA_HOME/bin" \
    "$HOME/.local/bin" \
    "${PYTHONUSERBASE:-$XDG_DATA_HOME/python}/bin" \
    "/opt/pulumi/" \
    "${GOPATH:-$XDG_DATA_HOME/go}/bin" \
    "${XDG_DATA_HOME:-$HOME/.local/share}/coursier/bin" \
    "${CARGO_HOME:-$XDG_DATA_HOME/cargo}/bin" \
    "${PNPM_HOME:-$XDG_DATA_HOME/pnpm}" \
    "${NPM_DIR:-$XDG_DATA_HOME/npm}/bin" \
    "${DENO_DIR:-$XDG_DATA_HOME/deno}/bin" \
    "${BUN_INSTALL:-$XDG_DATA_HOME/bun}/bin" \
    "${COMPOSER_HOME:-$XDG_DATA_HOME/composer}/vendor/bin" \
    "$HOME/opt/groovy-4.0.12/bin" \
    "$XDG_DATA_HOME/zig" \
    "${NIMBLE_DIR:-$XDG_DATA_HOME/nimble}/bin" \
    "/usr/local/bin"


if [ -f "$ZDOTDIR/.localenv" ]; then
    source "$ZDOTDIR/.localenv"
fi
