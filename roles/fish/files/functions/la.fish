status is-interactive; or exit 0

if command -q eza then
    function la --wraps=eza --description 'alias ls eza --icons -lah'
      command eza --icons -laH $argv
    end
else
    function la --wraps=ls --description 'alias la ls --color=auto -lah'
       command ls --color=auto -lah $argv
    end
end

