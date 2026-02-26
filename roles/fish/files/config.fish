set fish_greeting ""


if status is-login
    # Is login shell only
end

if status is-interactive
    # Commands to run in interactive sessions can go here
    starship init fish | source

    # source "$HOME/opt/fzf/shell/key-bindings.fish"

    direnv hook fish | source

    abbr --add v nvim
    abbr --add gp "git pull"
    abbr --add gP "git push"
    abbr --add gc "git commit --verbose --interactive --patch"
    abbr --add gcm --set-cursor "git commit -m \"%\""
    abbr --add ga "git add -ip"

    abbr --add gg lazygit

    bind \cH backward-kill-word


    # if builtin type /usr/local/bin/aws 1>/dev/null 2>/dev/null; then
    #     complete -C '/usr/local/bin/aws_completer' aws
    # fi
    #
    # if builtin type /usr/bin/kubectl 1>/dev/null 2>/dev/null; then
    #     source <(/usr/bin/kubectl completion fish)
    # fi
    #
    #
    # if builtin type /usr/bin/flutter 1>/dev/null 2>/dev/null; then
    #     source <(/usr/bin/flutter fish-completion)
    # fi
    #
    # if builtin type /usr/bin/terraform 1> /dev/null 2> /dev/null; then
    #     complete -o nospace -C /usr/bin/terraform terraform
    # fi
    #
    #
    # if builtin type /usr/bin/atlas 1>/dev/null 2>/dev/null; then
    #     source <(/usr/bin/atlas completion fish)
    # fi


    # if builtin type docker 1>/dev/null 2>/dev/null
    #     docker completion fish | source
    # end

    # if builtin type /usr/bin/go-task 1>/dev/null 2>/dev/null
    #     /usr/bin/go-task --completion fish | source
    # end
    #

    if builtin type /usr/bin/mise 1> /dev/null 2> /dev/null
        /usr/bin/mise activate fish | source
    end
end
