Analyze the current session and save a structured knowledge note to the Obsidian vault.

## Instructions

### 1. Analyze Session

Review the conversation and extract (skip sections with nothing to report):
- **What Was Done**: Completed items with context
- **Decisions**: Choices made and their rationale
- **Learned**: Gotchas, patterns, or insights worth remembering
- **Open Questions**: Unresolved items or blockers
- **Files Modified**: Key paths touched this session
- **Next Steps**: Ordered list for session resume

### 2. Infer Project

Map the current working directory to a vault project folder:
- `/Users/bitazza/Work/btz-one-shot/*` → `Projects/btz-one-shot/`
- `/Users/bitazza/Work/btz-ios/*` → `Projects/btz-one-shot/`
- `/Users/bitazza/Personal/*` → `Projects/personal/`
- Unknown → ask the user which project folder to use

### 3. Draft Note

Create a structured Obsidian note with this format:

```markdown
---
date: YYYY-MM-DD
project: <project-name>
tags: [session, <relevant-tags>]
type: session
---

# <Descriptive Title>

## What Was Done
- [completed items]

## Decisions
- [decision]: [rationale]

## Learned
- [gotcha or pattern]

## Open Questions
- [unresolved items]

## Next Steps
- [ordered resume list]

## Files Modified
- [paths]
```

Rules:
- Skip empty sections entirely
- Add `[[backlinks]]` to related notes in the same project folder
- Keep the title descriptive but concise
- Use `type: retro` for retrospectives, `type: decision` for architecture decisions

### 4. Show Draft

Present the full draft in chat. Wait for user approval or edits.

### 5. Write to Vault

After approval, write via `mcp__obsidian__write_note` to:
`Projects/<project>/YYYY-MM-DD-<topic-slug>.md`

### 6. Update Dashboard

Read `Context/dashboard.md`, update the line for this project with:
- Latest session link: `[[YYYY-MM-DD-<topic-slug>]]`
- Current status/next step
- Updated date in frontmatter

Keep the dashboard under 30 lines total.

### 7. Confirm

Print the vault path of the new note and confirm the dashboard was updated.
