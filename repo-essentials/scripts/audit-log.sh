#!/bin/bash
# audit-log.sh — PostToolUse: append a timestamped record to the audit log on every file write
# Receives: CLAUDE_TOOL_OUTPUT (JSON)
# Always exits 0 — audit logging must never block work.

# Claude Code passes hook input via stdin as JSON.
TOOL_OUTPUT=$(cat)
TOOL_OUTPUT="${TOOL_OUTPUT:-${CLAUDE_TOOL_OUTPUT:-}}"

# Ensure the persistent plugin data directory exists
mkdir -p "${CLAUDE_PLUGIN_DATA:-$HOME/.claude/plugin-data/repo-essentials}"

LOG_FILE="${CLAUDE_PLUGIN_DATA:-$HOME/.claude/plugin-data/repo-essentials}/audit.log"
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# Extract file path(s) from tool output
# Handles: Write/Edit (.file_path) and MultiEdit (.edits[].file_path)
FILE_PATHS=$(echo "$TOOL_OUTPUT" | jq -r '
  .tool_input |
  if .file_path then .file_path
  elif .edits then .edits[].file_path
  else "unknown"
  end
' 2>/dev/null || echo "unknown")

while IFS= read -r FILE; do
  [[ -z "$FILE" ]] && continue
  echo "${TIMESTAMP}  WRITE  ${FILE}" >> "$LOG_FILE"
done <<< "$FILE_PATHS"

exit 0
