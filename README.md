# Repo Handoff Notes v2 — Enforcement Layer

You're looking at this README because (a) you landed on the GitHub repo,
or (b) someone handed you a folder. Either way, here's what to do.

If you landed on GitHub and want the files locally, clone:

```bash
git clone https://github.com/heatonb1/repo-handoff-notes
cd repo-handoff-notes
```

Now `<PATH-TO-THIS-FOLDER>` in any instructions below = your local
`repo-handoff-notes` directory.

## What this is

A drop-in enforcement layer for the Repo Handoff Notes v2 convention
(the AI_NOTES.md / BACKEND_NOTES.md pattern for keeping Lovable and Claude
Code in sync). It stops you from committing code without updating the
matching notes file, and runs the same check in CI so Lovable can't
forget either.

## How to install it

You have three options, in order of preference:

### Option A — Tell Claude Code or Codex to do it (recommended)

1. Put this folder anywhere on your machine.
2. Open Claude Code (or Codex) in your project's root folder.
3. Paste this prompt:

```
I have a folder at <PATH-TO-THIS-FOLDER>. It contains an enforcement
layer for the Repo Handoff Notes v2 convention. Read its SETUP.md and
walk me through installing it in this repo. Ask me anything you need to
know, run the commands yourself where you can, and tell me exactly what
to paste if you need me to run something. Verify it worked at the end.
```

Replace `<PATH-TO-THIS-FOLDER>` with the actual path (e.g.
`~/Downloads/notes-enforcement` or wherever you unzipped it).

Claude Code will inspect your repo, ask 2-3 questions, run the installer,
and run a self-test to confirm it works. About 5 minutes total.

### Option B — Install it yourself

You're comfortable with a terminal. Open one in your repo root and:

```
cp -r <PATH-TO-THIS-FOLDER>/.notes ./
bash .notes/install.sh
bash .notes/scripts/self-test.sh
```

If all three commands print green checkmarks, you're done. Read
`QUICKSTART.md` for the daily workflow.

### Option C — Manual install with the QUICKSTART

If you prefer step-by-step instructions written for humans rather than
agents, open `QUICKSTART.md`. Same end result, more reading.

## Files in this folder

| File | What it's for |
|---|---|
| `README.md` | What you're reading. |
| `SETUP.md` | Playbook for Claude Code / Codex. Don't read this unless you're an AI agent — it's written for you. |
| `QUICKSTART.md` | Human-readable install + daily workflow guide. |
| `.notes/` | The actual enforcement layer. Gets copied into your repo by the installer. |
| `.notes/README.md` | Reference docs for the .notes/ layer once installed. |

## Before you start, you need

- A git repo on your machine (somewhere with a `.git/` folder in it).
- A terminal you can open in that folder.
- Optionally: GitHub MCP installed in Claude Code (lets Claude Code do
  more autonomously — push branches, check Actions runs).
- Optionally: Supabase MCP (if you're using Supabase as your backend).

Neither MCP is required. They just let Claude Code do more of the work
without copy-pasting.

## License

Use it. Modify it. Share it. No warranty.
