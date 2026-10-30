status is-interactive; or exit 0

function yaml2json
    if builtin type /usr/bin/yq 1> /dev/null 2> /dev/null
        yq -P -ojson
    else
        python3 -c 'import sys, json, yaml; json.dump(yaml.safe_load(sys.stdin), sys.stdout, ensure_ascii=False, indent=2)'
        echo
    end
end

