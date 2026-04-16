---
name: pr-description
description: Generate a well-structured PR description from staged changes or a provided git diff
---

Generate a pull request description from the current git changes.

## Step 1 — Gather context

Run the following in order:
1. `git diff --staged` — get the staged diff (primary source)
2. If nothing is staged, run `git diff HEAD~1` to get the last commit's changes
3. `git log --oneline -10` — get recent commit messages for context
4. `git branch --show-current` — get the branch name (often encodes intent)

If the user provides a specific diff or file list, use that instead of running git commands.

## Step 2 — Analyze the changes

Before writing, identify:
- What was added, changed, or removed
- Which components/modules are affected
- Whether this is a feature, bug fix, refactor, docs update, or dependency change
- Any migrations, config changes, or breaking changes present

## Step 3 — Write the PR description

Use this exact structure:

---

## Summary

[2-3 sentences. What does this PR do and why? Write for a reviewer who hasn't seen the branch — give them the "so what" immediately.]

## Changes

- [Specific change 1 — be concrete, not generic. e.g. "Added retry logic to the payment API client with exponential backoff up to 3 attempts"]
- [Specific change 2]
- [Add as many bullets as needed — group related items]

## Test Plan

- [ ] [Concrete verification step — e.g. "Run `npm test` and confirm all tests pass"]
- [ ] [Manual step if applicable — e.g. "Open /checkout and complete a purchase flow end to end"]
- [ ] [Edge case — e.g. "Test with an expired card to verify the error message is shown correctly"]

## Notes for Reviewers

[Optional — include only if there is something the reviewer specifically needs to know: a known trade-off, a deferred decision, or context that isn't obvious from the diff. Omit this section if there is nothing to add.]

---

## Style rules

- No emojis
- No filler phrases ("This PR aims to...", "This change seeks to...")
- Bullet points over prose in the Changes section
- Test plan items must be checkboxes so reviewers can track coverage
- If the branch name contains a ticket number (e.g. `feat/PROJ-123-...`), reference it at the top of the Summary
