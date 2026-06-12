# claude-skills

My personal [Claude Code](https://claude.com/claude-code) skills, kept in one repo so they follow me across machines.

These are plain skills-dir skills — not a plugin or marketplace. `bootstrap.sh` symlinks each skill into `~/.claude/skills/`, so they're invoked with short names (e.g. `/commit`) and update with a `git pull`.

## Setup on a new machine

```bash
git clone https://github.com/yjkellyjoo/claude-skills.git
cd claude-skills
./bootstrap.sh
```

That symlinks every skill into `~/.claude/skills/`. Restart Claude Code (or start a new session) and the skills are available.

## Updating

```bash
git pull
```

The symlinks point at this clone, so pulled changes are live immediately. Run `./bootstrap.sh` again only after **adding** a new skill (to link the new directory).

## Adding a skill

1. Create `skills/<name>/SKILL.md` with frontmatter (`name`, `description`) and instructions.
2. Run `./bootstrap.sh` to link it.
3. Commit it (use `/commit`).

## Skills

| Skill | Invoke | What it does |
|-------|--------|--------------|
| commit | `/commit` | Split the working tree into small, feature-by-feature commits with Conventional Commits subjects, bullet bodies, and Signed-off-by + Co-Authored-By trailers. Auto-branches off the default branch when needed. |

## License

[MIT](./LICENSE)
