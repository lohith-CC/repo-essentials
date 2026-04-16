#!/bin/bash
# block-risky-git.sh — PreToolUse: block destructive git commands run via Bash tool
# Detects: git push --force / -f / --force-with-lease  and  git reset --hard
# Receives: CLAUDE_TOOL_INPUT (JSON) with .command string
# Exit 1 to block the tool call; exit 0 to allow it.

set -euo pipefail

TOOL_INPUT=$(cat)
TOOL_INPUT="${TOOL_INPUT:-${CLAUDE_TOOL_INPUT:-}}"

COMMAND=$(echo "$TOOL_INPUT" | jq -r '.tool_input.command // empty' 2>/dev/null || true)

[[ -z "$COMMAND" ]] && exit 0

BLOCKED=0
REASONS=()

# Check for force push variants: --force, -f, --force-with-lease
if echo "$COMMAND" | grep -qE 'git\s+push\s+.*(-f\b|--force\b|--force-with-lease\b)'; then
  BLOCKED=1
  REASONS+=("git push with --force / -f / --force-with-lease")
fi

# Check for hard reset
if echo "$COMMAND" | grep -qE 'git\s+reset\s+.*--hard\b'; then
  BLOCKED=1
  REASONS+=("git reset --hard")
fi

if [[ "$BLOCKED" -eq 1 ]]; then
  echo "" >&2
  echo "  repo-essentials: Blocked risky git command." >&2
  for REASON in "${REASONS[@]}"; do
    echo "  Detected: $REASON" >&2
  done
  echo "" >&2
  echo "  These commands can permanently destroy commit history." >&2
  echo "  Please run this command yourself in the terminal if you are certain:" >&2
  echo "" >&2
  echo "    $COMMAND" >&2
  echo "" >&2
  echo "  Tip: Prefer --force-with-lease over --force to avoid overwriting" >&2
  echo "  commits pushed by teammates." >&2
  echo "" >&2
  exit 1
fi

exit 0
