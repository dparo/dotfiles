# Create temporary CSS file
TEMP_CSS="$(mktemp).css"
TEMP_HTML_TEMPLATE="$(mktemp).html"
trap "rm -f $TEMP_CSS" EXIT
trap "rm -f $TEMP_HTML_TEMPLATE" EXIT

cat > "$TEMP_CSS" << 'EOF'
/*
 * A minimal CSS for Pandoc-generated HTML emails. (Version 2)
 * Designed for readability and email client compatibility.
 * Updated to support light and dark themes with responsive layout.
 */

@page {
    margin: 2cm;
    size: A4;
}

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

@media print {
    body {
        max-width: 100%;
        padding: 0;
        margin: 0;
        background-color: white;
        color: black;
    }

    a {
        color: #0066cc;
        text-decoration: underline;
    }

    a[href^="http"]:after {
        content: " (" attr(href) ")";
        font-size: 0.8em;
        font-style: italic;
    }
}

h1, h2, h3, h4, h5, h6 {
    margin-top: 1.5em;
    margin-bottom: 0.5em;
    font-weight: 600;
    color: #000;
    page-break-after: avoid;
    break-after: avoid-page;
}

h1 {
    font-size: 1.8em;
    border-bottom: 1px solid #ddd;
    padding-bottom: 0.4em;
    page-break-before: auto;
    break-before: auto;
}

h2 {
    font-size: 1.5em;
    border-bottom: 1px solid #eee;
    padding-bottom: 0.3em;
    page-break-before: auto;
    break-before: auto;
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
    page-break-inside: avoid;
    break-inside: avoid;
}

pre code {
    background-color: transparent;
    padding: 0;
}

table {
    width: 100%;
    border-collapse: collapse;
    margin-bottom: 1em;
    page-break-inside: avoid;
    break-inside: avoid;
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

tbody tr:hover {
    background-color: #e8f4f8;
}

figure {
    margin: 1em 0;
    page-break-inside: avoid;
    break-inside: avoid;
}

img {
    max-width: 100%;
    height: auto;
    border-radius: 3px;
    page-break-inside: avoid;
    break-inside: avoid;
}

div.sourceCode {
    background-color: #222222;
    padding: 1em;
    border-radius: 3px;
    overflow-x: auto;
    page-break-inside: avoid;
    break-inside: avoid;
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

    tbody tr:hover {
        background-color: #2a2a2a;
    }

    /* Invert colors for math display images in dark mode */
    img.math {
        filter: invert(1);
    }
}

@media print {
    h1, h2, h3, h4, h5, h6 {
        page-break-after: avoid;
        break-after: avoid-page;
    }

    h1 {
        page-break-before: auto;
        break-before: auto;
    }

    h2, h3 {
        page-break-before: avoid;
        break-before: avoid-page;
    }

    p, blockquote, ul, ol {
        orphans: 3;
        widows: 3;
    }

    blockquote {
        page-break-inside: avoid;
        break-inside: avoid;
    }

    ul, ol {
        page-break-before: avoid;
        break-before: avoid-page;
    }

    pre, code, div.sourceCode {
        page-break-inside: avoid;
        break-inside: avoid;
        background-color: #f5f5f5 !important;
        border: 1px solid #ddd;
        color: black !important;
    }

    pre code {
        color: black !important;
    }

    table, figure, img {
        page-break-inside: avoid;
        break-inside: avoid;
    }

    tr {
        page-break-inside: avoid;
        break-inside: avoid;
    }
}
EOF

# Output the default template with: `pandoc -D html5`
cat > "$TEMP_HTML_TEMPLATE" << 'EOF'
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" lang="$lang$" xml:lang="$lang$"$if(dir)$ dir="$dir$"$endif$>
<head>
  <meta charset="utf-8" />
  <meta name="generator" content="pandoc" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=yes" />
$for(author-meta)$
  <meta name="author" content="$author-meta$" />
$endfor$
$if(date-meta)$
  <meta name="dcterms.date" content="$date-meta$" />
$endif$
$if(keywords)$
  <meta name="keywords" content="$for(keywords)$$keywords$$sep$, $endfor$" />
$endif$
$if(description-meta)$
  <meta name="description" content="$description-meta$" />
$endif$
  <title>$if(title-prefix)$$title-prefix$ – $endif$$pagetitle$</title>
  <style>
    $styles.html()$
  </style>
$for(css)$
  <link rel="stylesheet" href="$css$" />
$endfor$
$for(header-includes)$
  $header-includes$
$endfor$
$if(math)$
$if(mathjax)$
  <script src="https://polyfill.io/v3/polyfill.min.js?features=es6"></script>
$endif$
  $math$
$endif$
</head>
<body>
$for(include-before)$
$include-before$
$endfor$
$if(title)$
<header id="title-block-header">
<h1 class="title">$title$</h1>
$if(subtitle)$
<p class="subtitle">$subtitle$</p>
$endif$
$for(author)$
<p class="author">$author$</p>
$endfor$
$if(date)$
<p class="date">$date$</p>
$endif$
$if(abstract)$
<div class="abstract">
<div class="abstract-title">$abstract-title$</div>
$abstract$
</div>
$endif$
</header>
$endif$
$if(toc)$
<nav id="$idprefix$TOC" role="doc-toc">
$if(toc-title)$
<h2 id="$idprefix$toc-title">$toc-title$</h2>
$endif$
$table-of-contents$
</nav>
$endif$
$body$
$for(include-after)$
$include-after$
$endfor$
</body>
</html>
EOF


# Parse arguments
CLIPBOARD=false
INPUT="-"

while [ $# -gt 0 ]; do
    case "$1" in
        --clipboard)
            CLIPBOARD=true
            shift
            ;;
        *)
            INPUT="$1"
            shift
            ;;
    esac
done

    # --toc \
    # TODO Use pandoc filter to strip metadata instead of the sed expression
    # --lua-filter=strip-metadata.lua \

# STRIP Yaml front matter and convert to HTML
HTML_OUTPUT=$(sed '/^---$/,/^---$/d' "${INPUT}" | pandoc \
    -s \
    --embed-resources \
    --toc=false \
    --toc-depth=3 \
    --number-sections \
    --metadata toc-title="Indice" \
    --metadata title=" " \
    --metadata abstract-title="Sommario" \
    --metadata date-meta="$(date --iso-8601=minutes)" \
    --metadata author-meta="$(git config get user.name) <$(git config get user.email)>" \
    --metadata date="$(date --iso-8601=minutes)" \
    --metadata author="$(git config get user.name) <$(git config get user.email)>" \
    --webtex='https://latex.codecogs.com/png.image?' \
    --variable lang=it \
    --variable mainfont="Liberation Serif" \
    --variable monofont="Liberation Mono" \
    --variable colorlinks=true \
    --variable papersize=a4 \
    --highlight-style=zenburn \
    --template "$TEMP_HTML_TEMPLATE" \
    --css "$TEMP_CSS" \
    -f markdown+smart \
    --to=html5 \
    "${INPUT}")

# Output to clipboard or stdout based on --clipboard flag
if [ "$CLIPBOARD" = true ]; then
    echo "$HTML_OUTPUT" | xclip -t text/html -selection clipboard -i
else
    echo "$HTML_OUTPUT"
fi

