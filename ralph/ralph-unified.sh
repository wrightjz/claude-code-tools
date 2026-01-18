#!/bin/bash
# Ralph Wiggum - Long-running AI agent loop
# Unified version supporting Cursor CLI and Claude Code CLI
# Usage: ./ralph-unified.sh [--cursor|--claude] [max_iterations]

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Default configuration
CLI_TOOL="${RALPH_CLI:-}"  # Can be set via environment variable
MAX_ITERATIONS=10
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PRD_FILE="$SCRIPT_DIR/prd.json"
PROGRESS_FILE="$SCRIPT_DIR/progress.txt"
ARCHIVE_DIR="$SCRIPT_DIR/archive"
LAST_BRANCH_FILE="$SCRIPT_DIR/.last-branch"
PROMPT_FILE="$SCRIPT_DIR/prompt-unified.md"

# Load .env.local if it exists (for CURSOR_API_KEY, etc.)
if [ -f "$SCRIPT_DIR/.env.local" ]; then
    set -a  # Auto-export all variables
    source "$SCRIPT_DIR/.env.local"
    set +a
fi

# Check for jq dependency
if ! command -v jq &> /dev/null; then
    echo -e "${RED}Error: 'jq' is required but not installed.${NC}"
    echo "Install with: brew install jq (macOS) or apt-get install jq (Linux)"
    exit 1
fi

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --cursor)
            CLI_TOOL="cursor"
            shift
            ;;
        --claude)
            CLI_TOOL="claude"
            shift
            ;;
        --help|-h)
            echo "Ralph Wiggum - Autonomous AI Agent Loop"
            echo ""
            echo "Usage: ./ralph-unified.sh [OPTIONS] [max_iterations]"
            echo ""
            echo "Options:"
            echo "  --cursor    Use Cursor CLI (requires CURSOR_API_KEY)"
            echo "  --claude    Use Claude Code CLI"
            echo "  --help      Show this help message"
            echo ""
            echo "Environment Variables:"
            echo "  RALPH_CLI           Set default CLI tool (cursor|claude)"
            echo "  CURSOR_API_KEY      API key for Cursor CLI"
            echo "  RALPH_MODEL         Model to use (optional)"
            echo ""
            echo "Examples:"
            echo "  ./ralph-unified.sh --cursor 10"
            echo "  ./ralph-unified.sh --claude 20"
            echo "  RALPH_CLI=cursor ./ralph-unified.sh 15"
            exit 0
            ;;
        *)
            if [[ $1 =~ ^[0-9]+$ ]]; then
                MAX_ITERATIONS=$1
            else
                echo -e "${RED}Unknown option: $1${NC}"
                echo "Use --help for usage information"
                exit 1
            fi
            shift
            ;;
    esac
done

# Interactive CLI selection if not specified
if [ -z "$CLI_TOOL" ]; then
    echo -e "${CYAN}Select CLI tool:${NC}"
    echo "  1) Cursor CLI"
    echo "  2) Claude Code CLI"
    read -p "Enter choice [1-2]: " choice
    case $choice in
        1) CLI_TOOL="cursor" ;;
        2) CLI_TOOL="claude" ;;
        *) echo -e "${RED}Invalid choice${NC}"; exit 1 ;;
    esac
fi

# Validate CLI tool availability
validate_cli() {
    case $CLI_TOOL in
        cursor)
            if ! command -v cursor &> /dev/null; then
                echo -e "${RED}Error: 'cursor' CLI not found.${NC}"
                echo "Install from: https://cursor.com/docs/cli/overview"
                echo "Or run: curl https://cursor.com/install -fsS | bash"
                exit 1
            fi
            if [ -z "$CURSOR_API_KEY" ]; then
                echo -e "${YELLOW}Warning: CURSOR_API_KEY not set. You may need to authenticate.${NC}"
            fi
            ;;
        claude)
            if ! command -v claude &> /dev/null; then
                echo -e "${RED}Error: 'claude' CLI not found.${NC}"
                echo "Install Claude Code from: https://docs.anthropic.com/en/docs/claude-code"
                exit 1
            fi
            ;;
        *)
            echo -e "${RED}Error: Unknown CLI tool '$CLI_TOOL'${NC}"
            exit 1
            ;;
    esac
}

# Run the AI agent with the appropriate CLI
run_agent() {
    local prompt_content="$1"
    local prompt_file=$(mktemp)
    echo "$prompt_content" > "$prompt_file"

    case $CLI_TOOL in
        cursor)
            # Cursor CLI: Use --force for autonomous operation
            # Run in subshell to avoid environment conflicts
            local model_flag=""
            if [ -n "$RALPH_MODEL" ]; then
                model_flag="--model $RALPH_MODEL"
            fi
            bash -c "export CURSOR_API_KEY=\"$CURSOR_API_KEY\" && ~/.local/bin/cursor-agent -p \"\$(cat '$prompt_file')\" --print --force --output-format text $model_flag" 2>&1
            local exit_code=$?
            rm -f "$prompt_file"
            return $exit_code
            ;;
        claude)
            # Claude Code CLI: Use --dangerously-skip-permissions for autonomous operation
            local model_flag=""
            if [ -n "$RALPH_MODEL" ]; then
                model_flag="--model $RALPH_MODEL"
            fi
            claude --dangerously-skip-permissions --max-turns 50 -p "$(cat "$prompt_file")" $model_flag 2>&1
            local exit_code=$?
            rm -f "$prompt_file"
            return $exit_code
            ;;
    esac
}

# Check for required files
check_requirements() {
    if [ ! -f "$PRD_FILE" ]; then
        echo -e "${RED}Error: prd.json not found at $PRD_FILE${NC}"
        echo ""
        echo "Create a PRD first. You can:"
        echo "  1. Copy prd.json.example and customize it"
        echo "  2. Create one manually following the format"
        exit 1
    fi

    if [ ! -f "$PROMPT_FILE" ]; then
        echo -e "${RED}Error: prompt-unified.md not found at $PROMPT_FILE${NC}"
        exit 1
    fi
}

# Archive previous run if branch changed
archive_previous_run() {
    if [ -f "$PRD_FILE" ] && [ -f "$LAST_BRANCH_FILE" ]; then
        CURRENT_BRANCH=$(jq -r '.branchName // empty' "$PRD_FILE" 2>/dev/null || echo "")
        LAST_BRANCH=$(cat "$LAST_BRANCH_FILE" 2>/dev/null || echo "")

        if [ -n "$CURRENT_BRANCH" ] && [ -n "$LAST_BRANCH" ] && [ "$CURRENT_BRANCH" != "$LAST_BRANCH" ]; then
            DATE=$(date +%Y-%m-%d)
            FOLDER_NAME=$(echo "$LAST_BRANCH" | sed 's|^ralph/||')
            ARCHIVE_FOLDER="$ARCHIVE_DIR/$DATE-$FOLDER_NAME"

            echo -e "${YELLOW}Archiving previous run: $LAST_BRANCH${NC}"
            mkdir -p "$ARCHIVE_FOLDER"
            [ -f "$PRD_FILE" ] && cp "$PRD_FILE" "$ARCHIVE_FOLDER/"
            [ -f "$PROGRESS_FILE" ] && cp "$PROGRESS_FILE" "$ARCHIVE_FOLDER/"
            echo -e "${GREEN}   Archived to: $ARCHIVE_FOLDER${NC}"

            # Reset progress file for new run
            echo "# Ralph Progress Log" > "$PROGRESS_FILE"
            echo "Started: $(date)" >> "$PROGRESS_FILE"
            echo "CLI: $CLI_TOOL" >> "$PROGRESS_FILE"
            echo "---" >> "$PROGRESS_FILE"
        fi
    fi
}

# Track current branch
track_branch() {
    if [ -f "$PRD_FILE" ]; then
        CURRENT_BRANCH=$(jq -r '.branchName // empty' "$PRD_FILE" 2>/dev/null || echo "")
        if [ -n "$CURRENT_BRANCH" ]; then
            echo "$CURRENT_BRANCH" > "$LAST_BRANCH_FILE"
        fi
    fi
}

# Initialize progress file
init_progress_file() {
    if [ ! -f "$PROGRESS_FILE" ]; then
        echo "# Ralph Progress Log" > "$PROGRESS_FILE"
        echo "Started: $(date)" >> "$PROGRESS_FILE"
        echo "CLI: $CLI_TOOL" >> "$PROGRESS_FILE"
        echo "---" >> "$PROGRESS_FILE"
    fi
}

# Count remaining stories
count_remaining_stories() {
    jq '[.userStories[] | select(.passes == false)] | length' "$PRD_FILE" 2>/dev/null || echo "?"
}

# Get next story info
get_next_story() {
    jq -r '[.userStories[] | select(.passes == false)] | sort_by(.priority) | .[0] | "\(.id): \(.title)"' "$PRD_FILE" 2>/dev/null || echo "Unknown"
}

# Main execution
validate_cli
check_requirements
archive_previous_run
track_branch
init_progress_file

# Display banner
echo -e "${BLUE}"
echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║     Ralph - Autonomous AI Agent Loop                          ║"
echo "║     Supports Cursor CLI & Claude Code                         ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo -e "${NC}"
echo -e "CLI Tool:          ${CYAN}$CLI_TOOL${NC}"
echo -e "Max iterations:    ${YELLOW}$MAX_ITERATIONS${NC}"
echo -e "Stories remaining: ${YELLOW}$(count_remaining_stories)${NC}"
echo -e "Next story:        ${GREEN}$(get_next_story)${NC}"
echo ""

# Read prompt content once
PROMPT_CONTENT=$(cat "$PROMPT_FILE")

# Main loop
for i in $(seq 1 $MAX_ITERATIONS); do
    REMAINING=$(count_remaining_stories)
    NEXT_STORY=$(get_next_story)

    echo ""
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "  ${GREEN}Ralph Iteration $i of $MAX_ITERATIONS${NC} (using ${CYAN}$CLI_TOOL${NC})"
    echo -e "  Stories remaining: ${YELLOW}$REMAINING${NC}"
    echo -e "  Working on: ${GREEN}$NEXT_STORY${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    echo ""

    # Run the agent
    OUTPUT=$(run_agent "$PROMPT_CONTENT" | tee /dev/stderr) || true

    # Check for completion signal
    if echo "$OUTPUT" | grep -q "<promise>COMPLETE</promise>"; then
        echo ""
        echo -e "${GREEN}╔═══════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${GREEN}║     Ralph completed all tasks!                                ║${NC}"
        echo -e "${GREEN}║     Finished at iteration $i of $MAX_ITERATIONS                            ║${NC}"
        echo -e "${GREEN}║     CLI: $CLI_TOOL                                               ║${NC}"
        echo -e "${GREEN}╚═══════════════════════════════════════════════════════════════╝${NC}"
        exit 0
    fi

    echo -e "${YELLOW}Iteration $i complete. Continuing to next story...${NC}"
    sleep 2
done

echo ""
echo -e "${RED}╔═══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${RED}║     Ralph reached max iterations ($MAX_ITERATIONS)                         ║${NC}"
echo -e "${RED}║     Check progress.txt for status                             ║${NC}"
echo -e "${RED}╚═══════════════════════════════════════════════════════════════╝${NC}"
exit 1
