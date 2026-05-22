#!/usr/bin/env bash
# .notes/scripts/new-entry.sh
#
# Creates a new [STATUS: NEW] entry at the top of the appropriate notes
# file with a stable ID like AN-2026-05-22-001 (frontend) or BN-2026-05-22-001
# (backend). The ID is what the commit anchor references — titles can drift,
# IDs can't.
#
# Usage:
#   .notes/scripts/new-entry.sh frontend "Short title here"
#   .notes/scripts/new-entry.sh backend  "Short title here"

set -euo pipefail

SURFACE="${1:-}"
TITLE="${2:-}"

if [[ -z "$SURFACE" || -z "$TITLE" ]]; then
  cat <<EOF
Usage: $0 <frontend|backend> "<short title>"

Creates a [STATUS: NEW] entry at the top of AI_NOTES.md (frontend) or
BACKEND_NOTES.md (backend), with a stable entry ID.
EOF
  exit 1
fi

REPO_ROOT="$(git rev-parse --show-toplevel)"
# shellcheck disable=SC1091
source "$REPO_ROOT/.notes/config.sh"
[[ -f "$REPO_ROOT/.notesrc" ]] && source "$REPO_ROOT/.notesrc"

case "$SURFACE" in
  frontend|fe|ai)  FILE="$REPO_ROOT/$NOTES_AI_FILE";      PREFIX="AN" ;;
  backend|be|bn)   FILE="$REPO_ROOT/$NOTES_BACKEND_FILE"; PREFIX="BN" ;;
  *) echo "Unknown surface: $SURFACE (use 'frontend' or 'backend')"; exit 1 ;;
esac

DATE=$(date +%Y-%m-%d)

# Compute next sequence number for today
EXISTING_TODAY=$(grep -oE "${PREFIX}-${DATE}-[0-9]{3}" "$FILE" 2>/dev/null | sort -u | tail -1 || true)
if [[ -z "$EXISTING_TODAY" ]]; then
  SEQ="001"
else
  LAST_SEQ="${EXISTING_TODAY##*-}"
  SEQ=$(printf "%03d" $((10#$LAST_SEQ + 1)))
fi

ENTRY_ID="${PREFIX}-${DATE}-${SEQ}"

ENTRY=$(cat <<EOF
## [${DATE}] ${TITLE} [STATUS: NEW]

<!-- id: ${ENTRY_ID} -->

- **What**: TODO — 1-line description of the change
- **Area**: TODO
- **Files**: TODO — exact paths
- **Cross-side wiring**: TODO or "none"
- **Verification**: TODO — how to confirm it works
- **Follow-ups**: TODO or "none"

EOF
)

# Insert above "_Add new entries above this line._" if present,
# otherwise above the first existing entry, otherwise at end of file.
# Always append a trailing blank line after the entry for visual separation.
if grep -q "_Add new entries above this line._" "$FILE" 2>/dev/null; then
  # Insert before the marker
  awk -v entry="$ENTRY" '
    /_Add new entries above this line\._/ && !inserted {
      print entry
      print ""
      inserted = 1
    }
    { print }
  ' "$FILE" > "$FILE.tmp" && mv "$FILE.tmp" "$FILE"
elif grep -q "^## " "$FILE" 2>/dev/null; then
  # Insert above the first ## heading
  awk -v entry="$ENTRY" '
    /^## / && !inserted {
      print entry
      print ""
      inserted = 1
    }
    { print }
  ' "$FILE" > "$FILE.tmp" && mv "$FILE.tmp" "$FILE"
else
  # Append (file is new/empty)
  if [[ ! -f "$FILE" ]]; then
    case "$SURFACE" in
      frontend|fe|ai)
        echo "# $NOTES_AI_FILE" > "$FILE"
        echo "" >> "$FILE"
        echo "Running log from local dev → Lovable for **frontend** changes." >> "$FILE"
        echo "Backend changes go in \`$NOTES_BACKEND_FILE\`." >> "$FILE"
        echo "" >> "$FILE"
        ;;
      *)
        echo "# $NOTES_BACKEND_FILE" > "$FILE"
        echo "" >> "$FILE"
        echo "Running log from local dev → Lovable for **backend** changes" >> "$FILE"
        echo "(migrations, edge functions, RLS, secrets, auth, storage, cron)." >> "$FILE"
        echo "Frontend changes go in \`$NOTES_AI_FILE\`." >> "$FILE"
        echo "" >> "$FILE"
        ;;
    esac
  fi
  echo "$ENTRY" >> "$FILE"
  echo "" >> "$FILE"
  echo "_Add new entries above this line._" >> "$FILE"
fi

echo "Created entry $ENTRY_ID in $(basename "$FILE")"
echo ""
echo "Commit body should include:"
echo "  Notes: ${DATE} — ${TITLE}"
echo "  Ref: ${ENTRY_ID}"
