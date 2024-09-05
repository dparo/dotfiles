status is-interactive; or exit 0

function vim --wraps=nvim --description 'alias vim=nvim'
  nvim $argv
end
