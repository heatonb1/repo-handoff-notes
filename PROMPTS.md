# PROMPTS.md

Copy-paste prompts for talking to your AI tool (Lovable, Bolt, Cursor, v0,
Claude Code, Codex, etc.) about the Repo Handoff Notes v2 convention.

These assume you have pasted `WORKSPACE_KNOWLEDGE.md` into your AI tool's
Workspace Knowledge (Lovable), system prompt (Cursor), or equivalent.
If you haven't, the verbose versions at the bottom work without setup.

---

## Daily use (Workspace Knowledge loaded)

After merging your work, paste one of these into your AI tool's chat:

```
check both
```

That's it. The trigger phrase is defined in the Workspace Knowledge.
The AI will read AI_NOTES.md and BACKEND_NOTES.md, process every NEW
entry, flip them to PROCESSED with commit hashes, and surface anything
that spans both surfaces.

Other shortcuts:

```
check AI_NOTES.md
```

```
check BACKEND_NOTES.md
```

---

## First-time onboarding (point your AI at a fresh repo)

Paste this once when you start a new session in a repo with the
enforcement layer already installed:

```
This repo has the Repo Handoff Notes v2 enforcement layer installed
at `.notes/`. Before you make any changes, read `.notes/README.md`,
then read AI_NOTES.md and BACKEND_NOTES.md so you know the current
state of the handoff. Report any [STATUS: NEW] entries that need
action. Confirm you understand the same-commit rule (commits touching
code MUST also touch the matching notes file) and that GitHub Actions
will fail your PR if violated. After that, wait for my first task.
```

---

## Installing the enforcement layer in a fresh repo (hand to Claude Code or Codex)

### Option 1 — Point at the GitHub URL (no download needed)

Paste this into Claude Code or Codex while open in your project's root:

```
I want to install the Repo Handoff Notes v2 enforcement layer in this
repo (my current working directory).

Source: https://github.com/heatonb1/repo-handoff-notes

Clone it to a temp folder (e.g. /tmp/rhn-source) so you have the source
files locally, then read /tmp/rhn-source/SETUP.md and follow it
end-to-end to install the .notes/ layer in my current directory.

Ask me anything you need before destructive operations. Run commands
yourself where you can. Tell me exactly what to paste if you need me
to run something (especially anything that goes into Lovable's chat
window, since you can't reach Lovable directly). Verify with the
self-test at the end.
```

### Option 2 — Local folder (you already have the source)

If you have the `notes-enforcement` folder downloaded somewhere, paste
this into Claude Code or Codex in your project's root directory:

```
I have a folder at <PATH-TO-FOLDER>. It contains an enforcement layer
for the Repo Handoff Notes v2 convention. Read its SETUP.md and walk
me through installing it in this repo. Ask me anything you need to
know, run the commands yourself where you can, and tell me exactly
what to paste if you need me to run something. Verify it worked at
the end.
```

Replace `<PATH-TO-FOLDER>` with the actual path on your machine.

---

## Verbose versions (Workspace Knowledge NOT loaded)

Use these if you haven't pasted `WORKSPACE_KNOWLEDGE.md` anywhere yet,
or in a one-off chat where the AI doesn't have the convention loaded.

### Daily check (verbose)

```
Read AI_NOTES.md and BACKEND_NOTES.md at the repo root. For every
entry tagged [STATUS: NEW]: act on it, then flip to [STATUS: PROCESSED]
with a one-line result plus your actual commit short-hash (not <TBD>).
If you can't action something, mark it [STATUS: BLOCKED: <reason>]
instead of skipping silently. Don't edit existing [PROCESSED] entries.
Your commit body must include a line: `Notes: <today's date> — <title>`
matching one of the entries you processed.
```

### Inbox query (just show me what's pending, don't act)

```
List every [STATUS: NEW] and [STATUS: BLOCKED: ...] entry across
AI_NOTES.md and BACKEND_NOTES.md. Just titles and which file. Don't
act on anything yet.
```

### When your AI shipped something and needs to log it itself

```
You just shipped <describe what you did>. Add a [STATUS: NEW] entry
to the appropriate notes file (AI_NOTES.md for frontend, BACKEND_NOTES.md
for backend, both with a cross-ref stub if cross-cutting). Include a
stable ID comment like <!-- id: BN-<date>-NNN -->. The entry must
land in the same commit as the code. Commit body needs:
`Notes: <date> — <title>`.
```
