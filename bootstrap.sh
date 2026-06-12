#!/usr/bin/env bash
# Symlink every skill in this repo into ~/.claude/skills/ so Claude Code
# discovers them. Idempotent — safe to re-run after `git pull` or adding skills.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEST="$HOME/.claude/skills"
mkdir -p "$DEST"

for dir in "$REPO_DIR"/skills/*/; do
  name="$(basename "$dir")"
  ln -sfn "${dir%/}" "$DEST/$name"
  echo "linked $name -> $DEST/$name"
done
