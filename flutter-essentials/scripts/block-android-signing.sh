#!/bin/bash
# block-android-signing.sh — PreToolUse: block writes to Android signing config files
# key.properties and keystore files contain signing credentials — never AI-edited.
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

  # Match Android signing files
  if [[ "$BASENAME" == "key.properties" ]] || \
     [[ "$BASENAME" =~ \.(jks|keystore)$ ]]; then
    BLOCKED=1
    echo "" >&2
    echo "  flutter-essentials: Blocked write to Android signing file: $FILE" >&2
    echo "" >&2
    echo "  This file contains or references your Android release signing credentials." >&2
    echo "  Editing signing config through an AI agent is not safe." >&2
    echo "" >&2
    echo "  Make this change manually and ensure the file is in .gitignore." >&2
    echo "" >&2
  fi
done <<< "$FILE_PATHS"

[[ "$BLOCKED" -eq 1 ]] && exit 1
exit 0
