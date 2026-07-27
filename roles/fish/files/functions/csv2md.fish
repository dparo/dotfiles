status is-interactive; or exit 0

function csv2md
    python3 -c '
    import pandas as pd
    import sys

    def escape_markdown_cell(x):
        if not isinstance(x, str):
            return x
        return (
            x
             .replace("\r\n", "\n")
             .replace("\r", "\n")
             .replace("\\", "\\\\")
             .replace("|", "\\|")
             .replace("\n", "\\n")      # or "<br>"
        )


    df = pd.read_csv(sys.stdin, sep="\t", dtype=str, keep_default_na=False)
    df = df.map(escape_markdown_cell)
    print(df.to_markdown(index=False))
    '
end
