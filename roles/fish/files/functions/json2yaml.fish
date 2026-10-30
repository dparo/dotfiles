status is-interactive; or exit 0

function json2yaml
    if builtin type /usr/bin/yq 1> /dev/null 2> /dev/null
        yq -P -oyaml
    else
        python3 -c 'import sys, json, yaml; print(yaml.safe_dump(json.load(sys.stdin), sort_keys=False, allow_unicode=True))'
    end
end
