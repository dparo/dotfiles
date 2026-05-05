status is-interactive; or exit 0

function yaml2json
    python3 -c 'import sys, json, yaml; json.dump(yaml.safe_load(sys.stdin), sys.stdout, ensure_ascii=False, indent=2)'
    echo
end

