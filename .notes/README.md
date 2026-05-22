# `.notes/` — Repo Handoff Notes v2 enforcement

The convention is documented elsewhere; this directory makes it teeth-having
instead of vibes-having. Drop `.notes/` into the root of any repo using the
v2 convention, run the installer, and the same-commit rule + commit-message
anchor are enforced both locally (git hooks) and in CI (GitHub Actions).

Built to support both Lovable scenarios:

1. **Lovable Cloud + your own GitHub + Claude Code for backend.** Lovable
   commits frontend through its UI; Claude Code commits backend from your
   terminal. Hooks catch your terminal commits; CI catches Lovable's.
2. **Your own Supabase + your own GitHub + Lovable for UI scaffolding +
   Claude Code for backend.** Same enforcement story. The path globs in
   `config.sh` already match the standard Lovable + Supabase layout.

## Install

```bash
# From your repo root, after copying the .notes/ directory in:
bash .notes/install.sh
```

That's it. The installer:
- Wires `pre-commit` and `commit-msg` hooks into `.git/hooks/` (chaining any
  pre-existing hooks rather than clobbering them)
- Copies the CI workflow to `.github/workflows/notes-check.yml`
- Seeds `AI_NOTES.md` and `BACKEND_NOTES.md` if they don't exist yet
- Creates a starter `.notesrc` for local overrides

Re-running is idempotent.

## What it enforces

| Rule | Where caught | Bypassable? |
|---|---|---|
| Frontend code touched ⇒ `AI_NOTES.md` touched in same commit | pre-commit + CI | `NOTES_SKIP=1` (local only — CI still catches it) |
| Backend code touched ⇒ `BACKEND_NOTES.md` touched in same commit | pre-commit + CI | same |
| Commits touching notes have `Notes: YYYY-MM-DD — title` in body | commit-msg + CI | same |
| No `<TBD>` placeholders inside `[STATUS: PROCESSED]` entries | pre-commit + CI | same |

CI is the real enforcement. Hooks are convenience to catch issues before
the push. Lovable's commits won't trigger local hooks (different env) — CI
handles them.

## Daily use

```bash
# Start a new entry — stable ID is generated and printed at the end
.notes/scripts/new-entry.sh backend "Add refund_ledger table + 30-day guard"

# See everything still pending action across both files
.notes/scripts/list-new.sh

# Show just one surface
.notes/scripts/list-new.sh backend
```

Then commit with a body anchor like:

```
Add refund_ledger table for 30-day refund abuse guard

Notes: 2026-05-22 — Add refund_ledger table + 30-day guard
Ref: BN-2026-05-22-001
```

`git log --grep "Notes:"` reconstructs the entire handoff history.

## Configuration

`.notes/config.sh` ships sensible defaults. Override any of them in a
top-level `.notesrc` (created by the installer) — values there take
precedence and stay local to your checkout if you `.gitignore` it.

Key knobs:

- `NOTES_MODE` — `strict` (default, fails the commit), `warn` (prints but
  passes), or `off` (skip entirely; useful for a one-off refactor)
- `NOTES_FRONTEND_PATHS` / `NOTES_BACKEND_PATHS` — path-prefix lists for
  surface detection. Defaults work for standard Lovable + Supabase repos
- `NOTES_REQUIRE_COMMIT_ANCHOR` — toggle the `Notes:` line requirement
- `NOTES_REJECT_TBD_IN_PROCESSED` — toggle the placeholder check

## Emergency bypass

For genuinely urgent commits where the notes update will land in a
follow-up:

```bash
NOTES_SKIP=1 git commit -m "Hotfix prod auth"
```

CI will still flag the PR. Use this to unblock yourself, not to skip
enforcement permanently — if you find yourself reaching for it twice in
one week, the convention isn't working for your team and the right move
is to recalibrate `NOTES_MODE=warn` until you fix the friction.

## What this does NOT do

- **Format-validate entries** — no schema check on the body of an entry.
  Add it later if drift gets worse.
- **Detect cross-cutting changes** — if your code touches both surfaces
  but you only updated one notes file, both rules pass independently.
  Could be added (require both files for cross-cutting commits) but it
  would generate false positives on legitimate single-surface changes
  that happen to touch a shared file.
- **Auto-archive old entries** — manual for now. The 2k-line threshold is
  a discipline, not an automation.
- **Enforce inside Lovable's session-time editing** — Lovable's UI commits
  to GitHub when you publish, and CI catches it there. Pre-publish
  enforcement would require a Lovable-side integration that doesn't exist.

## File map

```
.notes/
├── README.md                          ← this file
├── config.sh                          ← defaults; override in .notesrc
├── install.sh                         ← one-shot installer (idempotent)
├── hooks/
│   ├── pre-commit                     ← same-commit + TBD check
│   └── commit-msg                     ← Notes: anchor check
├── scripts/
│   ├── detect-surfaces.sh             ← shared surface detection
│   ├── enforce.sh                     ← shared rule engine
│   ├── check-pr.sh                    ← CI same-commit check
│   ├── check-commit-anchors.sh        ← CI anchor check
│   ├── new-entry.sh                   ← create a new [NEW] entry
│   └── list-new.sh                    ← list all pending entries
└── workflows/
    └── notes-check.yml                ← copied to .github/workflows/ by installer
```
