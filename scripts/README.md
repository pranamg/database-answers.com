# Scripts: extract_models.sh & list_models_csv.sh

This folder contains two helper scripts to work with `*_model.gif` images used in the docs:

1) extract_models.sh
- Purpose: Find files under `docs/data_models/{category}/images/*_model.gif` and copy them into the repository-level `images/` directory.
- Result: Each copied file is prefixed with the category name (e.g. `images/<category>_<filename>.gif`).
- Usage:
  - chmod +x scripts/extract_models.sh
  - ./scripts/extract_models.sh

2) list_models_csv.sh
- Purpose: Find all `*_model.gif` files across the repository and write a CSV at `images/models_list.csv` with columns: `file_path,folder_path,category,filename`.
- Usage:
  - chmod +x scripts/list_models_csv.sh
  - ./scripts/list_models_csv.sh

Notes:
- The extractor intentionally targets files in `docs/data_models/*/images/` only.
- The CSV lists `*_model.gif` from the whole repo; `category` is filled only when the path matches `docs/data_models/<category>/images/...`.

Additional tools:
- `scripts/batch_commit_images.sh` commits extracted `*_model.gif` files in safe-sized batches. Run with `--dry-run` first to verify behavior.
- `scripts/setup_git_lfs.sh` configures Git LFS to track `*.gif` and commits `.gitattributes`. Recommended before committing many GIFs to avoid repo bloat.

- By default this README and the scripts are safe to commit without adding the full set of extracted images.

**Tip:** Use `scripts/batch_commit_images.sh -n 200 -d images -b workup --push-after-all` to commit in 200-file batches and push once at the end.
