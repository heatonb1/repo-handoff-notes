# Quickstart — for people who haven't done this before

This guide assumes you can open a terminal and you know your repo lives on
GitHub. Nothing else. If you've ever followed a Lovable setup tutorial, you
already have enough skill to do this.

**Time to install:** about 5 minutes.
**Time to learn the daily workflow:** about 10 minutes.

---

## What this thing actually does (in one paragraph)

You're using Lovable for some things and Claude Code / Codex / Cursor for
others. They don't talk to each other. You write down what you did in two
notes files — `AI_NOTES.md` (frontend) and `BACKEND_NOTES.md` (backend) —
and the other side reads them next time. **This tool's only job is to stop
you from forgetting to write the notes.** It blocks your commits if you
changed code but didn't update the notes. That's it.

---

## Step 1 — Get the code

You have two options for getting the files onto your machine. Pick one:

**Option A — git clone (recommended if you have git already):**

```bash
git clone https://github.com/heatonb1/repo-handoff-notes /tmp/rhn
cp -r /tmp/rhn/.notes <your-project-root>/
cd <your-project-root>
```

Then skip to Step 2 (the installer).

**Option B — download the tarball:**

1. Download `notes-enforcement-v1.tar.gz` (the file someone shared with you, or grab the latest from the repo's Releases page).
2. Move it into the folder of your project on your computer. The folder
   that has `package.json` in it. That's your "repo root."
3. Open a terminal in that folder.
   - **Mac:** Right-click the folder in Finder → "New Terminal at Folder"
     (you may need to enable this in System Settings → Keyboard →
     Keyboard Shortcuts → Services → Files and Folders).
   - **Windows:** Shift + Right-click in the folder → "Open in Terminal"
     (or "Open PowerShell window here" on older Windows).
   - **VS Code / Cursor:** Open the folder, then go to Terminal → New Terminal.

4. In the terminal, type these two commands one at a time, pressing Enter
   after each:

   ```
   tar xzf notes-enforcement-v1.tar.gz
   bash .notes/install.sh
   ```

   You'll see a list of green checkmarks. That means it worked.

**Done.** Enforcement is now active in this repo.

---

## Step 2 — What just happened?

The installer added a hidden folder called `.notes/` to your project and
hooked up four things:

1. A **guard before each commit** that checks: did you update the right
   notes file? If no → commit is blocked with a clear message telling you
   what to do.
2. A **second guard** that checks your commit message has a `Notes:` line
   in it.
3. A **GitHub Actions workflow** that runs the same checks when Lovable
   pushes code (because Lovable doesn't have the local guards).
4. Two starter files (`AI_NOTES.md` and `BACKEND_NOTES.md`) if you didn't
   already have them.

You don't have to remember any of this. The system tells you what to do
when you mess up.

---

## Step 3 — The daily workflow

This is the only part you need to memorize. There are exactly 3 commands.

### When you (or Claude Code) change BACKEND code (migrations, edge functions, RLS):

In the terminal, run:

```
.notes/scripts/new-entry.sh backend "Short title of what you did"
```

Example:
```
.notes/scripts/new-entry.sh backend "Added refund ledger table"
```

This creates an entry in `BACKEND_NOTES.md`. Open the file in your editor,
find the new entry at the top, and fill in the "TODO" placeholders with
actual details (what files, how to verify, etc).

Then commit normally, but include a `Notes:` line in the commit message:

```
git add .
git commit -m "Add refund ledger

Notes: 2026-05-22 — Added refund ledger table"
```

(That blank line between the subject and the `Notes:` line matters. Git
treats them differently.)

### When you change FRONTEND code (React, components, pages):

Same thing, but `frontend` instead of `backend`:

```
.notes/scripts/new-entry.sh frontend "Updated billing page"
```

### When you want to see what's pending:

```
.notes/scripts/list-new.sh
```

This prints every `[STATUS: NEW]` entry across both files. It's your
"inbox" — what still needs the other side's attention.

**That's the entire workflow.** Three commands.

---

## Step 4 — When the guard blocks you

You'll see something like this in red text:

```
═══════════════════════════════════════════════════════════════════════
 Repo Handoff Notes v2 — enforcement failure
═══════════════════════════════════════════════════════════════════════
  ✗ Backend code changed but BACKEND_NOTES.md was not updated in the same commit.
```

**Don't panic.** This is the system doing its job. You forgot the notes.
Run the `new-entry.sh` command from Step 3, fill in the placeholders,
stage that file (`git add BACKEND_NOTES.md`), and commit again.

---

## Step 5 — The Lovable side

In Lovable, paste this into the chat after merging your backend work:

```
Check AI_NOTES.md and BACKEND_NOTES.md and act on any [STATUS: NEW]
entries. Flip each to [STATUS: PROCESSED] with a one-line result + your
commit short-hash. If you can't act on something, mark it
[STATUS: BLOCKED: <reason>] instead.
```

Lovable will read both files, do the work, and flip the statuses. When
Lovable pushes those changes to GitHub, the same GitHub Actions check
runs on Lovable's commits too. If Lovable forgot something, your PR will
show a red X.

---

## The "I just need to commit this RIGHT NOW" escape hatch

If you have a genuine emergency (prod is down, you need to ship a hotfix,
the notes can wait), put `NOTES_SKIP=1` in front of your git commit:

```
NOTES_SKIP=1 git commit -m "Hotfix the broken thing"
```

The local guards skip. **The GitHub Actions check still runs** when you
push, so your PR will show a red X until you backfill the notes. This is
intentional — you can move fast in the moment but the system remembers.

---

## What if I want to turn this OFF temporarily?

Open the file called `.notesrc` in your repo root (the installer created
it). Find this line:

```
# NOTES_MODE=strict
```

Uncomment it (delete the `#` and the space) and change `strict` to either:
- `warn` — prints the warning but lets the commit through
- `off` — does nothing at all

Save the file. To turn enforcement back on, put the `#` back or change
the value back to `strict`.

---

## Common confusions

**"What's a `[STATUS: NEW]` entry?"**
A note that says "I did this thing, the other side should look at it." It
sits in the file until the other side reads it and flips it to
`[STATUS: PROCESSED]` (meaning: handled, here's what I did, here's my
commit hash).

**"Why two files instead of one?"**
Because frontend changes and backend changes are usually owned by
different parties (or different tools), and reading "give me only what
applies to me" is easier when they're separated.

**"What if my change touches both?"**
Add an entry to the file that's *more relevant* (where the bigger change
happened) and add a one-line cross-reference in the other file pointing
to it. The system enforces that you update both files when both code
surfaces changed.

**"Do I need to know what RLS / edge functions / migrations are?"**
If you're using Supabase, you already do (or Lovable does). If you're
not, you can just delete the word "backend" from your mental model — the
system still works for any two-surface split.

**"What if I'm using Replit / Bolt / v0 / Cursor instead of Lovable?"**
Same idea, different names. Anywhere you have one tool writing code and
another tool reading it later, this works. Adjust the labels in
`BACKEND_NOTES.md` to whatever makes sense for you.

---

## When to ask for help

If you see an error message you don't understand:

1. Copy the entire error message.
2. Paste it into Claude (or whatever AI you use) with the question:
   "I'm using the Repo Handoff Notes v2 enforcement layer. I got this
   error when trying to commit: [paste]. What should I do?"

That'll usually unstick you. The error messages in this system are
designed to be self-explanatory, but if one isn't, that's a bug worth
reporting.

---

## What this does NOT replace

- A real PR review process (this is a substitute for *not having one*,
  which is the case for most solo Lovable builders).
- Actually reading the notes (the system makes you write them, not read
  them — that part is on you and Lovable).
- Writing good code (it only checks that you documented the change, not
  that the change is correct).

---

## TL;DR for the impatient

```
# One-time setup (5 minutes):
tar xzf notes-enforcement-v1.tar.gz
bash .notes/install.sh

# Every time you write backend code:
.notes/scripts/new-entry.sh backend "what you did"
# (fill in the TODOs in BACKEND_NOTES.md)
git add . && git commit -m "Subject line

Notes: $(date +%Y-%m-%d) — what you did"

# Every time you write frontend code:
.notes/scripts/new-entry.sh frontend "what you did"
# (same flow)

# Tell Lovable to process pending notes:
"check AI_NOTES.md and BACKEND_NOTES.md"
```

That's it. That's the whole thing.
