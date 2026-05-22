#!/usr/bin/env bash
# .notes/scripts/check-pr.sh
#
# Run by CI on every PR. Compares BASE..HEAD diff and enforces the
# same-commit rule against the *aggregate* diff, not individual commits
# (so a PR that touches frontend in commit A and AI_NOTES.md in commit B
# still passes — the PR as a whole satisfies the rule).
#
# Usage: check-pr.sh <BASE_SHA> <HEAD_SHA>
#
# This is the catch-all enforcement that runs regardless of whether the
# committer had hooks installed (which Lovable's environment will not).

set -euo pipefail

BASE_SHA="${1:-}"
HEAD_SHA="${2:-HEAD}"

if [[ -z "$BASE_SHA" ]]; then
  echo "[notes] No BASE_SHA — skipping (likely a direct push to default branch on first commit)"
  exit 0
fi

REPO_ROOT="$(git rev-parse --show-toplevel)"
cd "$REPO_ROOT"

# Aggregate diff across the whole PR
CHANGED=$(git diff --name-only --diff-filter=ACMRT "$BASE_SHA" "$HEAD_SHA")

if [[ -z "$CHANGED" ]]; then
  echo "[notes] No file changes in range — skipping"
  exit 0
fi

echo "[notes] Checking $(echo "$CHANGED" | wc -l | tr -d ' ') changed files in $BASE_SHA..$HEAD_SHA"

eval "$(echo "$CHANGED" | bash "$REPO_ROOT/.notes/scripts/detect-surfaces.sh")"
export FRONTEND_CHANGED BACKEND_CHANGED AI_NOTES_CHANGED BACKEND_NOTES_CHANGED

bash "$REPO_ROOT/.notes/scripts/enforce.sh" pr
