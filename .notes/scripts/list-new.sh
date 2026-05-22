#!/usr/bin/env bash
# .notes/scripts/list-new.sh
#
# Prints every [STATUS: NEW] and [STATUS: BLOCKED: ...] entry from both
# notes files. This is the "inbox" view — what still needs action.
#
# Usage: list-new.sh [frontend|backend|both]   (default: both)

set -euo pipefail

WHICH="${1:-both}"

REPO_ROOT="$(git rev-parse --show-toplevel)"
# shellcheck disable=SC1091
source "$REPO_ROOT/.notes/config.sh"
[[ -f "$REPO_ROOT/.notesrc" ]] && source "$REPO_ROOT/.notesrc"

print_pending() {
  local file="$1" label="$2"
  [[ ! -f "$REPO_ROOT/$file" ]] && return

  echo ""
  echo "── $label ($file) ──"
  awk '
    /^## / {
      if ($0 ~ /\[STATUS:[[:space:]]*NEW\]/ || $0 ~ /\[STATUS:[[:space:]]*BLOCKED/) {
        print "  " $0
        found = 1
      }
    }
    END {
      if (!found) print "  (no pending entries)"
    }
  ' "$REPO_ROOT/$file"
}

case "$WHICH" in
  frontend|fe|ai) print_pending "$NOTES_AI_FILE" "FRONTEND" ;;
  backend|be|bn)  print_pending "$NOTES_BACKEND_FILE" "BACKEND" ;;
  both|*)
    print_pending "$NOTES_AI_FILE" "FRONTEND"
    print_pending "$NOTES_BACKEND_FILE" "BACKEND"
    ;;
esac
echo ""
