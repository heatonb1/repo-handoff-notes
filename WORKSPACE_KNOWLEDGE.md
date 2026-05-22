# Workspace Knowledge snippet

Paste this into your AI tool's Workspace Knowledge (Lovable), system
prompt (Cursor, Bolt, v0), or equivalent. It tells the AI how to
participate in the Repo Handoff Notes v2 convention.

Stack-agnostic on purpose. Add your own coding standards above it.

Character count: ~3,700. Leaves headroom under a 10K limit.

---

```
# Repo Handoff Notes v2 — async handoff convention

You and I (the AI agent) co-maintain two log files at the repo root so we
don't drift when working async on the same codebase. This convention may
be machine-enforced by an installed `.notes/` directory at the repo root
(pre-commit hooks + GitHub Actions). If `.notes/` is present, violations
of the enforced rules below WILL fail commits or CI. If not, the rules
are honor-system but still required.

Two log files
- `AI_NOTES.md` — frontend / UI-side changes
- `BACKEND_NOTES.md` — backend changes (database, server functions,
  auth, secrets, storage, scheduled jobs, infrastructure)

Adjust the "what counts as backend" definition to fit your stack
(Supabase, Firebase, Hasura, Rails API, Django, etc.). The split is
whatever maps to "the two surfaces being co-maintained."

Entry format (newest on top, inserted above `_Add new entries above this line._`)

## [YYYY-MM-DD] Short title [STATUS: NEW]

<!-- id: BN-YYYY-MM-DD-NNN -->

- **What**: 1-line description
- **Area**: e.g. "migration + edge function"
- **Files**: exact paths
- **Code verbatim**: fenced block when behavior-critical
- **Cross-side wiring**: how the other surface consumes this, or "none"
- **Verification**: how to confirm it works
- **Follow-ups**: known debt or "none"

Entry ID rules
- Prefix `AN-` for AI_NOTES entries, `BN-` for BACKEND_NOTES entries.
- Date is today (YYYY-MM-DD).
- NNN is a zero-padded sequence. Find the highest existing ID for today
  with the same prefix in the file, increment by 1. First of the day is 001.

Status tags (exact forms, the enforcement regex is strict)
- `[STATUS: NEW]` — the other party should act on it
- `[STATUS: PROCESSED]` — acted on, with one-line result + commit short-hash
- `[STATUS: BLOCKED: <reason>]` — tried, can't proceed, routes back

Enforced rules (CI will fail your PR if violated, when `.notes/` is installed)
1. Same-commit rule. Every commit touching code MUST also touch the
   matching notes file in the same commit. Backend code → BACKEND_NOTES.md.
   Frontend code → AI_NOTES.md. Cross-cutting → both files.
2. Commit-message anchor. Commit body MUST include a line:
   `Notes: YYYY-MM-DD — Short title` referencing the entry being shipped
   or flipped. Optional second line: `Ref: BN-YYYY-MM-DD-NNN`.
3. No `<TBD>` in PROCESSED entries. Flips MUST use the actual commit
   short-hash, not a placeholder.

Honor-system rules (not machine-checked, still required)
- Newest entries on top.
- Never edit existing `[STATUS: PROCESSED]` entries. Re-open with a new
  NEW entry instead.
- Never put secrets, tokens, or API keys in either file. Reference
  secret names only.
- Cross-cutting work: FULL entry in the more-relevant file plus a brief
  cross-ref stub in the other. Don't duplicate content (drift risk).
- Bidirectional flip. Either side processes the other's NEW entries.
- Archive when a file exceeds ~2k lines: move PROCESSED entries older
  than 30 days to `docs/notes/archive/YYYY-MM.md`.

Trigger phrases the user will say to me
- "check AI_NOTES.md" → read every `[STATUS: NEW]` in AI_NOTES.md.
  Act on each, then flip to `[STATUS: PROCESSED]` with a one-line result
  plus actual commit short-hash. Mark un-actionable ones
  `[STATUS: BLOCKED: <reason>]`. Never skip silently.
- "check BACKEND_NOTES.md" → same, for the backend file.
- "check both" → process BACKEND_NOTES.md first (backend changes
  often unblock frontend wiring), then AI_NOTES.md. Surface decisions
  that span both surfaces explicitly before acting on them.

Caveats
- I may not be able to read git branches. The user's work and notes
  must be committed and merged to the default branch before I can see them.
- If either notes file is missing in a repo, the `.notes/install.sh`
  installer seeds it. Don't create the files manually.
- If no `.notes/` directory exists in the repo, the enforcement layer
  isn't installed. Follow the convention anyway, but warn the user
  that violations won't be caught in CI.
```
