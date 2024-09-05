status is-interactive; or exit 0

function ls --wraps=exa --description 'alias ls=exa'
  exa $argv
end
