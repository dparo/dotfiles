status is-interactive; or exit 0

function ls --wraps=eza --description 'alias ls=eza'
  eza --icons $argv
end
