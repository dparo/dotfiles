status is-interactive; or exit 0

function json2yaml
    python3 -c 'import sys, json, yaml; print(yaml.safe_dump(json.load(sys.stdin), sort_keys=False, allow_unicode=True))'
end
