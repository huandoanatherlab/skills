#!/usr/bin/env bash
# The skills are one Claude Code plugin (./claude) that T3 Code loads with --plugin-dir, so nothing goes into
# ~/.claude/skills or ~/.codex/skills. This script removes links an older install made there (and skills this
# set replaced), moving them to ~/.skills-backup/<time>/, links bin/agent-run into ~/.local/bin, and prints the
# T3 setting to make.
# Usage: ./install.sh [--dry-run]
set -eu
ROOT=$(cd "$(dirname "$0")" && pwd)
HOSTS=(claude codex) # ~/.<host>/skills held links from older installs
REPLACED=(execute-plan-with-subagents executing-plans ask-cli-agents build-plan thermal-review-loop plan-review code-quality-review verify-plan-delivery writing-prd writing-tdd)
BACKUP=$HOME/.skills-backup/$(date +%Y%m%d-%H%M%S)
DRY=; [ "${1:-}" = --dry-run ] && DRY=echo

backup() { # $1 = path, $2 = host label
  $DRY mkdir -p "$BACKUP/$2"
  $DRY mv "$1" "$BACKUP/$2/"
  echo "removed $1 (backup in $BACKUP/$2)"
}

for label in "${HOSTS[@]}"; do
  host=$HOME/.$label/skills
  [ -d "$host" ] || continue
  for name in "${REPLACED[@]}"; do
    t=$host/$name
    if [ -e "$t" ] || [ -L "$t" ]; then backup "$t" "$label"; fi
  done
  for t in "$host"/*; do
    [ -L "$t" ] || continue
    case "$(readlink "$t")" in "$ROOT"/*) backup "$t" "$label" ;; esac
  done
done

BIN=$HOME/.local/bin/agent-run
$DRY mkdir -p "$HOME/.local/bin"
SRC=$ROOT/bin/agent-run
if { [ -e "$BIN" ] || [ -L "$BIN" ]; } && [ "$(readlink "$BIN")" != "$SRC" ]; then backup "$BIN" bin; fi
$DRY ln -sf "$SRC" "$BIN"
echo "linked ~/.local/bin/agent-run"

PLUGIN=$ROOT/claude
command -v cygpath >/dev/null 2>&1 && PLUGIN=$(cygpath -w "$PLUGIN")
cat <<EOF

T3 Code: Settings > Providers > Claude > Launch arguments:
  --plugin-dir $PLUGIN
New T3 threads then list the skills as ath:<name>. Claude Desktop, Cowork and plain claude do not load them.
EOF
exit 0
