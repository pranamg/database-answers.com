#!/usr/bin/env bash
set -euo pipefail

# List all *_model.gif files across the repository and write CSV with
# columns: file_path,folder_path,category,filename

OUT_CSV="images/models_list.csv"
mkdir -p "$(dirname "$OUT_CSV")"

echo "file_path,folder_path,category,filename" > "$OUT_CSV"

# Find files and emit CSV rows
while IFS= read -r -d '' file; do
  folder="$(dirname "$file")"
  filename="$(basename "$file")"
  category=""
  if [[ "$file" =~ ^\.?/docs/data_models/([^/]+)/images/ ]]; then
    category="${BASH_REMATCH[1]}"
  fi

  # Escape double quotes in fields
  esc_file="${file//\"/\"\"}"
  esc_folder="${folder//\"/\"\"}"
  esc_category="${category//\"/\"\"}"
  esc_filename="${filename//\"/\"\"}"

  echo "\"$esc_file\",\"$esc_folder\",\"$esc_category\",\"$esc_filename\"" >> "$OUT_CSV"
done < <(find . -type f -name '*_model.gif' -print0)

echo "CSV written to: $OUT_CSV"