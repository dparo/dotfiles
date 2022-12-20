#!/usr/bin/env bash


# Use LuaLatex since it seems a more modern alternative
# with better font support and UTF-8 support

# pdflatex: oldy backend
# xelatex: new backend, but some packages do not work since it uses a different infrastructure to emit the PDF
# lualatex: Since the accepted new pdf latex engine that will be further developed in the future

# NOTE: -pvc runs the file previwer (a PDF reader for example)

FILE="$1"
DIR=$(dirname "$FILE")


clean() {
    rm *.aux *.lof *.log *.lot *.fls *.out *.toc *.fmt *.fot *.cb *.cb2 .*.lb *.pdf \
        *.bbl *.bcf *.blg *-blx.aux *-blx.bib *.run.xml \
        *.fdb_latexmk *.synctex *.synctex* *.synctex.gz *.synctex.gz* *.pdfsync \
        latex.out/ \
        *.alg *.loa \
        acs-*.bib 1> /dev/null 2> /dev/null
}

# NOTE:
# - pdflatex = pdftex  SAME THING
# - xelatex = xetex    SAME THING
# - lualatex = luatex  SAME THING

# NOTE:
#  -pdf: Generates pdf using standard pdflatex
#  -pdftex: Generates pdf using xelatex
#  -pdflua: Generates pdf using lualatex
cd "$DIR" || exit

if test "$1" == "clean"; then
    clean
else

    latexmk -pdf -interaction=nonstopmode -recorder -file-line-error \
            -aux-directory="$DIR" \
            -output-directory="$DIR" \
            "$FILE" \
        | grep -E "^((l\\..*)|(.*:.*))$"
    exit $?
fi
