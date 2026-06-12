---
name: open-pr
description: Open a GitHub pull request with a body filled from the repo's PR template. Detects an existing PULL_REQUEST_TEMPLATE; if none exists, creates one (adapted from a known-good skeleton) and commits it in the PR. Fills the narrative from commits + diff, auto-checks only verifiable checklist items, derives the title from the branch, and always previews for confirmation before running gh pr create. Use when the user asks to "open a PR", "create a pull request", "raise a PR", or "make a PR".
---

# open-pr

Open a GitHub pull request whose body is filled from the repository's own PR template. If the repo has no template, create one first (adapted to this repo) and commit it as part of the PR. Always show the rendered PR content and get an explicit yes before `gh pr create`.

Invoking this skill **is** the request to open a PR. The only hard gate is the final preview-and-confirm before the PR is actually created.

## 1. Preconditions — branch, commits, push

This skill opens a PR for work that is **already committed**. It does not author code commits (that's `/commit`).

```bash
git branch --show-current
git status --porcelain
gh repo view --json defaultBranchRef -q .defaultBranchRef.name   # the base branch
git log --oneline <base>..HEAD                                   # commits to ship
```

- **On `main`/`master`, or no commits ahead of base** → stop. Tell the user to run `/commit` first. Do **not** create commits here.
- **Dirty tree** → note it; the uncommitted changes won't be in the PR. Offer `/commit`, but don't block if the user wants to PR what's committed.
- Confirm a remote exists (`git remote -v`). No remote → stop and report.

Push happens later (step 5), right before creating the PR — not yet.

## 2. Find the repo's PR template

GitHub recognizes these locations (case-insensitive, `.md`/`.markdown`/`.txt`):

```bash
ls .github/PULL_REQUEST_TEMPLATE.md \
   PULL_REQUEST_TEMPLATE.md \
   docs/PULL_REQUEST_TEMPLATE.md 2>/dev/null
ls .github/PULL_REQUEST_TEMPLATE/ 2>/dev/null   # directory = multiple templates
```

- **Exactly one template** → use it verbatim as the skeleton. Go to step 4.
- **Directory with multiple** → list them, ask the user which to use.
- **None** → create one (step 3).

## 3. No template — create one (adapted skeleton)

When the repo has no template, build `.github/PULL_REQUEST_TEMPLATE.md` from the skeleton below, **adapted to this repo**: read `README.md`, `CLAUDE.md`, `CONTRIBUTING.md`, the build/test setup, and recent PRs/commits to learn the repo's goal and conventions, then rewrite the checklist to match (test command, lint, docs surface, etc.). Keep it generic enough to fit every future PR — not specific to the current change.

Skeleton (from a known-good template; the section shape is fixed, the checklist is yours to adapt):

```markdown
**What does this PR resolve? 🚀**

<!-- One-line summary. Then bullets: the key changes and, briefly, the why. -->

**Details 📝**

<!-- Implementation specifics, trade-offs, anything a reviewer needs. -->

**Checklist ✅**

- [ ] Merged latest `<default-branch>` and resolved conflicts
- [ ] Changes are covered by tests or manually verified
- [ ] Docs updated where relevant
- [ ] Self-reviewed the diff
- [ ] PR title follows the repo's convention
```

Adapt the checklist to the repo — e.g. swap in the real test command, a lint/format gate, a changelog entry, or whatever recent PRs show contributors are expected to do. Drop items that don't apply. Keep boxes **unchecked** in the committed template (it's a blank for future PRs).

Then commit the template onto the current branch following the `commit` skill's conventions (Conventional Commits subject, bullet body, `-s` sign-off + `Co-Authored-By: Claude <model>` trailer):

```bash
git add .github/PULL_REQUEST_TEMPLATE.md
git commit -s -m "docs(github): add pull request template" -m "- add PULL_REQUEST_TEMPLATE.md with what/details/checklist sections
- checklist adapted to this repo's test and docs conventions

Co-Authored-By: Claude <model> <noreply@anthropic.com>"
```

This commit becomes part of the PR, so the template both ships in this PR and serves every future one.

## 4. Fill the PR body

Take the template (existing or just-created) and fill each section from the actual work — read the commits and diff:

```bash
git log <base>..HEAD --format='%s%n%b'
git diff <base>..HEAD --stat
git diff <base>..HEAD
```

- **What / why sections** → a concise summary plus bullets, grounded in the diff. Don't invent motivation that isn't supported by the changes; if the why isn't clear, ask the user one question.
- **Details** → implementation specifics, trade-offs, follow-ups.
- **Checklist** → **auto-check only boxes you can actually verify** from the repo/diff (e.g. tests exist and were added, docs were updated in this diff, title follows convention). Leave everything you cannot verify **unchecked**. In the preview, list which boxes you ticked and the evidence for each — never tick an item you can't back up.
- Preserve any extra template structure (comments-as-instructions become filled prose; HTML comments `<!-- -->` are dropped from the final body).

## 5. Title, then preview and confirm — the gate

**Title:** derive from the branch name (`git branch --show-current`) — e.g. `feat/open-pr-skill` → `feat: open pr skill`, normalizing the `type/slug` shape into a Conventional-Commits-style title. Show it in the preview so the user can edit it.

Show the user the **complete** PR before creating anything:

```
Base:   <base-branch>  ←  <head-branch>
Title:  <derived title>
Draft:  no            (say "draft" to change)

<full rendered PR body>

Auto-checked: <box> — <why>;  <box> — <why>
Left unchecked: <the rest>
```

**Wait for explicit confirmation.** If the user edits the title/body/checklist, apply and re-show. Only on a clear yes, proceed.

## 6. Push and create

```bash
git push -u origin <head-branch>     # set upstream if not already pushed
gh pr create --base <base> --title "<title>" --body "<body>"
# add --draft only if the user asked for a draft
```

- Pass the body via `--body-file` (write to a temp file) when it contains characters that fight the shell.
- On success, print the PR URL.
- If `gh` isn't authenticated, report the `gh auth login` step and stop — don't try to work around it.

## Guardrails

- **Never create the PR without showing the rendered content and getting a yes** — this is the one non-negotiable gate.
- Never check a checklist box you can't verify from the repo/diff.
- Don't author code commits — only the template commit (step 3) is in scope; everything else is `/commit`.
- Don't force-push, don't target a base the user didn't agree to, don't open against the wrong remote.
- Report failures honestly with the real `gh`/`git` output; never claim a PR was opened if it wasn't.
