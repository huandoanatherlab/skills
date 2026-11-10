#!/usr/bin/env bash
# Install the ath-* skills for every agent on this machine:
#   skills/ath-*            -> ~/.claude/skills/ (Claude Code) and ~/.agents/skills/ (Codex and other agents)
#   skills/ath-execute/roles/{builder,reviewer,scout}.md -> ~/.claude/agents/ath-<role>.md
# Symlinks, so edits in this repo are live. Where symlinks are unavailable (Windows without Developer Mode),
# copies instead: re-run after every change. Also removes links an older install left behind.
# Usage: ./install.sh [--dry-run] [--copy]
set -eu
ROOT=$(cd "$(dirname "$0")" && pwd)
DRY= COPY=
for a in "$@"; do case "$a" in --dry-run) DRY=echo ;; --copy) COPY=1 ;; *) echo "unknown $a" >&2; exit 1 ;; esac; done
case "$(uname -s)" in MINGW*|MSYS*|CYGWIN*) export MSYS=winsymlinks:nativestrict ;; esac

place() { # place SRC DEST
  src=$1 dest=$2
  if [ -L "$dest" ]; then
    [ "$(readlink "$dest")" = "$src" ] && { echo "ok      $dest"; return; }
    $DRY rm "$dest"
  elif [ -e "$dest" ]; then
    if [ -f "$dest/.ath-copy" ] || [ -f "$dest.ath-copy" ]; then $DRY rm -rf "$dest" "$dest.ath-copy"
    else echo "skip    $dest exists and is not ours; move it away and re-run" >&2; return; fi
  fi
  if [ -z "$COPY" ] && $DRY ln -s "$src" "$dest" 2>/dev/null && { [ -n "$DRY" ] || [ -L "$dest" ]; }; then
    echo "linked  $dest"
  else
    [ -n "$DRY" ] || rm -rf "$dest"
    $DRY cp -R "$src" "$dest"
    if [ -d "$src" ]; then $DRY touch "$dest/.ath-copy"; else $DRY touch "$dest.ath-copy"; fi
    echo "copied  $dest"
  fi
}

chmod +x "$ROOT"/skills/*/scripts/* 2>/dev/null || true

for base in "$HOME/.claude/skills" "$HOME/.agents/skills"; do
  $DRY mkdir -p "$base"
  # drop links into this repo that no longer point at a current skill (older installs)
  for t in "$base"/*; do
    [ -L "$t" ] || continue
    case "$(readlink "$t")" in "$ROOT"/*) [ -e "$t" ] && [ -e "$ROOT/skills/$(basename "$t")" ] || { $DRY rm "$t"; echo "removed $t (stale)"; } ;; esac
  done
  for s in "$ROOT"/skills/ath-*; do place "$s" "$base/$(basename "$s")"; done
done

$DRY mkdir -p "$HOME/.claude/agents"
for r in builder reviewer scout; do
  place "$ROOT/skills/ath-execute/roles/$r.md" "$HOME/.claude/agents/ath-$r.md"
done

OLD=$HOME/.local/bin/agent-run
if [ -L "$OLD" ]; then case "$(readlink "$OLD")" in "$ROOT"/*) $DRY rm "$OLD"; echo "removed $OLD" ;; esac; fi

cat <<MSG

Done. Also:
1. T3 Code: remove "--plugin-dir .../claude" from Settings > Providers > Claude > Launch arguments.
2. ~/.claude/settings.json: "worktree": { "baseRef": "head" }  (parallel builders branch from the plan's HEAD)
3. Needs on PATH: git, node (status script), lsof (cleanup process scan), gh (PRs).
MSG
