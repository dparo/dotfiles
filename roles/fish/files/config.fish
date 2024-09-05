set fish_greeting ""

if status is-interactive
    # Commands to run in interactive sessions can go here
    starship init fish | source

    # source "$HOME/opt/fzf/shell/key-bindings.fish"
    # fzf_key_bindings
    fzf --fish | source
end
