#!/bin/bash
# block-env-files.sh — PreToolUse: block writes to .env files
# Receives: CLAUDE_TOOL_INPUT (JSON) with file_path or edits[].file_path
# Exit 1 to block the tool call; exit 0 to allow it.

set -euo pipefail

# Claude Code passes hook input via stdin as JSON.
# Fall back to CLAUDE_TOOL_INPUT env var for forward-compatibility.
TOOL_INPUT=$(cat)
TOOL_INPUT="${TOOL_INPUT:-${CLAUDE_TOOL_INPUT:-}}"

# Extract all file paths from the tool input
# Handles: Write/Edit (.file_path) and MultiEdit (.edits[].file_path)
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

  # Match: .env, .env.local, .env.production, .env.staging, .env.test, .env.example, etc.
  if [[ "$BASENAME" =~ ^\.env(\..*)?$ ]]; then
    BLOCKED=1
    echo "" >&2
    echo "  repo-essentials: Blocked write to: $FILE" >&2
    echo "" >&2
    echo "  Environment files (.env, .env.local, .env.production, etc.) contain" >&2
    echo "  secrets and should not be edited by an AI agent." >&2
    echo "" >&2
    echo "  To make this change yourself:" >&2
    echo "    1. Open the file in your editor manually" >&2
    echo "    2. Apply the change by hand" >&2
    echo "    3. Never commit .env files to version control" >&2
    echo "" >&2
  fi
done <<< "$FILE_PATHS"

if [[ "$BLOCKED" -eq 1 ]]; then
  exit 1
fi

exit 0
