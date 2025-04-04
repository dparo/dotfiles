function fish_user_key_bindings
    fzf --fish | source

    bind --silent ctrl-f tmuxinator
    bind --silent \cf tmuxinator
end
