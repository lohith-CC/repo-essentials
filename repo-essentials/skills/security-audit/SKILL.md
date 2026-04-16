---
name: security-audit
description: Quick security review of staged or specified files — checks for hardcoded secrets, injection patterns, XSS vectors, and insecure practices
---

Run a targeted security review of the files the user specifies (or staged git changes if none specified).

## Step 1 — Identify scope

- If the user provides file paths or a diff, use those.
- Otherwise, run `git diff --staged --name-only` to get staged files, then read each one.
- If no staged files exist, ask the user which file(s) to review.

## Step 2 — Check for these issue categories

### A. Hardcoded secrets
- API keys, tokens, passwords assigned to variables (look for patterns like `api_key = "..."`, `password = "..."`, `secret = "..."`, `token = "..."`)
- Private keys or certificate material embedded in source
- Connection strings with credentials inline (e.g. `postgres://user:password@host/db`)
- Base64-encoded strings that decode to credential-like content

### B. SQL injection
- String concatenation or f-string/template interpolation used to build SQL queries
- Raw queries using user-provided input without parameterization
- ORM `.raw()` calls with unsanitized variables

### C. Cross-site scripting (XSS)
- `innerHTML`, `document.write()`, `eval()` with user-controlled data
- Template literals inserted into the DOM without sanitization
- React `dangerouslySetInnerHTML` used with dynamic content
- Server-side template injection (unsanitized variables in HTML templates)

### D. Insecure patterns
- Use of `MD5` or `SHA1` for password hashing (not `bcrypt`, `argon2`, or `pbkdf2`)
- Disabled TLS/SSL verification (`verify=False`, `NODE_TLS_REJECT_UNAUTHORIZED=0`)
- `exec()`, `eval()`, `shell=True` (Python) or `child_process.exec` with user input
- Logging of sensitive fields (passwords, tokens, PII)
- CORS configured with `*` alongside credentials

### E. Dependency issues
- Flag any `import` or `require` of packages known for recent critical CVEs if you recognize them
- Note any use of pinned-to-old-version patterns

## Step 3 — Report format

For each finding:

**[SEVERITY] Category — File:Line**
- What was found (quote the relevant line)
- Why it is a concern
- Recommended fix (concrete, not generic)

Severity levels: CRITICAL / HIGH / MEDIUM / LOW / INFO

At the end, provide a summary:
- Total findings by severity
- Overall risk assessment (one sentence)
- Top priority fix

If no issues are found, say so clearly — a clean result is useful information.
