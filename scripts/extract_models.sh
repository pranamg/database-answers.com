#!/usr/bin/env bash
set -euo pipefail

# Extract all *_model.gif files from docs/data_models/{category}/images
# Copy them into the repository-level `images/` dir and prefix each filename
# with the {category} they were found under.

DEST_DIR="images"
mkdir -p "$DEST_DIR"

# Find target files and copy
while IFS= read -r -d '' file; do
  # file like: docs/data_models/<category>/images/<name>_model.gif
  rel="${file#docs/data_models/}"
  category="${rel%%/*}"
  base="$(basename "$file")"
  target="${DEST_DIR}/${category}_${base}"

  if [[ -e "$target" ]]; then
    # avoid collision by adding a numeric suffix
    i=1
    while [[ -e "${DEST_DIR}/${category}_${i}_${base}" ]]; do
      ((i++))
    done
    target="${DEST_DIR}/${category}_${i}_${base}"
  fi

  cp -p "$file" "$target"
  echo "Copied: $file -> $target"

done < <(find docs/data_models -type f -path 'docs/data_models/*/images/*_model.gif' -print0)

echo "Done. Extracted files are in: $DEST_DIR"