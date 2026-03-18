#!/bin/bash
# sync.sh — Sync Claude Code configs between machines via Git
# iCloud memory syncs automatically — no action needed for that
#
# Usage:
#   sync.sh push    — commit all config changes and push to GitHub
#   sync.sh pull    — pull latest configs from GitHub

set -e

CLAUDE_DIR="$HOME/.claude"
cd "$CLAUDE_DIR"

case "${1:-}" in
  push)
    if git diff --quiet && git diff --cached --quiet && [ -z "$(git ls-files --others --exclude-standard)" ]; then
      echo "Nothing to sync — working tree is clean."
    else
      git add -A
      git commit -m "sync: $(date '+%Y-%m-%d %H:%M')"
      git push
      echo "Configs pushed to GitHub."
    fi
    ;;

  pull)
    git pull --rebase
    echo "Configs updated from GitHub."
    ;;

  *)
    echo "Usage: sync.sh [push|pull]"
    echo ""
    echo "  push  — commit and push config changes to GitHub"
    echo "  pull  — pull latest configs from GitHub"
    echo ""
    echo "Note: Project memory (MEMORY.md files) syncs automatically via iCloud."
    exit 1
    ;;
esac
