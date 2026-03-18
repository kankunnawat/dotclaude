#!/bin/bash
# Two-line statusline
#
# Line 1: folder  git-branch(dirty?)
# Line 2: model  tokens(used/total)  context-remaining%
#
# Token counts use context_window.current_usage.input_tokens (current context)
# and context_window.context_window_size (model limit).
# Note: session cost is not exposed in the Claude Code statusLine JSON schema.

# Read stdin (Claude Code passes JSON data via stdin)
stdin_data=$(cat)

# Extract all values in a single jq call
IFS=$'\t' read -r current_dir model_name ctx_remaining tokens_used tokens_total < <(
    echo "$stdin_data" | jq -r '[
        .workspace.current_dir // .cwd // "unknown",
        .model.display_name // "Unknown",
        (try (
            if (.context_window.remaining_percentage // null) != null then
                (.context_window.remaining_percentage | floor | tostring) + "%"
            else "?" end
        ) catch "?"),
        ((.context_window.current_usage.input_tokens // 0) | tostring),
        ((.context_window.context_window_size // 0) | tostring)
    ] | @tsv'
)

# Fallback if jq failed entirely
: "${current_dir:=unknown}"
: "${model_name:=Unknown}"
: "${ctx_remaining:=?}"
: "${tokens_used:=0}"
: "${tokens_total:=0}"

# --- Folder (basename of cwd) ---
folder_name=$(basename "$current_dir")

# --- Git branch + dirty indicator ---
git_branch=""
git_dirty=""
if cd "$current_dir" 2>/dev/null; then
    git_branch=$(git -c core.useBuiltinFSMonitor=false branch --show-current 2>/dev/null)
    if [ -n "$git_branch" ]; then
        if ! git -c core.useBuiltinFSMonitor=false diff --quiet HEAD 2>/dev/null || \
           [ -n "$(git -c core.useBuiltinFSMonitor=false ls-files --others --exclude-standard 2>/dev/null)" ]; then
            git_dirty="*"
        fi
    fi
fi

# --- Human-readable token counts (e.g. 12k / 200k) ---
human_k() {
    local n=$1
    if [ "$n" -ge 1000 ] 2>/dev/null; then
        printf "%dk" $(( n / 1000 ))
    else
        printf "%d" "$n"
    fi
}
tokens_display="$(human_k "$tokens_used")/$(human_k "$tokens_total")"

# --- Short model name ---
short_model=$(echo "$model_name" | sed -E 's/^Claude ([0-9.]+ )?//')

# --- Colors & separator ---
DIM='\033[2m'
RESET='\033[0m'
CYAN='\033[96m'
BLUE='\033[94m'
GREEN='\033[92m'
YELLOW='\033[93m'
SEP="${DIM}│${RESET}"

# --- LINE 1: 📁 folder  ⎇ branch(*) ---
line1=$(printf "${BLUE}%s${RESET}" "$folder_name")

if [ -n "$git_branch" ]; then
    branch_display="${git_branch}${git_dirty}"
    if [ -n "$git_dirty" ]; then
        line1="$line1 $(printf '%b' "$SEP") $(printf "${YELLOW}⎇ %s${RESET}" "$branch_display")"
    else
        line1="$line1 $(printf '%b' "$SEP") $(printf "${GREEN}⎇ %s${RESET}" "$branch_display")"
    fi
fi

# --- LINE 2: ◈ model  tokens used/total  ◷ ctx-remaining% ---
line2=$(printf "${DIM}◈ %s${RESET}" "$short_model")
line2="$line2 $(printf '%b' "$SEP") $(printf "${DIM}%s${RESET}" "$tokens_display")"
line2="$line2 $(printf '%b' "$SEP") $(printf "${CYAN}◷ %s${RESET}" "$ctx_remaining")"

printf '%b\n%b' "$line1" "$line2"
