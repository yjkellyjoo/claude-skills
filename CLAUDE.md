# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

The user's personal collection of [Claude Code](https://claude.com/claude-code) skills, version-controlled in one repo so they follow them across machines. These are **plain skills-dir skills**, not a plugin or marketplace. There is no build step, no test suite, and no application code — each skill is a `SKILL.md` document of instructions that Claude Code loads and follows.

## Architecture

- `skills/<name>/SKILL.md` — one directory per skill. The `SKILL.md` has YAML frontmatter (`name`, `description`) followed by markdown instructions. The `description` is what Claude matches against to decide when to auto-invoke the skill, and the `name` is what the user types (e.g. `/commit`). Skills are invoked, not executed — there is no runtime; Claude reads and acts on the prose.
- `bootstrap.sh` — symlinks every `skills/*/` directory into `~/.claude/skills/` (via `ln -sfn`). Idempotent. Because it links rather than copies, a `git pull` makes edits live immediately; re-run `bootstrap.sh` only after **adding** a new skill directory.

## Common tasks

Adding a skill:
1. Create `skills/<name>/SKILL.md` with `name` + `description` frontmatter and instructions.
2. Run `./bootstrap.sh` to symlink it into `~/.claude/skills/`.
3. Commit it (the `commit` skill exists for exactly this).

## Conventions

- Commits in this repo follow the rules in `skills/commit/SKILL.md`: Conventional Commits subject (`type(scope): subject`), bullet-point body, and `Signed-off-by` + `Co-Authored-By: Claude <model>` trailers. The `<model>` is the model currently running, not a fixed string. Branch off `main` with a `type/short-slug` name when committing from `main`.
- When writing a `SKILL.md`, the `description` should enumerate concrete trigger phrases — that text is the sole signal for auto-invocation, so be specific about when the skill applies.
