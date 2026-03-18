#!/bin/bash
# bootstrap.sh — Set up Claude Code workflow on a fresh machine
# Idempotent: safe to run multiple times

set -e

ICLOUD="/Users/$USER/Library/Mobile Documents/com~apple~CloudDocs/claude-memory"
PROJECTS="/Users/$USER/.claude/projects"

log() { echo "[bootstrap] $*"; }
ok()  { echo "[  OK  ] $*"; }
skip(){ echo "[ SKIP ] $*"; }

# ────────────────────────────────────────────────────────────────
# 1. Check prerequisites
# ────────────────────────────────────────────────────────────────
log "Checking prerequisites..."

if ! command -v brew >/dev/null 2>&1; then
  echo "ERROR: Homebrew not found. Install it first:"
  echo '  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
  exit 1
fi
ok "Homebrew found"

# ────────────────────────────────────────────────────────────────
# 2. Install CLI tools
# ────────────────────────────────────────────────────────────────
log "Installing CLI tools..."

BREW_TOOLS=(ripgrep fd ast-grep)
for tool in "${BREW_TOOLS[@]}"; do
  if brew list "$tool" >/dev/null 2>&1; then
    skip "$tool already installed"
  else
    log "Installing $tool..."
    brew install "$tool"
    ok "$tool installed"
  fi
done

# trash-cli is macOS-native trash command
if command -v trash >/dev/null 2>&1; then
  skip "trash already installed"
else
  log "Installing trash..."
  brew install trash-cli 2>/dev/null || brew install --cask trash 2>/dev/null || npm install -g trash-cli
  ok "trash installed"
fi

# ────────────────────────────────────────────────────────────────
# 3. Install Claude Code
# ────────────────────────────────────────────────────────────────
log "Checking Claude Code..."

if command -v claude >/dev/null 2>&1; then
  skip "Claude Code already installed ($(claude --version 2>/dev/null | head -1))"
else
  log "Installing Claude Code..."
  npm install -g @anthropic-ai/claude-code
  ok "Claude Code installed"
fi

# ────────────────────────────────────────────────────────────────
# 4. Create required directories
# ────────────────────────────────────────────────────────────────
log "Creating required directories..."

for dir in "$HOME/.claude/projects" "$HOME/.claude/plans" "$HOME/.claude/sessions"; do
  mkdir -p "$dir"
  ok "Directory: $dir"
done

# ────────────────────────────────────────────────────────────────
# 5. Set up iCloud memory symlinks
# ────────────────────────────────────────────────────────────────
log "Setting up iCloud memory symlinks..."

if [ ! -d "$ICLOUD" ]; then
  log "WARNING: iCloud claude-memory directory not found at:"
  log "  $ICLOUD"
  log "Make sure iCloud Drive is signed in and synced, then re-run."
else
  for proj_dir in "$ICLOUD"/*/; do
    proj=$(basename "$proj_dir")
    local_proj="$PROJECTS/$proj"
    local_memory="$local_proj/memory"

    mkdir -p "$local_proj"

    if [ -L "$local_memory" ]; then
      skip "Symlink exists: $proj/memory"
    elif [ -d "$local_memory" ]; then
      log "WARNING: $local_memory is a real directory, not a symlink. Skipping."
    else
      ln -s "$proj_dir" "$local_memory"
      ok "Linked: $proj/memory -> iCloud"
    fi
  done
fi

# ────────────────────────────────────────────────────────────────
# 6. Shell aliases
# ────────────────────────────────────────────────────────────────
echo ""
echo "────────────────────────────────────────────────────────────"
echo "  Add this line to your ~/.zshrc or ~/.bashrc:"
echo ""
echo '    source ~/.claude/aliases.sh'
echo ""

# ────────────────────────────────────────────────────────────────
# 7. Manual steps checklist
# ────────────────────────────────────────────────────────────────
echo "  Manual steps remaining:"
echo ""
echo "  [ ] Set Anthropic API key:"
echo '        export ANTHROPIC_API_KEY="your-key-here"  # add to ~/.zshrc'
echo "        or: claude login"
echo ""
echo "  [ ] Set up SSH keys for GitHub/Bitbucket repo access"
echo "        (copy ~/.ssh/ from old machine or generate new keys)"
echo ""
echo "  [ ] Install Xcode from the App Store"
echo ""
echo "  [ ] Clone project repos:"
echo "        mkdir -p ~/Work && cd ~/Work"
echo "        git clone git@bitbucket.org:bitazza/btz-ios-refacter-fresh.git"
echo ""
echo "  [ ] Run claude once to trigger plugin auto-installation:"
echo "        cd ~/Work/btz-ios-refacter-fresh && claude"
echo ""
echo "────────────────────────────────────────────────────────────"
echo "  Bootstrap complete!"
