#!/usr/bin/env bash
set -euo pipefail

# Usage:
#   scripts/run_commit_and_pr.sh [--branch BRANCH] [--batch-size N] [--dir DIR] [--auto-approve]
#
# Example:
#   chmod +x scripts/run_commit_and_pr.sh
#   ./scripts/run_commit_and_pr.sh --branch workup --batch-size 200 --dir images

BRANCH="workup"
BATCH_SIZE=200
DIR="images"
AUTO_APPROVE=0
PR_TITLE="Add scripts to extract/list *_model.gif files"
PR_BODY=$'Adds two helper scripts:\n\n- scripts/extract_models.sh — copies docs/data_models/*/images/*_model.gif into images/ prefixed by category\n- scripts/list_models_csv.sh — writes images/models_list.csv listing all *_model.gif\n\nAlso adds scripts/README.md and optional helper scripts for batching and LFS.\n\nThis PR intentionally includes only the scripts and CSV to avoid repo bloat; if needed, images can be added using Git LFS in a follow-up step.'

while [[ $# -gt 0 ]]; do
  case "$1" in
    --branch) BRANCH="$2"; shift 2;;
    --batch-size) BATCH_SIZE="$2"; shift 2;;
    --dir) DIR="$2"; shift 2;;
    --auto-approve) AUTO_APPROVE=1; shift;;
    -h|--help) echo "Usage: $0 [--branch BRANCH] [--batch-size N] [--dir DIR] [--auto-approve]"; exit 0;;
    *) echo "Unknown arg $1"; exit 2;;
  esac
done

log() { printf '\033[1;32m[INFO]\033[0m %s\n' "$*"; }
err() { printf '\033[1;31m[ERROR]\033[0m %s\n' "$*" >&2; }

# Files to commit for Option B
files_to_stage=(
  "scripts/extract_models.sh"
  "scripts/list_models_csv.sh"
  "scripts/README.md"
  "scripts/batch_commit_images.sh"
  "scripts/setup_git_lfs.sh"
  "images/models_list.csv"
)

# Ensure git repository
if ! command -v git >/dev/null 2>&1; then
  err "git not found — run this locally in a machine with git configured"
  exit 2
fi

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  err "Not inside a git repository. Run from repo root."
  exit 2
fi

# Option B: Commit scripts + CSV, push, create PR
do_option_b() {
  log "Option B: commit scripts & CSV to branch '$BRANCH' and create PR."

  log "Creating/checking out branch '$BRANCH'..."
  git checkout -B "$BRANCH"

  log "Staging files for Option B..."
  git add -- "${files_to_stage[@]}" || true

  if git diff --cached --quiet; then
    log "No staged changes to commit for Option B."
  else
    log "Committing staged files..."
    git commit -m "Add scripts to extract and list *_model.gif; add README and models_list.csv"
  fi

  log "Pushing branch '$BRANCH'..."
  if git push --set-upstream origin "$BRANCH"; then
    log "Push succeeded."
  else
    err "Push failed (possible large files or remote error)."
    return 2
  fi

  # Try to create PR using gh
  if command -v gh >/dev/null 2>&1; then
    log "Creating PR via gh..."
    if gh pr create --base main --head "$BRANCH" --title "$PR_TITLE" --body "$PR_BODY"; then
      log "PR created successfully."
    else
      err "gh PR creation failed (but push succeeded). You can create the PR manually."
    fi
  else
    log "gh CLI not found. Create a PR on GitHub using the branch '$BRANCH'."
  fi

  return 0
}

# Option A: Enable Git LFS and batch-commit images
do_option_a() {
  log "Option A: configure Git LFS and commit extracted images in batches."

  if command -v git-lfs >/dev/null 2>&1 || command -v git lfs >/dev/null 2>&1; then
    log "Configuring Git LFS for '*.gif'..."
    git lfs install --local || true
    if ! grep -q '^\*\.gif' .gitattributes 2>/dev/null; then
      git lfs track "*.gif"
      git add .gitattributes
      git commit -m "Add Git LFS tracking for GIFs" || log "No .gitattributes commit needed."
    else
      log "*.gif already tracked in .gitattributes"
    fi
  else
    err "git-lfs not installed; installing it is recommended before committing thousands of GIFs."
    if [[ $AUTO_APPROVE -ne 1 ]]; then
      read -p "Continue and try to commit without LFS? (y/N) " yn
      [[ "${yn,,}" == "y" ]] || { err "Aborting Option A."; return 3; }
    else
      log "AUTO_APPROVE set: proceeding without git-lfs (not recommended)."
    fi
  fi

  # Use batch commit helper
  if [[ -x scripts/batch_commit_images.sh ]]; then
    log "Running batch commit helper (batch size $BATCH_SIZE)..."
    if ./scripts/batch_commit_images.sh -n "$BATCH_SIZE" -d "$DIR" -b "$BRANCH" --push-after-all; then
      log "Batch commits completed."
    else
      err "Batch commit helper failed."
      return 4
    fi
  else
    err "scripts/batch_commit_images.sh not found or not executable. Add it or run manual batching."
    return 5
  fi

  # Ensure PR exists
  if command -v gh >/dev/null 2>&1; then
    log "Creating PR via gh (post-images)..."
    gh pr create --base main --head "$BRANCH" --title "$PR_TITLE (with images)" --body "$PR_BODY
\n\nThis PR also includes the extracted images committed in batches (using Git LFS if available)." || log "PR creation might have failed or PR may already exist."
  else
    log "gh CLI not found; create or update PR manually on GitHub for branch '$BRANCH'."
  fi

  return 0
}

# Main flow
if do_option_b; then
  log "Option B completed successfully."
  exit 0
else
  err "Option B failed; preparing to run Option A."
  if [[ $AUTO_APPROVE -ne 1 ]]; then
    read -p "Proceed with Option A (enable LFS & batch-commit images)? (y/N) " reply
    if [[ "${reply,,}" != "y" ]]; then
      err "User declined Option A. Exiting."
      exit 3
    fi
  else
    log "AUTO_APPROVE set: proceeding with Option A automatically."
  fi

  if do_option_a; then
    log "Option A completed (images committed)."
    exit 0
  else
    err "Option A also failed. Please check environment (git, git-lfs, gh) and run script again or run commands manually."
    exit 4
  fi
fi