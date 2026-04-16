#!/bin/bash
# warn-missing-dispose.sh — PostToolUse: warn when a controller is created without dispose()
# Detects common Flutter memory leak: creating a controller in initState/constructor
# without a corresponding dispose() call.
# Always exits 0 — never blocks work.

set -euo pipefail

TOOL_OUTPUT=$(cat)
TOOL_OUTPUT="${TOOL_OUTPUT:-${CLAUDE_TOOL_OUTPUT:-}}"

FILE_PATH=$(echo "$TOOL_OUTPUT" | jq -r '.tool_input.file_path // empty' 2>/dev/null || true)

[[ -z "$FILE_PATH" ]] && exit 0
[[ ! -f "$FILE_PATH" ]] && exit 0
[[ ! "$FILE_PATH" =~ \.dart$ ]] && exit 0

FILE_CONTENT=$(cat "$FILE_PATH" 2>/dev/null || true)

# Check if any controller type is instantiated
CONTROLLERS_CREATED=$(echo "$FILE_CONTENT" | grep -cE '(TextEditingController|AnimationController|ScrollController|FocusNode|PageController|TabController)\s*\(' || true)

# Check if dispose() is implemented
HAS_DISPOSE=$(echo "$FILE_CONTENT" | grep -c 'void dispose()' || true)

if [[ "$CONTROLLERS_CREATED" -gt 0 ]] && [[ "$HAS_DISPOSE" -eq 0 ]]; then
  echo "" >&2
  echo "  flutter-essentials: Controller created without dispose() in $(basename "$FILE_PATH")" >&2
  echo "" >&2
  echo "  Found controller instantiation(s) but no dispose() override." >&2
  echo "  Forgetting to dispose controllers is one of the most common Flutter memory leaks." >&2
  echo "" >&2
  echo "  Add to your State class:" >&2
  echo "    @override" >&2
  echo "    void dispose() {" >&2
  echo "      myController.dispose();" >&2
  echo "      super.dispose();" >&2
  echo "    }" >&2
  echo "" >&2
fi

exit 0
