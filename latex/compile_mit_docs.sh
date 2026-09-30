#!/bin/bash
set -e

cd "$(dirname "$0")"

DOCS=("theory_and_math" "tutorials_and_guides" "contributors_and_wiki")

for doc in "${DOCS[@]}"; do
    echo "=== Compiling ${doc}.tex with pdflatex (Pass 1) ==="
    pdflatex -interaction=nonstopmode "${doc}.tex" > /dev/null
    echo "=== Compiling ${doc}.tex with pdflatex (Pass 2) ==="
    pdflatex -interaction=nonstopmode "${doc}.tex" > /dev/null

    echo "=== Generating high-DPI page images for ${doc} ==="
    # Clean previous page pngs
    rm -f "${doc}_page-"*.png

    # Render PNGs at 170 DPI (crisp and clean)
    pdftoppm -png -r 170 "${doc}.pdf" "${doc}_page"

    # Normalize filenames: pdftoppm produces foo_page-1.png, foo_page-01.png etc.
    # Check if files like foo_page-01.png exist and rename to foo_page-1.png if needed
    for f in "${doc}_page-"*.png; do
        base=$(basename "$f")
        # e.g. theory_and_math_page-01.png -> theory_and_math_page-1.png
        num=$(echo "$base" | sed -E "s/${doc}_page-0*([0-9]+)\.png/\1/")
        newname="${doc}_page-${num}.png"
        if [ "$base" != "$newname" ]; then
            mv "$f" "$newname"
        fi
    done
done

# Copy into app/latex/
echo "=== Syncing artifacts to app/latex/ ==="
mkdir -p ../app/latex
cp -v *.pdf ../app/latex/
cp -v *_page-*.png ../app/latex/

echo "=== All MIT-styled documentation compiled and synchronized successfully ==="
