#!/usr/bin/env bash
set -euo pipefail

# Commit *_model.gif files in safe batches with optional push behavior.
# Usage: scripts/batch_commit_images.sh [-n BATCH_SIZE] [-d DIR] [-b BRANCH] [--push-after-batch] [--push-after-all] [--setup-lfs] [--dry-run]
# Example: scripts/batch_commit_images.sh -n 200 -d images -b workup --push-after-all

print_usage() {
  cat <<'USAGE'
Usage: batch_commit_images.sh [options]

Options:
  -n, --batch-size N       Number of files per commit batch (default: 200)
  -d, --dir DIR            Directory to search for *_model.gif (default: images)
  -b, --branch BRANCH      Branch to commit to (default: workup)
      --push-after-batch  Push to origin after each batch commit
      --push-after-all    Push once at the end after all commits
      --setup-lfs         Run scripts/setup_git_lfs.sh before committing (tracks *.gif with Git LFS)
      --dry-run           Print actions without performing commits
  -h, --help               Show this help
USAGE
}

# Defaults
BATCH_SIZE=200
DIR="images"
BRANCH="workup"
PUSH_AFTER_BATCH=0
PUSH_AFTER_ALL=0
SETUP_LFS=0
DRY_RUN=0

# Parse args
while [[ $# -gt 0 ]]; do
  case "$1" in
    -n|--batch-size) BATCH_SIZE="$2"; shift 2;;
    -d|--dir) DIR="$2"; shift 2;;
    -b|--branch) BRANCH="$2"; shift 2;;
    --push-after-batch) PUSH_AFTER_BATCH=1; shift;;
    --push-after-all) PUSH_AFTER_ALL=1; shift;;
    --setup-lfs) SETUP_LFS=1; shift;;
    --dry-run) DRY_RUN=1; shift;;
    -h|--help) print_usage; exit 0;;
    *) echo "Unknown argument: $1" >&2; print_usage; exit 2;;
  esac
done

# Check git available and we're inside a repo
if ! command -v git >/dev/null 2>&1; then
  cat <<'MSG'
Error: git CLI not found in this environment.
Run these commands locally instead to batch-commit images:

  # From repo root
  git checkout -B workup
  scripts/batch_commit_images.sh -n 200 -d images -b workup --push-after-all

MSG
  exit 2
fi

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "Error: Not inside a git repository or git can't access the repo. Run this locally from the repo root." >&2
  exit 2
fi

# Optionally setup LFS
if [[ "$SETUP_LFS" -eq 1 ]]; then
  if [[ "$DRY_RUN" -eq 1 ]]; then
    echo "DRY RUN: would run scripts/setup_git_lfs.sh"
  else
    if [[ -x scripts/setup_git_lfs.sh ]]; then
      echo "Setting up Git LFS (tracking '*.gif')"
      scripts/setup_git_lfs.sh || { echo "Git LFS setup failed" >&2; exit 3; }
    else
      echo "scripts/setup_git_lfs.sh not found or not executable. Skipping LFS setup." >&2
    fi
  fi
fi

# Ensure branch
if [[ "$DRY_RUN" -eq 1 ]]; then
  echo "DRY RUN: would create/checkout branch '$BRANCH'"
else
  git checkout -B "$BRANCH"
fi

# Build list of untracked *_model.gif files under DIR
mapfile -t files < <(git ls-files --others --exclude-standard -z "$DIR" 2>/dev/null | tr '\0' '\n' | grep -E '_model\.gif$' || true)

# If none, find files in DIR and exclude already tracked ones
if [[ ${#files[@]} -eq 0 ]]; then
  mapfile -t allfiles < <(find "$DIR" -type f -name '*_model.gif' -print0 | tr '\0' '\n')
  for f in "${allfiles[@]}"; do
    if git ls-files --error-unmatch "$f" >/dev/null 2>&1; then
      continue
    fi
    files+=("$f")
  done
fi

if [[ ${#files[@]} -eq 0 ]]; then
  echo "No untracked or new '*_model.gif' files to commit under '$DIR'."
  exit 0
fi

total=${#files[@]}
num_batches=$(( (total + BATCH_SIZE - 1) / BATCH_SIZE ))

echo "Found $total image(s) to add under: $DIR. Committing in $num_batches batch(es) of up to $BATCH_SIZE files to branch '$BRANCH'."

i=0
batch=1
while [[ $i -lt $total ]]; do
  chunk=("${files[@]:$i:$BATCH_SIZE}")
  echo "\n=== Batch $batch/$num_batches: ${#chunk[@]} files ==="
  if [[ "$DRY_RUN" -eq 1 ]]; then
    printf '%s\n' "${chunk[@]}"
  else
    git add -- "${chunk[@]}"
    git commit -m "Add extracted model images (batch $batch/$num_batches)"
    echo "Committed batch $batch/$num_batches ( ${#chunk[@]} files )."

    if [[ "$PUSH_AFTER_BATCH" -eq 1 ]]; then
      echo "Pushing branch '$BRANCH' to origin (after batch $batch)"
      git push origin "$BRANCH"
    fi
  fi

  ((batch++))
  i=$((i + BATCH_SIZE))
done

if [[ "$DRY_RUN" -eq 1 ]]; then
  echo "\nDRY RUN complete. Re-run without --dry-run to actually commit." 
else
  if [[ "$PUSH_AFTER_ALL" -eq 1 ]]; then
    echo "Pushing branch '$BRANCH' to origin (after all batches)"
    git push origin "$BRANCH"
  else
    echo "\nAll batches committed locally. To push the commits run: git push --set-upstream origin $BRANCH"
  fi
fi

