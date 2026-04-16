#!/bin/bash
# block-nextjs-config.sh — PreToolUse: warn before modifying next.config.js/ts
# next.config changes affect the entire build and can expose env vars or break routing.
# This hook blocks the write and asks the user to confirm intent.
# Exit 1 to block; exit 0 to allow.

set -euo pipefail

TOOL_INPUT=$(cat)
TOOL_INPUT="${TOOL_INPUT:-${CLAUDE_TOOL_INPUT:-}}"

FILE_PATHS=$(echo "$TOOL_INPUT" | jq -r '
  .tool_input |
  if .file_path then .file_path
  elif .edits then .edits[].file_path
  else empty
  end
' 2>/dev/null || true)

BLOCKED=0

while IFS= read -r FILE; do
  [[ -z "$FILE" ]] && continue
  BASENAME=$(basename "$FILE")

  if [[ "$BASENAME" =~ ^next\.config\.(js|ts|mjs|cjs)$ ]]; then
    BLOCKED=1
    echo "" >&2
    echo "  nextjs-essentials: Blocked write to $FILE" >&2
    echo "" >&2
    echo "  next.config changes affect your entire build:" >&2
    echo "    - Incorrect rewrites/redirects can break routing silently" >&2
    echo "    - env/publicRuntimeConfig can accidentally expose secrets to the browser" >&2
    echo "    - webpack overrides can break production builds" >&2
    echo "" >&2
    echo "  Review the proposed change carefully, then apply it yourself." >&2
    echo "  If you want Claude to proceed, remove this hook temporarily." >&2
    echo "" >&2
  fi
done <<< "$FILE_PATHS"

[[ "$BLOCKED" -eq 1 ]] && exit 1
exit 0
