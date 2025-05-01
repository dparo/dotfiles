status is-interactive; or exit 0

if command -q eza then
    function ls --wraps=eza --description 'alias ls eza --icons -h'
      command eza --icons -H $argv
    end
else
    function ls --wraps=ls --description 'alias ls ls --color=auto -h'
      command ls --color=auto -h $argv
    end
end
