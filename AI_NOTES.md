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
