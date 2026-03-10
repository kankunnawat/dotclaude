# Claude Code context-specific aliases
# Source this from ~/.zshrc: source ~/.claude/aliases.sh

alias claude-ios='claude --system-prompt "$(cat ~/.claude/contexts/ios-dev.md)"'
alias claude-web='claude --system-prompt "$(cat ~/.claude/contexts/web-dev.md)"'
