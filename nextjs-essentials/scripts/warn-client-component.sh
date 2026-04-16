#!/bin/bash
# warn-client-component.sh — PostToolUse: warn when "use client" is added to a file
# high in the component tree. Does not block — just surfaces the concern.
# Always exits 0.

set -euo pipefail

TOOL_OUTPUT=$(cat)
TOOL_OUTPUT="${TOOL_OUTPUT:-${CLAUDE_TOOL_OUTPUT:-}}"

FILE_PATH=$(echo "$TOOL_OUTPUT" | jq -r '.tool_input.file_path // empty' 2>/dev/null || true)

[[ -z "$FILE_PATH" ]] && exit 0
[[ ! -f "$FILE_PATH" ]] && exit 0

# Only check .tsx / .jsx / .ts / .js files
BASENAME=$(basename "$FILE_PATH")
[[ ! "$BASENAME" =~ \.(tsx|jsx|ts|js)$ ]] && exit 0

# Check if the written file contains "use client" at the top
FIRST_LINES=$(head -5 "$FILE_PATH" 2>/dev/null || true)
if echo "$FIRST_LINES" | grep -q '"use client"'; then
  # Warn if this looks like a layout or page file (high in the tree)
  if [[ "$BASENAME" =~ ^(layout|page|template)\.(tsx|jsx|ts|js)$ ]]; then
    echo "" >&2
    echo "  nextjs-essentials: 'use client' added to $BASENAME" >&2
    echo "" >&2
    echo "  Adding 'use client' to a layout or page converts the entire subtree" >&2
    echo "  to Client Components, disabling server-side rendering for all children." >&2
    echo "" >&2
    echo "  Consider: extract only the interactive part into a small leaf component" >&2
    echo "  and mark that leaf as 'use client' instead." >&2
    echo "" >&2
  fi
fi

exit 0
