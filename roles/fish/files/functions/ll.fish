status is-interactive; or exit 0

if command -q eza then
    function ll --wraps=eza --description 'alias ls eza --icons -laFh'
      command eza --icons -laFh $argv
    end
else
    function ll --wraps=ls --description 'alias ll ls -laFh'
      command ls -laFh $argv
    end
end


