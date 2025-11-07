# Create temporary CSS file
TEMP_CSS=$(mktemp)
trap "rm -f $TEMP_CSS" EXIT

cat > "$TEMP_CSS" << 'EOF'
/*
 * A minimal CSS for Pandoc-generated HTML emails. (Version 2)
 * Designed for readability and email client compatibility.
 * Updated to support light and dark themes with responsive layout.
 */

body {
    font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif, "Apple Color Emoji", "Segoe UI Emoji", "Segoe UI Symbol";
    line-height: 1.6;
    color: #333;
    background-color: #fdfdfd;
    max-width: 95%;
    margin: 0 auto;
    padding: 15px;
}

/* Responsive max-width adjustments */
@media (min-width: 480px) {
    body {
        max-width: 90%;
        padding: 20px;
    }
}

@media (min-width: 768px) {
    body {
        max-width: 700px;
        padding: 25px;
    }
}

@media (min-width: 1024px) {
    body {
        max-width: 800px;
        padding: 30px;
    }
}

h1, h2, h3, h4, h5, h6 {
    margin-top: 1.5em;
    margin-bottom: 0.5em;
    font-weight: 600;
    color: #000;
}

h1 {
    font-size: 1.8em;
    border-bottom: 1px solid #ddd;
    padding-bottom: 0.4em;
}

h2 {
    font-size: 1.5em;
    border-bottom: 1px solid #eee;
    padding-bottom: 0.3em;
}

h3 {
    font-size: 1.25em;
}

p {
    margin-bottom: 1em;
}

a {
    color: #007bff;
    text-decoration: none;
}

a:hover {
    text-decoration: underline;
}

ul, ol {
    padding-left: 2em;
    margin-bottom: 1em;
}

li {
    margin-bottom: 0.4em;
}

blockquote {
    border-left: 4px solid #ddd;
    padding-left: 1em;
    color: #666;
    margin-left: 0;
    margin-right: 0;
}

code {
    font-family: "SFMono-Regular", Consolas, "Liberation Mono", Menlo, Courier, monospace;
    background-color: #f0f0f0;
    padding: 0.2em 0.4em;
    border-radius: 3px;
    font-size: 0.9em;
}

pre {
    background-color: #222222;
    padding: 1em;
    border-radius: 3px;
    overflow-x: auto;
}

pre code {
    background-color: transparent;
    padding: 0;
}

table {
    width: 100%;
    border-collapse: collapse;
    margin-bottom: 1em;
}

th, td {
    border: 1px solid #ccc;
    padding: 8px;
    text-align: left;
}

th {
    background-color: #e9ecef;
    font-weight: bold;
    color: #212529;
}

tr:nth-child(even) {
    background-color: #f9f9f9;
}

figure {
    margin: 1em 0;
}

img {
    max-width: 100%;
    height: auto;
    border-radius: 3px;
}

div.sourceCode {
    background-color: #222222;
    padding: 1em;
    border-radius: 3px;
    overflow-x: auto;
}

pre {
    background-color: transparent;
    padding: 0;
    margin: 0;
    border: none;
    overflow-x: visible;
}

pre code {
    background-color: transparent;
    padding: 0;
    font-size: 0.9em;
}

/* Dark theme styles */
@media (prefers-color-scheme: dark) {
    body {
        color: #e4e4e7;
        background-color: #18181b;
    }

    h1, h2, h3, h4, h5, h6 {
        color: #fafafa;
    }

    h1 {
        border-bottom: 1px solid #404040;
    }

    h2 {
        border-bottom: 1px solid #333;
    }

    a {
        color: #60a5fa;
    }

    blockquote {
        border-left: 4px solid #404040;
        color: #a1a1aa;
    }

    code {
        background-color: #222222;
        color: #e4e4e7;
    }

    pre {
        background-color: #222222;
    }

    div.sourceCode {
        background-color: #222222;
    }

    th, td {
        border: 1px solid #404040;
        color: #e4e4e7;
    }

    th {
        background-color: #222222;
        color: #fafafa;
    }

    tr:nth-child(even) {
        background-color: #222222;
    }
    /* Invert colors for math display images in dark mode */
    img.math {
        filter: invert(1);
    }
}
EOF

if [ -n "${1:-}" ]; then
    INPUT="$1"
else
    INPUT="-"
fi

    # --toc \
    # TODO Use pandoc filter to strip metadata instead of the sed expression
    # --lua-filter=strip-metadata.lua \

# STRIP Yaml front matter
sed '/^---$/,/^---$/d' "${INPUT}" | pandoc \
    -s \
    --embed-resources \
    --metadata-file=/dev/null \
    --metadata title=" " \
    --webtex='https://latex.codecogs.com/png.image?' \
    -V lang=it \
    --highlight-style=pygments \
     --css "$TEMP_CSS" \
    -f markdown+smart \
    --to=html5 \
    "${INPUT}" \
    | xclip -t text/html -selection clipboard -i
