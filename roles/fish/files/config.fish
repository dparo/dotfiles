set fish_greeting ""

if status is-interactive
    # Commands to run in interactive sessions can go here
    starship init fish | source

    # source "$HOME/opt/fzf/shell/key-bindings.fish"
    # fzf_key_bindings
    fzf --fish | source

    abbr --add v "nvim"
    abbr --add gp "git pull"
    abbr --add gP "git push"
    abbr --add gc "git commit"
    abbr --add gg "lazygit"
end
