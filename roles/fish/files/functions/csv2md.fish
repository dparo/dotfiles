status is-interactive; or exit 0

function csv2md
    python3 -c '
    import pandas as pd
    import sys

    df = pd.read_csv(sys.stdin, sep="\t", dtype=str, keep_default_na=False)
    print(df.to_markdown(index=False))
    '
end
