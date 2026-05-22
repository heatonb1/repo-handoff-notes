# BACKEND_NOTES.md

Running log of backend changes (database, server functions, RLS, secrets,
storage, scheduled jobs, infrastructure). Frontend / UI changes go in
`AI_NOTES.md`. If a change spans both, log in the more-relevant file
and post a brief cross-reference stub in the other.

In this particular repo, "backend" means the `.notes/` enforcement layer
itself — the scripts, hooks, and CI workflow that adopters install into
their own repos. There is no traditional backend (no database, no API,
no server functions) because this repo ships tooling, not a product.

## How to use

- **`[STATUS: NEW]`** — needs the other party's attention
- **`[STATUS: PROCESSED]`** — acted on, with one-line result + commit short-hash
- **`[STATUS: BLOCKED: <reason>]`** — read but can't act, routes back

Newest entries on top. Never edit `[STATUS: PROCESSED]` entries.
Never put secrets, tokens, or keys here. Reference secret names only.

## [2026-05-22] Initial `.notes/` enforcement layer — hooks, CI, helpers, installer [STATUS: PROCESSED]

<!-- id: BN-2026-05-22-001 -->

**Result (initial commit, 26c236e):** Full `.notes/` directory shipped. Pre-commit hook (same-commit rule + unresolved-placeholder rejection), commit-msg hook (Notes: anchor), GitHub Actions workflow (catch-all for un-hooked commits including those from no-code-side tools), helper scripts (new-entry, list-new), CI scripts (check-pr, check-commit-anchors), shared logic (detect-surfaces, enforce), self-test, and idempotent installer. Convention enforced in three places: pre-commit, commit-msg, and CI on PR. Bypass via `NOTES_SKIP=1` for local emergencies, still caught in CI.

- **What**: Drop-in enforcement layer for the Repo Handoff Notes v2 convention. Installs into any git repo via `bash .notes/install.sh`.
- **Area**: Git hooks, GitHub Actions, shell helpers, installer.
- **Files**: `.notes/install.sh`, `.notes/config.sh`, `.notes/hooks/pre-commit`, `.notes/hooks/commit-msg`, `.notes/scripts/detect-surfaces.sh`, `.notes/scripts/enforce.sh`, `.notes/scripts/check-pr.sh`, `.notes/scripts/check-commit-anchors.sh`, `.notes/scripts/new-entry.sh`, `.notes/scripts/list-new.sh`, `.notes/scripts/self-test.sh`, `.notes/workflows/notes-check.yml`, `.notes/README.md`.
- **Cross-side wiring**: Human-facing docs (README, QUICKSTART, SETUP, WORKSPACE_KNOWLEDGE) describe how adopters install and use this layer. See AI_NOTES.md entry of the same date.
- **Verification**: `bash .notes/install.sh` then `bash .notes/scripts/self-test.sh` returns green on a clean repo. Five synthetic scenarios pass (backend without notes blocks, backend with notes passes, frontend without notes blocks, frontend with notes passes, cross-cutting with both notes passes). Hook wiring check confirms `.git/hooks/pre-commit` and `commit-msg` reference `.notes/hooks/`. CI workflow file present at `.github/workflows/notes-check.yml`. Drift check finds no unresolved placeholders in seeded PROCESSED entries.
- **Follow-ups**: Windows / PowerShell variant of the hooks if Windows adoption emerges. A `notes` CLI wrapper (`notes new backend "title"` instead of `.notes/scripts/new-entry.sh backend "title"`) if the path becomes friction. Honest inbox-vs-changelog split (separate `INBOX.md` from `LOG.md`) if files start exceeding the 2k-line archive threshold faster than monthly archiving handles.

_Add new entries above this line._
