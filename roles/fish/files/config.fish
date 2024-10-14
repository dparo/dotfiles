set fish_greeting ""


if status is-login
    # Is login shell only
end

if status is-interactive
    # Commands to run in interactive sessions can go here
    starship init fish | source

    # source "$HOME/opt/fzf/shell/key-bindings.fish"
    # fzf_key_bindings
    fzf --fish | source

    direnv hook fish | source

    abbr --add v "nvim"
    abbr --add gp "git pull"
    abbr --add gP "git push"
    abbr --add gc "git commit --verbose --interactive --patch"
    abbr --add gcm --set-cursor "git commit -m \"%\""
    abbr --add ga "git add -ip"

    abbr --add gg "lazygit"

    bind \cH backward-kill-word

    # if builtin type docker 1>/dev/null 2>/dev/null
    #     docker completion fish | source
    # end

    if builtin type go-task 1>/dev/null 2>/dev/null
        go-task --completion fish | source
    end
end
