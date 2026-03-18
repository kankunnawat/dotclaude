# dotclaude

Personal Claude Code configuration — rules, skills, teams, hooks, and scripts for a consistent AI-assisted development workflow across machines.

## What's in here

```
~/.claude/
├── CLAUDE.md              # Global instructions loaded into every session
├── settings.json          # Hooks, permissions, model, theme
├── aliases.sh             # Shell aliases (source from ~/.zshrc)
├── statusline.sh          # Custom two-line terminal statusline
├── bootstrap.sh           # New machine setup (run once)
├── sync.sh                # Push/pull configs between machines
│
├── rules/                 # Auto-loaded rules by language/domain
│   ├── common/            # coding-style, git-workflow, security, testing
│   ├── swift/             # iOS-specific style, security, testing
│   └── typescript/        # TS-specific style, hooks, patterns, security, testing
│
├── commands/              # Slash commands (/history, /save-to-vault, etc.)
├── contexts/              # Context presets (ios-dev.md, web-dev.md)
├── skills/                # Reusable agent skills
│   └── xcodebuildmcp-cli/ # XcodeBuildMCP CLI skill
├── teams/                 # Multi-agent team configs
│   ├── arch-reset/
│   ├── default/
│   └── phase1-core/
└── projects/              # Per-project state (gitignored)
    └── <project>/
        └── memory/ -> iCloud  # Symlink to iCloud Drive
```

## New machine setup

### 1. Clone this repo

```bash
git clone git@github.com:kankunnawat/dotclaude.git ~/.claude
```

### 2. Run bootstrap

```bash
cd ~/.claude && chmod +x bootstrap.sh && ./bootstrap.sh
```

This installs CLI tools (`ripgrep`, `fd`, `ast-grep`, `trash`), Claude Code, creates required directories, and wires up iCloud memory symlinks. Safe to run multiple times.

### 3. Follow the printed checklist

The script prints what to do next:

- Add `source ~/.claude/aliases.sh` to `~/.zshrc`
- Set `ANTHROPIC_API_KEY` or run `claude login`
- Copy/generate SSH keys for GitHub and Bitbucket
- Install Xcode from the App Store
- Clone project repos into `~/Work/`
- Run `claude` once in a project directory — plugins auto-install from `settings.json`

### 4. Verify

```bash
claude --version          # Claude Code is installed
rg --version              # ripgrep available
fd --version              # fd available
ls -la ~/.claude/projects/*/memory/   # symlinks pointing to iCloud
```

## Daily workflow

### Syncing configs between machines

```bash
# Before switching to another machine
~/.claude/sync.sh push

# After switching, on the new machine
~/.claude/sync.sh pull
```

Project memory (`MEMORY.md` files) syncs automatically via iCloud — no action needed.

### Context aliases

```bash
# Start Claude with iOS-specific context loaded
claude-ios

# Start Claude with web/TypeScript context loaded
claude-web
```

Add to `~/.zshrc`:
```bash
source ~/.claude/aliases.sh
```

## How memory sync works

Project memory lives in iCloud Drive, not in the git repo:

```
iCloud Drive/claude-memory/<project-name>/MEMORY.md
                                          topic-files...
```

Each `~/.claude/projects/<project>/memory/` is a symlink pointing there. Claude Code reads and writes through the symlink transparently — iCloud handles the sync between machines within minutes.

**Why iCloud instead of git for memory?**
Memory files change constantly during sessions. Git requires manual commits. iCloud syncs in the background automatically, which is the right fit for frequently-written ephemeral-ish data.

**Why git for configs?**
Rules, skills, and CLAUDE.md change intentionally and benefit from version history and explicit commits.

## Statusline

The custom statusline (`statusline.sh`) shows two lines in the Claude Code terminal UI:

```
btz-ios-refacter-fresh │ ⎇ refactor/arch-reset*
◈ Sonnet 4.6 │ 45k/200k │ ◷ 77%
```

- Line 1: folder name, git branch (yellow if dirty)
- Line 2: model, tokens used/total, context remaining %

Configured via `settings.json` hooks.

## Customization

### Add a rule

Drop a `.md` file in `rules/common/`, `rules/swift/`, or `rules/typescript/`. It will be available to reference in CLAUDE.md or project-level configs.

### Add a slash command

Create a `.md` file in `commands/`. The filename becomes the command name (e.g. `commands/my-command.md` → `/my-command`).

### Add a skill

Create a `SKILL.md` in `skills/<skill-name>/`. See existing skills for the format.

### Project-specific overrides

Add a `CLAUDE.md` at the project root. It overrides these global instructions for that project.

## What does NOT transfer

| Item | Why excluded |
|------|-------------|
| `projects/` (except memory) | Session state, machine-specific paths |
| Session transcripts (~600 MB) | Raw dumps, rebuild naturally |
| claude-mem observations (~272 MB) | Too large, rebuild as you work |
| `remote-settings.json` | Org-pushed, auto-fetched on auth |
| `settings.local.json` | Machine-specific permissions |
| Plugin cache | Auto-installed from `settings.json` marketplace configs |
