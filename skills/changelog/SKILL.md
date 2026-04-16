---
name: changelog
description: Generate a CHANGELOG entry from recent git commits since the last tag or release, grouped by type in Keep a Changelog format
---

Generate a formatted CHANGELOG entry for the current release.

## Step 1 — Find the commit range

Run in order:
1. `git describe --tags --abbrev=0` — get the most recent tag
2. If a tag exists: `git log <last-tag>..HEAD --oneline` — commits since that tag
3. If no tag exists: `git log --oneline -30` — last 30 commits as fallback
4. `git tag --sort=-version:refname | head -5` — list recent tags for context on version numbering convention

## Step 2 — Parse and categorize commits

Group commits by their conventional commit prefix. If commits do not use conventional commits format, infer the category from the message text.

| Prefix / keyword | Category |
|------------------|----------|
| `feat:`, `feature:`, adds/introduces | Features |
| `fix:`, `bug:`, resolves/closes issue | Bug Fixes |
| `docs:`, `doc:`, README, documentation | Documentation |
| `chore:`, `build:`, `ci:`, `deps:`, dependency updates | Maintenance |
| `refactor:`, `perf:`, cleanup | Improvements |
| `test:`, tests, spec | Tests |
| `BREAKING CHANGE:` or `!` suffix | Breaking Changes |

## Step 3 — Write the CHANGELOG entry

Use this format (Keep a Changelog standard):

---

## [Unreleased] — YYYY-MM-DD

### Breaking Changes
- [List any breaking changes first — clearly call out what callers/users must change]

### Features
- [Feature description — trim commit noise, write for a human reader]

### Bug Fixes
- [What was addressed and what the symptom was]

### Improvements
- [Refactors, performance wins, UX improvements]

### Maintenance
- [Dependency bumps, CI changes, build tooling]

### Documentation
- [Docs, README changes]

---

## Rules

- Write each bullet for the person consuming the software, not the developer who made the commit — "Users can now export reports as PDF" not "Added pdf export handler"
- Omit purely internal commits (whitespace, debug logging removal) unless they address a user-visible issue
- If the version number is determinable from the tag pattern, suggest the next version following semver: patch for fixes-only, minor for new features, major for breaking changes
- Ask the user if they want the entry prepended to an existing `CHANGELOG.md` file
- Omit empty sections (don't include a "### Tests" heading if there are no test-related commits)
