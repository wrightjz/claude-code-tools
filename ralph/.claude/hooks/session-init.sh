#!/bin/bash
# Ralph Session Initialization Hook
# This runs at the start of each Claude Code session

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$(dirname "$SCRIPT_DIR")")"
PRD_FILE="$PROJECT_DIR/prd.json"
PROGRESS_FILE="$PROJECT_DIR/progress.txt"

# Output context information to stderr (shown in verbose mode)
>&2 echo "[Ralph] Session starting..."

# Check if PRD exists
if [ -f "$PRD_FILE" ]; then
    REMAINING=$(jq '[.userStories[] | select(.passes == false)] | length' "$PRD_FILE" 2>/dev/null || echo "?")
    TOTAL=$(jq '.userStories | length' "$PRD_FILE" 2>/dev/null || echo "?")
    BRANCH=$(jq -r '.branchName // "unknown"' "$PRD_FILE" 2>/dev/null || echo "unknown")

    >&2 echo "[Ralph] PRD loaded: $REMAINING of $TOTAL stories remaining"
    >&2 echo "[Ralph] Branch: $BRANCH"
fi

# Check if progress file exists and has patterns
if [ -f "$PROGRESS_FILE" ]; then
    PATTERN_COUNT=$(grep -c "^- " "$PROGRESS_FILE" 2>/dev/null || echo "0")
    >&2 echo "[Ralph] Progress file found with ~$PATTERN_COUNT logged items"
fi

# Set environment variables if CLAUDE_ENV_FILE is available
if [ -n "$CLAUDE_ENV_FILE" ]; then
    echo "export RALPH_PROJECT_DIR=\"$PROJECT_DIR\"" >> "$CLAUDE_ENV_FILE"
    echo "export RALPH_PRD_FILE=\"$PRD_FILE\"" >> "$CLAUDE_ENV_FILE"
    echo "export RALPH_PROGRESS_FILE=\"$PROGRESS_FILE\"" >> "$CLAUDE_ENV_FILE"
fi

# Return success - output goes to Claude's context
echo "Ralph session initialized. PRD: $PRD_FILE"
exit 0
