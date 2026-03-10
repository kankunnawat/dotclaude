Save current session progress to a continuity file for pickup in future sessions.

## Instructions

1. Summarize the current session state:
   - What task was being worked on
   - What's been completed (with file paths)
   - What's in progress or blocked
   - Key decisions made this session
   - Next steps remaining

2. Write the summary to a timestamped file:
   - Path: `.claude/sessions/YYYY-MM-DD-HH-MM-<topic>.md`
   - Create the `.claude/sessions/` directory if it doesn't exist
   - Use the primary task as the topic slug (e.g., `dashboard-balance`, `login-flow`)

3. Format:
```markdown
# Session: <topic>
Date: YYYY-MM-DD HH:MM
Duration: ~Xm (estimate from message count)

## Completed
- [ item with file path ]

## In Progress
- [ item with current state ]

## Blocked
- [ item with blocker description ]

## Decisions
- [ decision and rationale ]

## Next Steps
- [ ordered list of what to do next ]

## Key Files Modified
- [ file paths touched this session ]
```

4. Print the file path when done so the user can reference it.

Do NOT include speculative future work. Only document what actually happened and the immediate next steps.
