
status is-interactive; or exit 0

function run --wraps=nohup --description 'alias run=nohup'
  nohup $argv 1> /dev/null 2> /dev/null &
end
