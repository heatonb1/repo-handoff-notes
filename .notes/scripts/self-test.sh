#!/usr/bin/env bash
# .notes/scripts/self-test.sh
#
# Verifies the enforcement layer is wired correctly by running synthetic
# file-change scenarios through the detection + enforcement scripts.
# Does NOT make any commits or modify tracked files.
#
# Run after install to confirm everything works:
#   bash .notes/scripts/self-test.sh

set -euo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel)"
cd "$REPO_ROOT"

# Disable TBD check during scenario tests — we're testing the
# same-commit rule, not the user's existing file hygiene.
# (We do a separate drift report at the end.)
export NOTES_REJECT_TBD_IN_PROCESSED=0
export NOTES_MODE=strict

PASS=0
FAIL=0
FAILURES=()

run_scenario() {
  local name="$1" expected="$2" files="$3"

  # Run detection
  local vars
  vars=$(echo -e "$files" | bash "$REPO_ROOT/.notes/scripts/detect-surfaces.sh")
  eval "$vars"
  export FRONTEND_CHANGED BACKEND_CHANGED AI_NOTES_CHANGED BACKEND_NOTES_CHANGED

  # Run enforcement
  local actual
  if bash "$REPO_ROOT/.notes/scripts/enforce.sh" commit > /dev/null 2>&1; then
    actual="pass"
  else
    actual="fail"
  fi

  if [[ "$actual" == "$expected" ]]; then
    echo "  ✓ $name"
    PASS=$((PASS + 1))
  else
    echo "  ✗ $name (expected $expected, got $actual)"
    FAIL=$((FAIL + 1))
    FAILURES+=("$name")
  fi
}

echo ""
echo "═══════════════════════════════════════════════════════════════════════"
echo " Repo Handoff Notes v2 — self-test"
echo "═══════════════════════════════════════════════════════════════════════"
echo ""
echo "Running 5 synthetic scenarios (no commits, no file changes)..."
echo ""

run_scenario "Backend code without notes → should block" "fail" \
  "supabase/migrations/test.sql"

run_scenario "Backend code WITH BACKEND_NOTES → should allow" "pass" \
  "supabase/migrations/test.sql\nBACKEND_NOTES.md"

run_scenario "Frontend code without notes → should block" "fail" \
  "src/App.tsx"

run_scenario "Frontend code WITH AI_NOTES → should allow" "pass" \
  "src/App.tsx\nAI_NOTES.md"

run_scenario "Cross-cutting change WITH both notes → should allow" "pass" \
  "src/App.tsx\nsupabase/functions/myfn/index.ts\nAI_NOTES.md\nBACKEND_NOTES.md"

echo ""
echo "Scenarios: $PASS passed, $FAIL failed"

# ---- Hook installation check ---------------------------------------------
echo ""
echo "Checking hook installation..."

HOOK_PASS=0
HOOK_FAIL=0

for hook in pre-commit commit-msg; do
  target="$REPO_ROOT/.git/hooks/$hook"
  if [[ ! -f "$target" ]]; then
    echo "  ✗ $hook hook not installed"
    HOOK_FAIL=$((HOOK_FAIL + 1))
  elif ! grep -q ".notes/hooks/$hook" "$target"; then
    echo "  ✗ $hook hook installed but doesn't reference .notes/hooks/$hook"
    HOOK_FAIL=$((HOOK_FAIL + 1))
  elif [[ ! -x "$target" ]]; then
    echo "  ✗ $hook hook present but not executable"
    HOOK_FAIL=$((HOOK_FAIL + 1))
  else
    echo "  ✓ $hook hook wired correctly"
    HOOK_PASS=$((HOOK_PASS + 1))
  fi
done

# ---- CI workflow check ----------------------------------------------------
echo ""
echo "Checking CI workflow..."

if [[ -f "$REPO_ROOT/.github/workflows/notes-check.yml" ]]; then
  echo "  ✓ .github/workflows/notes-check.yml installed"
else
  echo "  ✗ .github/workflows/notes-check.yml missing"
  HOOK_FAIL=$((HOOK_FAIL + 1))
fi

# ---- Drift report (informational, not a test failure) --------------------
echo ""
echo "Checking for existing drift in your notes files (informational)..."

DRIFT_LINES=""
# shellcheck disable=SC1091
source "$REPO_ROOT/.notes/config.sh"
for file in "$NOTES_AI_FILE" "$NOTES_BACKEND_FILE"; do
  [[ ! -f "$REPO_ROOT/$file" ]] && continue
  drift=$(awk '
    /^## / {
      in_processed = ($0 ~ /\[STATUS:[[:space:]]*PROCESSED\]/ || $0 ~ /\[PROCESSED\]/)
      next
    }
    in_processed && /<TBD>/ { print FILENAME ":" NR }
  ' "$REPO_ROOT/$file" 2>/dev/null)
  if [[ -n "$drift" ]]; then
    DRIFT_LINES="${DRIFT_LINES}${drift}\n"
  fi
done

if [[ -z "$DRIFT_LINES" ]]; then
  echo "  ✓ no <TBD> placeholders found in [PROCESSED] entries"
else
  echo "  ⚠ found <TBD> placeholders inside existing [PROCESSED] entries:"
  echo -e "$DRIFT_LINES" | sed 's/^/      /' | head -10
  echo ""
  echo "    These will block your next commit. Backfill the commit hashes"
  echo "    or remove the <TBD> markers. (Set NOTES_REJECT_TBD_IN_PROCESSED=0"
  echo "    in .notesrc to disable this check entirely.)"
fi

# ---- Final verdict --------------------------------------------------------
echo ""
echo "═══════════════════════════════════════════════════════════════════════"
if [[ $FAIL -eq 0 && $HOOK_FAIL -eq 0 ]]; then
  echo " ✓ Self-test PASSED — enforcement is wired correctly"
  echo "═══════════════════════════════════════════════════════════════════════"
  exit 0
else
  echo " ✗ Self-test FAILED — $((FAIL + HOOK_FAIL)) issue(s)"
  echo "═══════════════════════════════════════════════════════════════════════"
  exit 1
fi
