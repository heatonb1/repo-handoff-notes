#!/usr/bin/env bash
# .notes/scripts/detect-surfaces.sh
#
# Shared logic: given a list of changed files on stdin, prints a result
# block to stdout that other scripts source via eval.
#
# Output variables:
#   FRONTEND_CHANGED       0/1
#   BACKEND_CHANGED        0/1
#   AI_NOTES_CHANGED       0/1
#   BACKEND_NOTES_CHANGED  0/1
#   FRONTEND_FILES         newline-separated list
#   BACKEND_FILES          newline-separated list

set -euo pipefail

# Resolve repo root and source config
REPO_ROOT="$(git rev-parse --show-toplevel)"
# shellcheck disable=SC1091
source "$REPO_ROOT/.notes/config.sh"
[[ -f "$REPO_ROOT/.notesrc" ]] && source "$REPO_ROOT/.notesrc"

FRONTEND_CHANGED=0
BACKEND_CHANGED=0
AI_NOTES_CHANGED=0
BACKEND_NOTES_CHANGED=0
FRONTEND_FILES=""
BACKEND_FILES=""

match_prefix() {
  local file="$1" prefixes="$2"
  for p in $prefixes; do
    case "$file" in
      "$p"*) return 0 ;;
    esac
  done
  return 1
}

while IFS= read -r file; do
  [[ -z "$file" ]] && continue

  # Skip ignored paths first (notes files themselves, docs, etc.)
  if match_prefix "$file" "$NOTES_IGNORE_PATHS"; then
    # But still record if the notes files specifically were touched
    [[ "$file" == "$NOTES_AI_FILE" ]] && AI_NOTES_CHANGED=1
    [[ "$file" == "$NOTES_BACKEND_FILE" ]] && BACKEND_NOTES_CHANGED=1
    continue
  fi

  if match_prefix "$file" "$NOTES_FRONTEND_PATHS"; then
    FRONTEND_CHANGED=1
    FRONTEND_FILES="${FRONTEND_FILES}${file}"$'\n'
  fi
  if match_prefix "$file" "$NOTES_BACKEND_PATHS"; then
    BACKEND_CHANGED=1
    BACKEND_FILES="${BACKEND_FILES}${file}"$'\n'
  fi
done

# Emit results as shell assignments
cat <<EOF
FRONTEND_CHANGED=$FRONTEND_CHANGED
BACKEND_CHANGED=$BACKEND_CHANGED
AI_NOTES_CHANGED=$AI_NOTES_CHANGED
BACKEND_NOTES_CHANGED=$BACKEND_NOTES_CHANGED
EOF
