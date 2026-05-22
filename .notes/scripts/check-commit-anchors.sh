#!/usr/bin/env bash
# .notes/scripts/check-commit-anchors.sh
#
# Scans every commit in BASE..HEAD; for commits that touched a notes file,
# verifies the commit body contains a `Notes: <date> — <title>` anchor.
# This catches Lovable commits (whose dev environment doesn't run our hooks)
# plus any commits made with NOTES_SKIP=1 locally.

set -euo pipefail

BASE_SHA="${1:-}"
HEAD_SHA="${2:-HEAD}"

REPO_ROOT="$(git rev-parse --show-toplevel)"
# shellcheck disable=SC1091
source "$REPO_ROOT/.notes/config.sh"
[[ -f "$REPO_ROOT/.notesrc" ]] && source "$REPO_ROOT/.notesrc"

if [[ "$NOTES_REQUIRE_COMMIT_ANCHOR" != "1" || "$NOTES_MODE" == "off" ]]; then
  echo "[notes] anchor check disabled"
  exit 0
fi

if [[ -z "$BASE_SHA" ]]; then
  echo "[notes] No BASE_SHA — skipping anchor check"
  exit 0
fi

ANCHOR_REGEX='^Notes:[[:space:]]+[0-9]{4}-[0-9]{2}-[0-9]{2}[[:space:]]+[—–-]'
MISSING=()

for sha in $(git rev-list --no-merges "$BASE_SHA..$HEAD_SHA"); do
  # Did this commit touch a notes file?
  files=$(git diff-tree --no-commit-id --name-only -r "$sha")
  touched_notes=0
  while IFS= read -r f; do
    if [[ "$f" == "$NOTES_AI_FILE" || "$f" == "$NOTES_BACKEND_FILE" ]]; then
      touched_notes=1
      break
    fi
  done <<< "$files"
  [[ "$touched_notes" == "0" ]] && continue

  # Check commit body for the anchor
  body=$(git log -1 --format=%B "$sha")
  if ! echo "$body" | grep -Eq "$ANCHOR_REGEX"; then
    short=$(git log -1 --format=%h "$sha")
    subject=$(git log -1 --format=%s "$sha")
    MISSING+=("$short  $subject")
  fi
done

if [[ ${#MISSING[@]} -eq 0 ]]; then
  echo "[notes] ✓ all notes-touching commits have anchors"
  exit 0
fi

echo ""
echo "═══════════════════════════════════════════════════════════════════════"
echo " Repo Handoff Notes v2 — commits missing Notes: anchor"
echo "═══════════════════════════════════════════════════════════════════════"
echo ""
echo " These commits touched a notes file but their commit message body"
echo " has no \`Notes: YYYY-MM-DD — title\` anchor:"
echo ""
for m in "${MISSING[@]}"; do echo "   $m"; done
echo ""
echo " Without the anchor, \`git log --grep \"Notes:\"\` is incomplete."
echo " Amend the commit body or merge with the missing anchors recorded"
echo " as known-debt."
echo "═══════════════════════════════════════════════════════════════════════"

if [[ "$NOTES_MODE" == "warn" ]]; then
  echo "[notes] NOTES_MODE=warn — not failing"
  exit 0
fi

exit 1
