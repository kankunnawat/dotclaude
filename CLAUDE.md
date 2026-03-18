# Global Claude Code Instructions

Global defaults. Project-specific CLAUDE.md files override these.

## Workflow

### Plan first, then execute

Start every complex task in plan mode. Invest heavily in the plan — a good plan lets Claude one-shot the implementation. For high-stakes changes, have a second Claude session review the plan as a staff engineer before executing.

### Parallel worktrees are the biggest unlock

Spin up 3-5 git worktrees, each running its own Claude session in parallel. Each subagent MUST work in its own worktree (`wt switch <branch>`), never the main repo. Use `use subagents` in prompts when you need more compute.

### Self-improving instructions

After every correction, update the relevant CLAUDE.md so the mistake doesn't repeat. Claude writes rules for itself — let it. This file should grow organically from real corrections, not from templates.

### Skills and automation

Use skills proactively when they match the task. If something happens more than once a day, turn it into a skill or slash command. Commit skills to git so they persist across machines.

### Specs reduce ambiguity

Write detailed specs before implementation. Challenge the output — "grill me on these changes and don't make a PR until I pass your test." Vague prompts produce vague code.

### Session continuity

When context compression occurs, re-read the project's task tracking file (e.g., `resume-state.md`) immediately — don't continue from memory alone. Log meaningful decisions to a progress file as they happen, not at session end.

### Multi-machine sync

Configs live in a private GitHub repo (`dotclaude`). Project memory syncs via iCloud.

- **Before switching machines:** `~/.claude/sync.sh push`
- **After switching machines:** `~/.claude/sync.sh pull`
- **Project memory** (`MEMORY.md` files) — no action needed, iCloud syncs automatically
- **New machine setup:** `git clone git@github.com:kankunnawat/dotclaude.git ~/.claude && ~/.claude/bootstrap.sh`

### Obsidian Vault

- Vault path: `/Users/bitazza/Documents/Obsidian Vault/`
- At session start, read `Context/dashboard.md` via `mcp__obsidian__read_note` for cross-project orientation
- After significant sessions, suggest `/save-to-vault` to capture knowledge
- Never scan the full vault automatically — read specific notes only when asked

## Philosophy

- **No speculative features** — Don't add features, flags, or configuration unless actively needed
- **No premature abstraction** — Don't create utilities until you've written the same code three times
- **Clarity over cleverness** — Prefer explicit, readable code over dense one-liners
- **Bias toward action** — Decide and move for anything easily reversed; state your assumption. Ask before committing to interfaces, data models, architecture, or destructive operations
- **Finish the job** — Handle edge cases you can see. Clean up what you touched. Flag adjacent breakage. But don't invent new scope
- **Replace, don't deprecate** — Remove old implementations entirely. No backward-compatible shims or migration paths. Flag dead code
- **Agent-native by default** — Design so agents can achieve any outcome users can. Prefer file-based state for transparency

## Code Quality

- Zero warnings from all tools — linters, type checkers, compilers, tests. Inline ignore with justification if truly unfixable
- Code should be self-documenting. No commented-out code — delete it
- Fail fast with clear, actionable error messages. Never swallow exceptions
- Google-style docstrings on non-trivial public APIs

### Reviewing code

Evaluate in order: architecture > code quality > tests > performance. Sync to latest remote first (`git fetch origin`).

For each issue: describe concretely with file:line references, present options with tradeoffs, recommend one, ask before proceeding.

### Testing

- Test behavior, not implementation. If a refactor breaks your tests but not your code, the tests were wrong
- Test edges and errors, not just the happy path
- Mock boundaries (network, filesystem, external services), not logic

## CLI Tools

| tool | replaces | usage |
|---|---|---|
| `rg` (ripgrep) | grep | `rg "pattern"` — fast regex search |
| `fd` | find | `fd "*.swift"` — fast file finder |
| `ast-grep` | - | AST-based code search (prefer over rg for structure) |
| `trash` | rm | `trash file` — recoverable delete. **Never use `rm -rf`** |
| `wt` | git worktree | `wt switch branch` — manage parallel worktrees |
| `prek` | pre-commit | `prek run` — fast git hooks |

## GitHub

- **Always create repos as private** (`gh repo create --private`) unless explicitly told to make public

## Commits and PRs

- Imperative mood, <=72 char subject line, one logical change per commit
- Never push directly to main — feature branches and PRs
- Never commit secrets or credentials — use `.env` files (gitignored)
- PR descriptions: what the code does now, plain factual language. No "critical stability improvement" — a bug fix is a bug fix
- Run relevant tests and linters before committing. Fix everything first
