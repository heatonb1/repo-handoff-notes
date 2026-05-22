# SETUP.md — Playbook for AI agents installing this layer

**Audience: Claude Code, Codex, Cursor agent, or any other coding agent.**
**Human users: this file is written for the agent. Read README.md instead.**

## Your job

Install this enforcement layer in the user's current repository, then
verify it works, then teach them the daily workflow. Be careful, ask
before destructive actions, and report status at each phase.

## Critical constraints

1. **Do not overwrite existing files without asking.** Specifically:
   - `AI_NOTES.md` / `BACKEND_NOTES.md` — if present, leave them alone.
   - `.git/hooks/pre-commit` / `commit-msg` — the installer chains
     these automatically. Tell the user this is happening.
   - `.github/workflows/notes-check.yml` — confirm before overwriting.
   - `.notesrc` — leave existing values alone.

2. **Stop and ask if the repo is non-standard.** Default path globs assume
   `src/` (frontend) and `supabase/` (backend). If the repo has a
   different layout (e.g. `apps/web/`, `apps/api/`, monorepo with
   workspaces), ask the user to confirm the right path prefixes before
   running the installer.

3. **Never commit on the user's behalf without confirming.** You may run
   the installer, copy files, and run the self-test (which doesn't make
   commits). But actual `git commit` to the user's repo requires
   explicit confirmation.

4. **Report what you did at each phase.** Print a short status line so
   the user can see progress.

---

## Phase 0 — Verify the user is ready

Before doing anything else, check:

```bash
git rev-parse --show-toplevel   # confirm we're in a git repo
git rev-parse --show-prefix     # confirm we're at the root (output should be empty)
git status --porcelain          # check for uncommitted changes
```

**If not in a git repo:** stop. Tell the user they need to run
`git init` first or `cd` into the right folder.

**If not at the root:** stop. Tell the user to `cd` to the repo root.

**If there are uncommitted changes:** warn the user. Suggest they commit
or stash first so the install is on a clean tree. Proceed only if they
confirm.

Then check whether the user actually needs this:

```bash
ls -la .notes 2>/dev/null      # is it already installed?
```

**If `.notes/` exists:** ask if they want to re-install (idempotent, safe)
or upgrade an existing install. Don't auto-replace.

---

## Phase 1 — Discover the user's setup

Gather information silently, then report a summary. Don't ask the user
things you can find out yourself.

```bash
# Frontend surface present?
ls src/ public/ 2>/dev/null

# Backend surface present?
ls supabase/ 2>/dev/null
ls supabase/migrations/ 2>/dev/null
ls supabase/functions/ 2>/dev/null
ls supabase/config.toml 2>/dev/null

# Existing notes files?
ls AI_NOTES.md BACKEND_NOTES.md 2>/dev/null

# Existing pre-commit / commit-msg hooks?
ls -la .git/hooks/pre-commit .git/hooks/commit-msg 2>/dev/null

# CI setup?
ls .github/workflows/ 2>/dev/null

# Package manager / framework hints (helps detect unusual layouts)
cat package.json 2>/dev/null | head -20
```

Then report a 3-6 line summary like:

```
Found:
  • Git repo at /Users/you/projects/myapp
  • Frontend: src/ (React, Vite)
  • Backend: supabase/ with migrations + functions
  • Notes files: AI_NOTES.md exists (1473 lines), BACKEND_NOTES.md exists (892 lines)
  • Existing hooks: none
  • Existing CI workflows: 2 (will add a third, won't conflict)
```

If the layout doesn't match defaults (no `src/` or no `supabase/`),
**ask before proceeding**:

> "Your repo doesn't have the standard Lovable + Supabase layout. I see
> `<actual paths>`. Should I treat `<X>` as frontend and `<Y>` as
> backend, or do you want a different split?"

---

## Phase 2 — Ask the minimum questions

Only ask things you can't infer. Bundle into one message, with sensible
defaults the user can accept by saying "ok":

> "I'll install in **strict mode** (fails commits that don't update
> notes). You can switch to `warn` or `off` anytime by editing `.notesrc`.
> 
> Two questions:
>
> 1. Strict mode now, or start with `warn` for the first week so you can
>    see what would have been blocked?
> 2. Should I add `.notesrc` to `.gitignore` (so each contributor can
>    customize locally) or commit it (so the whole team shares one config)?"

Wait for their response before continuing.

---

## Phase 2.5 — Get the source code (if you don't have it locally)

If the user pointed you at a GitHub URL (e.g. `https://github.com/heatonb1/repo-handoff-notes`)
instead of a local folder path, clone the source to a temp directory
first. This is the most common case when the user pastes the README's
Option A prompt.

```bash
git clone https://github.com/heatonb1/repo-handoff-notes /tmp/rhn-source
```

Treat `/tmp/rhn-source` as `<PATH-TO-NOTES-ENFORCEMENT-FOLDER>` for the
rest of the playbook. Tell the user where you cloned it so they can
clean it up later (or just leave it — it's small).

If the user pointed you at a local folder (e.g. `~/Downloads/notes-enforcement`),
skip this phase and use that path directly in Phase 3.

---

## Phase 3 — Install

Run these commands. Print each one before running so the user sees what's
happening:

```bash
# Copy the .notes/ directory into the repo
cp -r <PATH-TO-NOTES-ENFORCEMENT-FOLDER>/.notes ./

# Make scripts executable (should already be, but be defensive)
chmod +x .notes/hooks/* .notes/scripts/*.sh .notes/install.sh

# Run the installer
bash .notes/install.sh
```

**Expected output:** six green checkmarks. If anything errored, stop
and report the error to the user verbatim.

If the user chose `warn` mode in Phase 2, also do:

```bash
sed -i.bak 's|# NOTES_MODE=strict|NOTES_MODE=warn|' .notesrc && rm .notesrc.bak
```

(On macOS, `sed -i` requires the `.bak` argument. The command above
works cross-platform.)

If the user wanted `.notesrc` gitignored:

```bash
echo ".notesrc" >> .gitignore
```

---

## Phase 4 — Self-test

Run the self-test:

```bash
bash .notes/scripts/self-test.sh
```

**Expected:** all 4 scenarios pass. The script is non-destructive — it
simulates staged-file scenarios without actually creating commits or
modifying tracked files.

If any scenario fails, stop and report which one. Common causes:
- User's existing notes files contain `<TBD>` placeholders inside
  `[PROCESSED]` entries (this is real drift the system is correctly
  flagging — tell the user, don't silently fix it)
- Non-standard layout that the user didn't disclose in Phase 2
- Permission issue on scripts (re-run the `chmod` line)

---

## Phase 5 — First entry walkthrough

Now teach the user the daily workflow by creating their first entry
together. Pick the surface they're more likely to work on next based on
your earlier discovery (probably backend if you saw a `supabase/` folder
and they're working with you).

Tell them:

> "Let's create your first entry. Run this in the terminal — or want me
> to run it for you?
>
> ```
> .notes/scripts/new-entry.sh backend \"My first entry\"
> ```
>
> Then I'll show you what got created and how to fill it in."

Run the command (yourself if they confirm), then `cat BACKEND_NOTES.md`
to show the result. Walk them through:

- Where the entry sits (top of file, above `_Add new entries above this line._`)
- The stable ID in the HTML comment (`<!-- id: BN-YYYY-MM-DD-001 -->`)
- The TODO placeholders they fill in
- How to commit with a proper `Notes:` anchor

Show them a sample commit message they can copy:

```
Subject line describing the change

Notes: <today's date> — My first entry
Ref: BN-<today's date>-001
```

---

## Phase 6 — Lovable side prep

Give the user this prompt to paste into Lovable's chat after their next
merge:

> ```
> Check AI_NOTES.md and BACKEND_NOTES.md. For every [STATUS: NEW] entry:
> read it, do the work it asks for if possible, and flip it to
> [STATUS: PROCESSED] with a one-line result + your commit short-hash.
> If you can't act on something, mark it [STATUS: BLOCKED: <reason>]
> instead of skipping it. Don't edit existing [PROCESSED] entries.
> ```

Also tell them: add this to Lovable's Workspace Knowledge so it persists
across sessions. (The spec text for that is in the original convention
doc — point them to it if they don't have it.)

---

## Phase 7 — Final report

Print a final summary:

```
Setup complete.

Installed:
  • .notes/ directory with enforcement scripts
  • Git hooks (pre-commit, commit-msg) — runs on every commit
  • GitHub Actions workflow — runs on every PR
  • .notesrc with NOTES_MODE=<strict|warn>
  • AI_NOTES.md and/or BACKEND_NOTES.md (if missing)

Daily workflow:
  • Make a code change
  • .notes/scripts/new-entry.sh <frontend|backend> "title"
  • Fill in the TODOs in the notes file
  • Commit with: Notes: YYYY-MM-DD — title  (in the commit body)
  • Push. CI will verify on the PR.

Inbox view (see what's still pending):
  .notes/scripts/list-new.sh

Emergency bypass (local only, CI still catches):
  NOTES_SKIP=1 git commit ...

Disable temporarily:
  Edit .notesrc, set NOTES_MODE=off

Lovable side: paste the prompt from Phase 6 after your next merge.
```

---

## When you should bail out and ask for help

- The user's repo layout is fundamentally non-standard (e.g. notes files
  in a subdirectory, multiple frontends, monorepo with workspaces) and
  the path globs would need substantial reconfiguration.
- The self-test fails for a reason you can't identify from the error.
- The user has existing git hooks managed by a tool you don't recognize
  (e.g. `husky`, `lefthook`, `pre-commit` framework) — the installer
  chains them but the interaction may need user input.
- The user reports the install seemed to work but their first real
  commit isn't being checked. Investigate before assuming it's working.

In any of these cases: stop, summarize what you've done so far, and ask
the user what they want to do next. Don't keep going.

---

## Notes on MCPs

If the user has the **GitHub MCP** installed, you can additionally:
- Create a draft PR after install to test that the Actions workflow runs
- Check the Actions tab on their last few PRs to see if `notes-check`
  is passing

If they have the **Supabase MCP** installed:
- Verify their Supabase project is reachable (sanity check, not strictly
  needed for the install)

Neither is required. Don't make the install depend on them.
