# .notes/config.sh
# Sourced by hooks and scripts. Override any of these in a top-level .notesrc
# file (which is .gitignored by default so each contributor can customize).

# ---- Surface detection (path prefixes, space-separated) -------------------
# A staged file matches a surface if it starts with any of these prefixes.
# Defaults assume a Lovable + Supabase project. Override for monorepos or
# non-standard layouts.

NOTES_FRONTEND_PATHS="${NOTES_FRONTEND_PATHS:-src/ public/ index.html vite.config.ts vite.config.js}"
NOTES_BACKEND_PATHS="${NOTES_BACKEND_PATHS:-supabase/}"

# Files that don't count as either surface (notes files themselves, docs,
# config, lockfiles). Touching ONLY these will not trigger the same-commit
# rule. Listed as path prefixes.
NOTES_IGNORE_PATHS="${NOTES_IGNORE_PATHS:-AI_NOTES.md BACKEND_NOTES.md docs/ README.md .notes/ .github/ .gitignore .notesrc package-lock.json yarn.lock pnpm-lock.yaml bun.lockb}"

# ---- Notes file locations -------------------------------------------------
NOTES_AI_FILE="${NOTES_AI_FILE:-AI_NOTES.md}"
NOTES_BACKEND_FILE="${NOTES_BACKEND_FILE:-BACKEND_NOTES.md}"

# ---- Enforcement mode -----------------------------------------------------
# strict = fail the commit / PR
# warn   = print warning but allow
# off    = do nothing (useful temporarily during big refactors)
NOTES_MODE="${NOTES_MODE:-strict}"

# Require commit message body to contain a `Notes: <date — title>` line
# whenever a notes file was touched. Set to 0 to disable.
NOTES_REQUIRE_COMMIT_ANCHOR="${NOTES_REQUIRE_COMMIT_ANCHOR:-1}"

# Reject commits where a [PROCESSED] entry still contains the literal
# placeholder `<TBD>` (catches the failure mode we already see in the wild).
NOTES_REJECT_TBD_IN_PROCESSED="${NOTES_REJECT_TBD_IN_PROCESSED:-1}"
