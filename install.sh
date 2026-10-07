#!/usr/bin/env bash
# Link every skill in ./skills into Claude Code and Codex, and agent-run into ~/.local/bin.
# Existing real dirs with the same name, and skills this set replaces, move to ~/.skills-backup/<time>/.
# Usage: ./install.sh [--dry-run]
set -eu
ROOT=$(cd "$(dirname "$0")" && pwd)
HOSTS=("$HOME/.claude/skills" "$HOME/.codex/skills")
REPLACED=(execute-plan-with-subagents executing-plans ask-cli-agents)
BACKUP=$HOME/.skills-backup/$(date +%Y%m%d-%H%M%S)
DRY=; [ "${1:-}" = --dry-run ] && DRY=echo

backup() { # $1 = path, $2 = host label
  $DRY mkdir -p "$BACKUP/$2"
  $DRY mv "$1" "$BACKUP/$2/"
  echo "backed up $1"
}

for host in "${HOSTS[@]}"; do
  [ -d "$host" ] || { echo "skip $host (missing)"; continue; }
  label=$(basename "$(dirname "$host")")
  for name in "${REPLACED[@]}"; do
    t=$host/$name
    if [ -L "$t" ]; then $DRY rm "$t"; echo "removed link $t"
    elif [ -e "$t" ]; then backup "$t" "$label"; fi
  done
  for src in "$ROOT"/skills/*/; do
    name=$(basename "$src"); t=$host/$name
    if [ -L "$t" ]; then $DRY rm "$t"
    elif [ -e "$t" ]; then backup "$t" "$label"; fi
    $DRY ln -s "${src%/}" "$t"
    echo "linked $t"
  done
done

$DRY mkdir -p "$HOME/.local/bin"
$DRY ln -sf "$ROOT/skills/agent-run/scripts/agent-run" "$HOME/.local/bin/agent-run"
echo "linked ~/.local/bin/agent-run"
[ -z "$DRY" ] && [ -d "$BACKUP" ] && echo "backups in $BACKUP"
exit 0
