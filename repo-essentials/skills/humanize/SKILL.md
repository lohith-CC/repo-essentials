---
name: humanize
description: Rewrite user-facing strings, comments, error messages, and docs to be warm, jargon-free, and positively framed
---

Review the content the user points to — which may be a file, a code block, selected text, or a specific function — and rewrite all user-facing text to be warmer and clearer.

## What to scan

- Error messages and exception text
- UI labels, button text, toast/alert messages
- Code comments (especially those describing failure states)
- README sections and documentation prose
- Log messages that users might see
- Tooltip and placeholder text

## Replacement rules (apply strictly)

| Original word/phrase | Replace with |
|----------------------|-------------|
| broken | needs attention |
| failed / failure | couldn't complete |
| error (as a noun describing an outcome) | issue |
| crashed | stopped unexpectedly |
| killed / terminated | stopped |
| invalid | doesn't look right |
| fatal | critical |
| hack (in comments) | workaround |
| stupid / dumb (in comments) | remove the word entirely, rewrite the sentence constructively |
| cannot / can't (in error messages) | couldn't / isn't able to |
| abort / aborted | cancelled |
| illegal (describing input) | not supported |
| bad (e.g. "bad input") | unexpected |

## Style principles

1. Conversational but professional — write as if a helpful colleague is speaking, not a system alert.
2. Positive framing — say what can be done, not just what went wrong.
3. No technical acronyms in user-visible text unless absolutely unavoidable (and even then, explain them inline).
4. Keep error messages actionable — if possible, include one concrete next step.
5. Do not add filler phrases like "Oops!" or emojis — warmth comes from word choice, not decoration.
6. Preserve all logic, variable references, and string interpolation — only the prose changes.

## Output format

For each changed string, show:
- **Original**: the existing text
- **Revised**: the improved text
- **Note**: one line explaining what changed

After all individual changes, offer to apply them directly if the user is working in a file.

If no user-facing text needs changes, say so briefly rather than inventing unnecessary edits.
