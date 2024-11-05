status is-interactive; or exit 0

function :q --wraps=exit --description 'alias :q exit'
  exit $argv
end
