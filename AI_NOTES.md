# AI_NOTES.md

Running log of frontend / UI-side changes for handoff between parties
co-maintaining this repo. Backend changes go in `BACKEND_NOTES.md`.
If a change spans both surfaces, log it in the more-relevant file and
post a brief cross-reference stub in the other.

## How to use

- **`[STATUS: NEW]`** — needs the other party's attention
- **`[STATUS: PROCESSED]`** — acted on, with one-line result + commit short-hash
- **`[STATUS: BLOCKED: <reason>]`** — read but can't act, routes back

Newest entries on top. Never edit `[STATUS: PROCESSED]` entries.
Never put secrets, tokens, or keys here. Reference secret names only.

## [2026-05-22] URL-source install workflow + archive notice [STATUS: PROCESSED]

<!-- id: AN-2026-05-22-002 -->

**Result (post-launch update, 234c289):** Added a "Point Claude Code at the GitHub URL" install path as Option A in README + Option 1 in PROMPTS so adopters can hand the repo URL to Claude Code / Codex without first downloading a tarball. Added Phase 2.5 to SETUP.md telling the agent to clone the source to `/tmp/rhn-source` when given a URL. Added Status: Archived notice to README so adopters know support level upfront. Verified via 5-scenario live commit test (TEST 1 backend-without-notes blocks ✓, TEST 2 backend+notes+anchor passes ✓, TEST 3 missing Notes anchor blocks ✓, TEST 4 NOTES_SKIP=1 bypass passes ✓, TEST 5 frontend-without-notes blocks ✓).

- **What**: Documentation refresh to make the install path self-contained when adopters point Claude Code at the public GitHub URL (no manual file download required). Plus archive-status signal.
- **Area**: Human-facing docs (README, SETUP, PROMPTS) + AI_NOTES self-log.
- **Files**: `README.md` (4 install options including new URL-aware Option A + archive notice), `SETUP.md` (Phase 2.5 added), `PROMPTS.md` (2-option split: URL vs local), `AI_NOTES.md` (this entry).
- **Cross-side wiring**: None — pure documentation; `.notes/` enforcement layer unchanged. See BACKEND_NOTES.md for the unchanged-runtime confirmation.
- **Verification**: Live commit test on /tmp victim repo proved hook + commit-msg enforcement works end-to-end. Self-test still 5/5 green.
- **Follow-ups**: Repo to be archived post-merge — no further updates possible without unarchive cycle. Discord Buildathon community share planned.

## [2026-05-22] Initial repo scaffold — landing page and human-facing docs [STATUS: PROCESSED]

<!-- id: AN-2026-05-22-001 -->

**Result (initial commit, 26c236e):** Landing README.md, QUICKSTART.md (human install guide), SETUP.md (playbook for AI agents like Claude Code/Codex), and WORKSPACE_KNOWLEDGE.md (paste-ready snippet for downstream adopters) all shipped together. No actual frontend application code in this repo, so "frontend" here means the human-facing documentation surface that adopters interact with first.

- **What**: Initial scaffold of the repo's human-readable surface — the files someone sees when they land on the GitHub page or extract the folder.
- **Area**: Documentation / install surface (no app code yet, this repo ships a convention, not a product).
- **Files**: `README.md`, `QUICKSTART.md`, `SETUP.md`, `WORKSPACE_KNOWLEDGE.md`.
- **Cross-side wiring**: All four files reference the `.notes/` enforcement layer documented in BACKEND_NOTES.md entry of the same date.
- **Verification**: Files render correctly on GitHub. Install prompt in README.md works when handed to Claude Code along with the folder. Self-test passes after install (see BACKEND_NOTES.md).
- **Follow-ups**: Add a 90-second install video to README.md if the text-only install path filters out too many adopters. Consider adding an `examples/` directory with a worked Lovable+Supabase and Lovable-external-Supabase example once two adopters have tried it and surfaced common gotchas.

_Add new entries above this line._
