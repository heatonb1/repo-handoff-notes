#!/usr/bin/env bash
# .notes/scripts/enforce.sh
#
# Given detection results in the environment (from detect-surfaces.sh) and
# a "context" arg ("commit" or "pr"), prints PASS/FAIL and exits 0/1.
#
# Usage: enforce.sh <context>
# Reads: FRONTEND_CHANGED, BACKEND_CHANGED, AI_NOTES_CHANGED, BACKEND_NOTES_CHANGED
# Optional: SCAN_PATH (root to scan for <TBD> check; defaults to repo root)

set -euo pipefail

CONTEXT="${1:-commit}"
REPO_ROOT="$(git rev-parse --show-toplevel)"
# shellcheck disable=SC1091
source "$REPO_ROOT/.notes/config.sh"
[[ -f "$REPO_ROOT/.notesrc" ]] && source "$REPO_ROOT/.notesrc"

# Mode short-circuit
if [[ "$NOTES_MODE" == "off" ]]; then
  echo "[notes] NOTES_MODE=off — skipping all checks"
  exit 0
fi

FAIL=0
WARNINGS=()
ERRORS=()

# ---- Rule 1: Same-commit / same-PR ----------------------------------------
if [[ "${FRONTEND_CHANGED:-0}" == "1" && "${AI_NOTES_CHANGED:-0}" == "0" ]]; then
  ERRORS+=("Frontend code changed but $NOTES_AI_FILE was not updated in the same $CONTEXT.")
fi
if [[ "${BACKEND_CHANGED:-0}" == "1" && "${BACKEND_NOTES_CHANGED:-0}" == "0" ]]; then
  ERRORS+=("Backend code changed but $NOTES_BACKEND_FILE was not updated in the same $CONTEXT.")
fi

# ---- Rule 2: No <TBD> in [PROCESSED] entries ------------------------------
# Catches the failure mode where a flip happens but the commit hash never
# gets backfilled.
if [[ "$NOTES_REJECT_TBD_IN_PROCESSED" == "1" ]]; then
  for file in "$NOTES_AI_FILE" "$NOTES_BACKEND_FILE"; do
    [[ ! -f "$REPO_ROOT/$file" ]] && continue
    # awk: track current entry's status; flag <TBD> only inside [PROCESSED] blocks
    tbd_lines=$(awk '
      /^## / {
        in_processed = ($0 ~ /\[STATUS:[[:space:]]*PROCESSED\]/ || $0 ~ /\[PROCESSED\]/)
        next
      }
      in_processed && /<TBD>/ { print FILENAME ":" NR ": " $0 }
    ' "$REPO_ROOT/$file" || true)
    if [[ -n "$tbd_lines" ]]; then
      ERRORS+=("$file contains <TBD> placeholder inside a [PROCESSED] entry:")
      while IFS= read -r line; do ERRORS+=("    $line"); done <<< "$tbd_lines"
    fi
  done
fi

# ---- Print results --------------------------------------------------------
if [[ ${#ERRORS[@]} -eq 0 ]]; then
  echo "[notes] ✓ same-commit rule satisfied (context: $CONTEXT)"
  exit 0
fi

echo ""
echo "═══════════════════════════════════════════════════════════════════════"
echo " Repo Handoff Notes v2 — enforcement failure"
echo "═══════════════════════════════════════════════════════════════════════"
for err in "${ERRORS[@]}"; do
  echo "  ✗ $err"
done
echo ""
echo " The same-commit rule (v2): every commit touching code must also"
echo " touch the matching notes file. Add a [STATUS: NEW] entry for new"
echo " work, OR flip an existing [STATUS: NEW] to [STATUS: PROCESSED]."
echo ""

if [[ "$CONTEXT" == "commit" ]]; then
  echo " Quick fix:"
  echo "   .notes/scripts/new-entry.sh frontend \"<short title>\""
  echo "   .notes/scripts/new-entry.sh backend  \"<short title>\""
  echo ""
  echo " Emergency bypass (use sparingly, CI will still catch it):"
  echo "   NOTES_SKIP=1 git commit ..."
fi
echo "═══════════════════════════════════════════════════════════════════════"

if [[ "$NOTES_MODE" == "warn" ]]; then
  echo "[notes] NOTES_MODE=warn — not failing"
  exit 0
fi

exit 1
