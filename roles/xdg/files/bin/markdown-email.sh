# To produce a PDF from the HTML contents, use a QT headless Web Engine to produce an output

# `wkhtmltopdf --page-size A4 --margin-top 40mm --margin-bottom 40mm --margin-left 20mm --margin-right 20mm --minimum-font-size 20 input.html output.pdf`

# Equivalently, using Chrome in headless mode:

# `chromium-browser --headless --disable-gpu --run-all-compositor-stages-before-draw --no-pdf-header-footer --print-to-pdf-no-header input.html --print-to-pdf=output.pdf`


# Create temporary files
TEMP_CSS="$(mktemp --suffix=.css)"
TEMP_HTML_TEMPLATE="$(mktemp --suffix=.html)"
TEMP_ASCIIDOC_HTML=""
TEMP_RENDER_HTML=""
TEMP_PDF=""

cleanup() {
    rm -f "$TEMP_CSS" "$TEMP_HTML_TEMPLATE" "$TEMP_ASCIIDOC_HTML" "$TEMP_RENDER_HTML" "$TEMP_PDF"
}
trap cleanup EXIT

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
<!-- <p class="author">$author$</p> -->
$endfor$
$if(date)$
<!-- <p class="date">$date$</p> -->
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
TOC=false
NUMBER_SECTIONS=false
ASCIIDOC=false
MODERN=false
PDF_OUTPUT=""
INPUT="-"

while [ $# -gt 0 ]; do
    case "$1" in
        --clipboard)
            CLIPBOARD=true
            shift
            ;;
        --toc)
            TOC=true
            shift
            ;;
        --number-sections)
            NUMBER_SECTIONS=true
            shift
            ;;
        --asciidoc)
            ASCIIDOC=true
            shift
            ;;
        --modern)
            MODERN=true
            shift
            ;;
        --pdf)
            if [ $# -lt 2 ] || [ -z "$2" ]; then
                echo "Error: --pdf requires an output file path" >&2
                exit 1
            fi
            PDF_OUTPUT="$2"
            shift 2
            ;;
        *)
            INPUT="$1"
            shift
            ;;
    esac
done

if [ "$MODERN" = true ]; then
    cat > "$TEMP_CSS" << 'EOF'
html {
    background: #f8fafc;
}

body {
    box-sizing: border-box;
    max-width: 46rem;
    margin: 3rem auto;
    padding: 3rem clamp(1.5rem, 5vw, 4rem);
    background: #ffffff;
    color: #1f2937;
    font-family: Inter, ui-sans-serif, system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
    font-size: 1.0625rem;
    line-height: 1.75;
    box-shadow: 0 1rem 3rem rgb(15 23 42 / 0.08);
}

*, *::before, *::after {
    box-sizing: inherit;
}

h1, h2, h3, h4, h5, h6 {
    color: #0f172a;
    font-weight: 700;
    line-height: 1.2;
    letter-spacing: -0.025em;
    margin: 2.5em 0 0.75em;
}

h1, .title {
    font-size: clamp(2.25rem, 6vw, 3.5rem);
    margin-top: 0;
}

h2 { font-size: 1.75rem; }
h3 { font-size: 1.375rem; }

p, ul, ol, blockquote, pre, div.sourceCode, table, figure {
    margin: 0 0 1.5rem;
}

a {
    color: #2563eb;
    text-decoration: underline;
    text-decoration-color: #93c5fd;
    text-underline-offset: 0.15em;
}

a:hover {
    color: #1d4ed8;
    text-decoration-color: currentColor;
}

ul, ol {
    padding-left: 1.5em;
}

li + li {
    margin-top: 0.5em;
}

blockquote {
    color: #475569;
    border-left: 0.25rem solid #60a5fa;
    margin-left: 0;
    padding-left: 1.25rem;
    font-size: 1.125em;
}

code {
    color: #be123c;
    background: #fff1f2;
    border-radius: 0.25rem;
    padding: 0.15em 0.35em;
    font-family: ui-monospace, SFMono-Regular, Menlo, Consolas, monospace;
    font-size: 0.875em;
}

pre, div.sourceCode {
    overflow-x: auto;
    color: #e2e8f0;
    background: #0f172a;
    border-radius: 0.75rem;
    padding: 1.25rem;
}

pre code, div.sourceCode code {
    color: inherit;
    background: transparent;
    padding: 0;
}

table {
    display: block;
    width: 100%;
    overflow-x: auto;
    border-collapse: collapse;
}

th, td {
    border-bottom: 1px solid #e2e8f0;
    padding: 0.75rem 1rem;
    text-align: left;
}

th {
    color: #0f172a;
    background: #f8fafc;
    font-weight: 600;
}

figure { margin-left: 0; margin-right: 0; }

img {
    display: block;
    max-width: 100%;
    height: auto;
    border-radius: 0.5rem;
}

@media (max-width: 640px) {
    html { background: #ffffff; }

    body {
        margin: 0;
        padding: 1.5rem;
        box-shadow: none;
    }
}
EOF
else
    cat > "$TEMP_CSS" << 'EOF'
@page {
    size: A4;
    margin: 0;
}

body {
    font-family: Arial, sans-serif;
    font-size: 16px;
    line-height: 1.5;
    color: #333333;
    background-color: #ffffff;
    margin: 0;
    padding: 16px;
}

h1, h2, h3, h4, h5, h6 {
    color: #000000;
    margin: 1.25em 0 0.5em;
}

h1 { font-size: 1.75em; }
h2 { font-size: 1.5em; }
h3 { font-size: 1.25em; }

p { margin: 0 0 1em; }

a {
    color: #0000ff;
    text-decoration: underline;
}

ul, ol {
    margin: 0 0 1em;
    padding-left: 2em;
}

li { margin-bottom: 0.25em; }

blockquote {
    color: #555555;
    border-left: 3px solid #cccccc;
    margin: 0 0 1em;
    padding-left: 1em;
}

code {
    font-family: "Courier New", monospace;
    font-size: 0.9em;
    color: #333333;
    background-color: #f2f2f2;
    padding: 0.15em 0.3em;
}

pre, div.sourceCode {
    font-family: "Courier New", monospace;
    color: #333333;
    background-color: #f2f2f2;
    border: 1px solid #cccccc;
    margin: 0 0 1em;
    padding: 0.75em;
}

pre code {
    background-color: transparent;
    padding: 0;
}

table {
    border-collapse: collapse;
    margin: 0 0 1em;
}

th, td {
    border: 1px solid #cccccc;
    padding: 0.5em;
    text-align: left;
}

th {
    color: #000000;
    background-color: #eeeeee;
}

figure { margin: 0 0 1em; }

img {
    max-width: 100%;
    height: auto;
}
EOF
fi

    # --toc \
    # TODO Use pandoc filter to strip metadata instead of the sed expression
    # --lua-filter=strip-metadata.lua \

# Process based on input format
if [ "$ASCIIDOC" = true ]; then
    # Use asciidoctor for AsciiDoc files
    if ! command -v asciidoctor >/dev/null 2>&1; then
        echo "Error: asciidoctor is not installed. Please install it to process AsciiDoc files." >&2
        exit 1
    fi

    # Build asciidoctor command with options
    ASCIIDOCTOR_OPTS="-a embedcss -a linkcss!"

    # Add TOC if requested
    if [ "$TOC" = true ]; then
        ASCIIDOCTOR_OPTS="$ASCIIDOCTOR_OPTS -a toc -a toc-title='Indice'"
    fi

    # Convert AsciiDoc to HTML using asciidoctor
    TEMP_ASCIIDOC_HTML="$(mktemp --suffix=.html)"

    asciidoctor $ASCIIDOCTOR_OPTS -o "$TEMP_ASCIIDOC_HTML" "${INPUT}"

    # Extract the body content and wrap it with our custom template
    BODY_CONTENT=$(sed -n '/<body/,/<\/body>/p' "$TEMP_ASCIIDOC_HTML" | sed '1d;$d')

    # Apply custom CSS styling
    HTML_OUTPUT=$(cat <<EOHTML
<!DOCTYPE html>
<html lang="it">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=yes" />
  <meta name="author" content="$(git config get user.name) <$(git config get user.email)>" />
  <meta name="dcterms.date" content="$(date --iso-8601=minutes)" />
  <title> </title>
  <style>
$(cat "$TEMP_CSS")
  </style>
</head>
<body>
$BODY_CONTENT
</body>
</html>
EOHTML
)
else
    # Use pandoc for Markdown files
    INPUT_FORMAT="markdown+smart"

    # Check if mermaid-filter is available
    MERMAID_FILTER=""
    if command -v mermaid-filter >/dev/null 2>&1; then
        MERMAID_FILTER="-F mermaid-filter"
    fi

    export MERMAID_FILTER_FORMAT=svg

    # STRIP Yaml front matter and convert to HTML
    HTML_OUTPUT=$(sed '/^---$/,/^---$/d' "${INPUT}" | pandoc \
        -s \
        ${MERMAID_FILTER} \
        --embed-resources \
        --toc="${TOC}" \
        --toc-depth=3 \
        --number-sections=${NUMBER_SECTIONS:false} \
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
        -f "${INPUT_FORMAT}" \
        --to=html5 \
        "${INPUT}")
fi

# Output as PDF, to clipboard, or stdout
if [ -n "$PDF_OUTPUT" ]; then
    if ! command -v google-chrome >/dev/null 2>&1; then
        echo "Error: google-chrome is required to generate PDF output" >&2
        exit 1
    fi

    TEMP_RENDER_HTML="$(mktemp --suffix=.html)"
    TEMP_PDF="$(mktemp --suffix=.pdf)"
    printf '%s\n' "$HTML_OUTPUT" > "$TEMP_RENDER_HTML"

    if ! google-chrome --headless --disable-gpu --no-pdf-header-footer \
        --print-to-pdf="$TEMP_PDF" "file://$TEMP_RENDER_HTML"; then
        echo "Error: Google Chrome could not generate the PDF" >&2
        exit 1
    fi

    if [ "$CLIPBOARD" = true ]; then
        if ! command -v wl-copy >/dev/null 2>&1; then
            echo "Error: wl-copy is required to copy PDF output to the clipboard" >&2
            exit 1
        fi
        if ! wl-copy --type application/pdf < "$TEMP_PDF"; then
            echo "Error: Could not copy PDF output to the clipboard" >&2
            exit 1
        fi
    else
        mv "$TEMP_PDF" "$PDF_OUTPUT"
        TEMP_PDF=""
    fi
elif [ "$CLIPBOARD" = true ]; then
    if [ -n "$WAYLAND_DISPLAY" ] && command -v wl-copy >/dev/null 2>&1; then
        # Wayland / sway
        echo "$HTML_OUTPUT" | wl-copy --type text/html
    elif [ -n "$DISPLAY" ] && command -v xclip >/dev/null 2>&1; then
        # X11 fallback
        echo "$HTML_OUTPUT" | xclip -t text/html -selection clipboard -i
    else
        echo "Error: No clipboard utility found (need wl-copy or xclip)" >&2
        exit 1
    fi
else
    echo "$HTML_OUTPUT"
fi





