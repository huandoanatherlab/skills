#!/usr/bin/env bash
# Link ./claude/<skill> into ~/.claude/skills, ./codex/<skill> into ~/.codex/skills, and bin/agent-run into ~/.local/bin.
# Existing real dirs with the same name, and skills this set replaces, move to ~/.skills-backup/<time>/.
# Usage: ./install.sh [--dry-run]
set -eu
ROOT=$(cd "$(dirname "$0")" && pwd)
HOSTS=(claude codex) # each host gets its own set: ./<host> -> ~/.<host>/skills
REPLACED=(execute-plan-with-subagents executing-plans ask-cli-agents build-plan thermal-review-loop plan-review code-quality-review verify-plan-delivery writing-prd writing-tdd)
BACKUP=$HOME/.skills-backup/$(date +%Y%m%d-%H%M%S)
DRY=; [ "${1:-}" = --dry-run ] && DRY=echo

backup() { # $1 = path, $2 = host label
  $DRY mkdir -p "$BACKUP/$2"
  $DRY mv "$1" "$BACKUP/$2/"
  echo "backed up $1"
}

for label in "${HOSTS[@]}"; do
  host=$HOME/.$label/skills
  $DRY mkdir -p "$host"
  for name in "${REPLACED[@]}"; do
    t=$host/$name
    if [ -e "$t" ] || [ -L "$t" ]; then backup "$t" "$label"; fi
  done
  for src in "$ROOT"/$label/*/; do
    name=$(basename "$src"); t=$host/$name
    if [ -L "$t" ] && [ "$(readlink "$t")" = "${src%/}" ]; then echo "ok $t"; continue; fi
    if [ -e "$t" ] || [ -L "$t" ]; then backup "$t" "$label"; fi
    $DRY ln -s "${src%/}" "$t"
    echo "linked $t"
  done
done

BIN=$HOME/.local/bin/agent-run
$DRY mkdir -p "$HOME/.local/bin"
SRC=$ROOT/bin/agent-run
if { [ -e "$BIN" ] || [ -L "$BIN" ]; } && [ "$(readlink "$BIN")" != "$SRC" ]; then backup "$BIN" bin; fi
$DRY ln -sf "$SRC" "$BIN"
echo "linked ~/.local/bin/agent-run"
[ -z "$DRY" ] && [ -d "$BACKUP" ] && echo "backups in $BACKUP"
exit 0
