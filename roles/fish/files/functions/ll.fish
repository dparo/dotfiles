status is-interactive; or exit 0

function ll --wraps=eza --description 'alias ll=eza'
  eza --icons -laFh $argv
end


