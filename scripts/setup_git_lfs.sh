#!/usr/bin/env bash
set -euo pipefail

# Setup Git LFS for GIFs in this repo. Tracks '*.gif' and commits .gitattributes.
# Usage: scripts/setup_git_lfs.sh

if ! command -v git >/dev/null 2>&1; then
  echo "Error: git is required to run this script." >&2
  exit 2
fi

if ! command -v git-lfs >/dev/null 2>&1 && ! command -v git-lfs >/dev/null 2>&1; then
  echo "Warning: git-lfs is not installed. Please install Git LFS and re-run this script." >&2
  exit 3
fi

# Install LFS hooks
git lfs install --local

# Track GIFs
if ! grep -q "\\*.gif filter=lfs" .gitattributes 2>/dev/null; then
  git lfs track "*.gif"
  git add .gitattributes
  git commit -m "Add Git LFS tracking for GIFs"
  echo "Git LFS tracking added and .gitattributes committed."
else
  echo "GIFs already tracked in .gitattributes"
fi

echo "Git LFS setup complete."
