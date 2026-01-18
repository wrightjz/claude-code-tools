#!/bin/bash
# Ralph Activity Logging Hook
# This runs after Bash tool executions to track activity

# Read input from stdin (PostToolUse provides JSON)
INPUT=$(cat)

# Extract tool info from JSON input
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // "unknown"' 2>/dev/null)
TOOL_INPUT=$(echo "$INPUT" | jq -r '.tool_input.command // ""' 2>/dev/null | head -c 100)

# Log to stderr for verbose mode visibility
if [ -n "$TOOL_INPUT" ]; then
    >&2 echo "[Ralph Activity] $TOOL_NAME: ${TOOL_INPUT}..."
fi

# Exit success - don't block the tool
exit 0
