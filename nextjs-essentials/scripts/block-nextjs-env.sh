#!/bin/bash
# block-nextjs-env.sh — PreToolUse: block writes to Next.js environment files
# Protects: .env.local, .env.production.local, .env.development.local
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

  # Match Next.js local env files that should never be committed or AI-edited
  if [[ "$BASENAME" =~ ^\.env\.(local|production\.local|development\.local|test\.local)$ ]]; then
    BLOCKED=1
    echo "" >&2
    echo "  nextjs-essentials: Blocked write to Next.js environment file: $FILE" >&2
    echo "" >&2
    echo "  Local environment files contain secrets and are git-ignored for a reason." >&2
    echo "  These should never be edited by an AI agent." >&2
    echo "" >&2
    echo "  Edit this file manually in your terminal or editor." >&2
    echo "" >&2
  fi
done <<< "$FILE_PATHS"

[[ "$BLOCKED" -eq 1 ]] && exit 1
exit 0
