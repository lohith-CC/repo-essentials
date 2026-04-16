---
name: code-review
description: Review a file or diff for correctness, readability, maintainability, and bugs — provides specific, actionable feedback
---

Conduct a thorough code review on the file or diff the user provides.

## Step 1 — Establish scope

- If the user provides a file path, read it fully.
- If the user says "staged changes" or "diff", run `git diff --staged`.
- If the user provides a specific function or class name, focus on that section but read surrounding context too.
- Ask for clarification if the scope is ambiguous.

## Step 2 — Review across these dimensions

### Correctness
- Logic errors, off-by-one errors, wrong conditionals
- Missing null/undefined checks where the value could reasonably be absent
- Edge cases that are unhandled (empty arrays, zero values, concurrent access)
- Incorrect assumptions about API return shapes

### Readability
- Functions or methods doing more than one thing (violating single-responsibility)
- Variable and function names that don't convey intent clearly
- Long functions that should be extracted
- Dead code (unreachable branches, unused variables/imports)
- Missing or misleading comments on non-obvious logic

### Maintainability
- Magic numbers or strings that should be named constants
- Duplicated logic that could be a shared utility
- Tight coupling that makes testing or future changes harder
- Missing error handling or silent failures (empty catch blocks)
- Hard-coded values that should be configurable

### Performance (flag only when meaningful)
- N+1 queries or loops that hit an API/DB repeatedly
- Unnecessary re-computation inside loops
- Synchronous I/O where async would be expected

### Testing considerations
- Whether the code is structured in a testable way
- Missing test cases worth covering for the logic being added

## Step 3 — Format the review

### Summary
[1-2 sentences: overall quality assessment, biggest strength, and biggest concern]

### Issues (required changes)
For each issue:
- **Location**: file:line or function name
- **Problem**: What is wrong and why it matters
- **Suggestion**: Concrete fix — show corrected code where practical

### Suggestions (optional improvements)
Same format as Issues, but non-blocking.

### Positives
[2-3 things done well — a good review acknowledges what works]

## Style rules

- Be specific — "this function is hard to read" is not useful; "this function does X and Y and should be split at line N" is.
- Suggest, don't dictate — use "consider", "could be simplified to", "worth extracting" rather than imperatives.
- No personal language — review the code, not the author.
- Prioritize: lead with things that could cause bugs or data loss; style issues come last.
