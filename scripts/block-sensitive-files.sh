#!/bin/bash
# block-sensitive-files.sh — PreToolUse: block writes to cryptographic key/cert files
# Receives: CLAUDE_TOOL_INPUT (JSON) with file_path or edits[].file_path
# Exit 1 to block the tool call; exit 0 to allow it.

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

  # Match certificate/key file extensions: .pem .key .p12 .pfx .crt .cer .der
  # Match standard OpenSSH key filenames: id_rsa, id_dsa, id_ecdsa, id_ed25519 (with or without .pub)
  if [[ "$BASENAME" =~ \.(pem|key|p12|pfx|crt|cer|der)$ ]] || \
     [[ "$BASENAME" =~ ^id_(rsa|dsa|ecdsa|ed25519)(\.pub)?$ ]]; then
    BLOCKED=1
    echo "" >&2
    echo "  repo-essentials: Blocked write to sensitive file: $FILE" >&2
    echo "" >&2
    echo "  This file appears to contain cryptographic keys or certificates." >&2
    echo "  Editing key material through an AI agent is not recommended." >&2
    echo "" >&2
    echo "  If you intended this, make the change manually in your terminal." >&2
    echo "" >&2
  fi
done <<< "$FILE_PATHS"

if [[ "$BLOCKED" -eq 1 ]]; then
  exit 1
fi

exit 0
