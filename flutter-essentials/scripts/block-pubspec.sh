#!/bin/bash
# block-pubspec.sh — PreToolUse: block direct writes to pubspec.yaml
# Accidental dependency removal or version downgrades can silently break the app.
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

  if [[ "$BASENAME" == "pubspec.yaml" ]]; then
    BLOCKED=1
    echo "" >&2
    echo "  flutter-essentials: Blocked write to pubspec.yaml" >&2
    echo "" >&2
    echo "  Direct edits to pubspec.yaml can:" >&2
    echo "    - Remove dependencies still used in code (causes compile errors)" >&2
    echo "    - Downgrade packages and introduce incompatibilities" >&2
    echo "    - Break version constraints in ways that are hard to debug" >&2
    echo "" >&2
    echo "  To add a package:    flutter pub add <package_name>" >&2
    echo "  To remove a package: flutter pub remove <package_name>" >&2
    echo "  To upgrade:          flutter pub upgrade" >&2
    echo "" >&2
    echo "  If you need a manual edit, apply it yourself in your editor." >&2
    echo "" >&2
  fi
done <<< "$FILE_PATHS"

[[ "$BLOCKED" -eq 1 ]] && exit 1
exit 0
