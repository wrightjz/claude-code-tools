# Ralph

Ralph is an autonomous AI agent loop that repeatedly runs an AI coding assistant until all PRD items are complete. Each iteration is a fresh instance with clean context. Memory persists via git history, `progress.txt`, and `prd.json`.

## Attribution

This implementation is based on [Geoffrey Huntley's original Ralph pattern](https://ghuntley.com/ralph/) and adapted from [Ryan Carson's excellent implementation](https://x.com/ryancarson/status/2008548371712135632). This version has been modified to work as a general-purpose tool independent of any specific platform.

## Supported CLI Tools

Ralph supports multiple AI coding assistants:

| CLI Tool | Autonomous Flag | Installation |
|----------|----------------|--------------|
| **Cursor CLI** | `--force` | [cursor.com/docs/cli](https://cursor.com/docs/cli/overview) |
| **Claude Code** | `--dangerously-skip-permissions` | [Claude Code](https://docs.anthropic.com/en/docs/claude-code) |

## Prerequisites

- One of the supported CLI tools installed and authenticated
- `jq` installed (`brew install jq` on macOS)
- A git repository for your project

### For Cursor CLI

```bash
# Install Cursor CLI
curl -sS https://cursor.com/install | bash

# Set your API key (add to .env.local or export)
export CURSOR_API_KEY=your_key_here
```

### For Claude Code

```bash
# Install Claude Code
# See: https://docs.anthropic.com/en/docs/claude-code

# Authenticate (built-in, no API key needed)
claude auth login
```

## Quick Start

```bash
# Run with Cursor CLI
./ralph-unified.sh --cursor

# Run with Claude Code
./ralph-unified.sh --claude

# Run with custom max iterations
./ralph-unified.sh --cursor 20

# Interactive mode (prompts you to choose)
./ralph-unified.sh
```

## Setup

### Option 1: Copy to your project

```bash
# From your project root
mkdir -p scripts/ralph
cp /path/to/ralph/ralph-unified.sh scripts/ralph/
cp /path/to/ralph/prompt-unified.md scripts/ralph/
chmod +x scripts/ralph/ralph-unified.sh
```

### Option 2: Use environment variables

Create a `.env.local` file in your ralph directory:

```bash
# For Cursor CLI
CURSOR_API_KEY=your_key_here

# Optional: Set default CLI tool
RALPH_CLI=cursor  # or "claude"

# Optional: Override model
RALPH_MODEL=claude-sonnet
```

The script automatically loads `.env.local` if present.

## Workflow

### 1. Create a PRD

Create a `prd.json` file with your user stories (see `prd.json.example`):

```json
{
  "project": "my-feature",
  "branchName": "ralph/my-feature",
  "description": "Feature description",
  "userStories": [
    {
      "id": "US-001",
      "title": "Add user settings page",
      "description": "As a user, I want to access my settings...",
      "acceptanceCriteria": [
        "Settings page accessible from nav menu",
        "Displays current user preferences",
        "All changes persist to database"
      ],
      "priority": 1,
      "passes": false,
      "notes": ""
    }
  ]
}
```

### 2. Run Ralph

```bash
./ralph-unified.sh --cursor  # or --claude
```

Ralph will:
1. Create/checkout the feature branch (from PRD `branchName`)
2. Pick the highest priority story where `passes: false`
3. Implement that single story
4. Run quality checks (typecheck, tests)
5. Commit if checks pass
6. Update `prd.json` to mark story as `passes: true`
7. Append learnings to `progress.txt`
8. Repeat until all stories pass or max iterations reached

## Key Files

| File | Purpose |
|------|---------|
| `ralph-unified.sh` | Main loop script (Cursor + Claude Code support) |
| `prompt-unified.md` | Instructions given to each CLI instance |
| `prd.json` | User stories with `passes` status (the task list) |
| `prd.json.example` | Example PRD format for reference |
| `progress.txt` | Append-only learnings for future iterations |
| `.env.local` | Local environment variables (API keys, defaults) |
| `.cursor/cli.json` | Cursor CLI permissions config |
| `.claude/settings.json` | Claude Code hooks config |

## CLI Comparison

| Feature | Cursor CLI | Claude Code |
|---------|-----------|-------------|
| Autonomous flag | `--force` | `--dangerously-skip-permissions` |
| Non-interactive | `--print` | `-p` |
| Output format | `--output-format text` | (default text) |
| Model selection | `--model` | `--model` |
| Authentication | `CURSOR_API_KEY` env | Built-in |
| Subscription | Cursor subscription | Anthropic API |

## Critical Concepts

### Each Iteration = Fresh Context

Each iteration spawns a **new CLI instance** with clean context. The only memory between iterations is:
- Git history (commits from previous iterations)
- `progress.txt` (learnings and context)
- `prd.json` (which stories are done)

### Small Tasks

Each PRD item should be small enough to complete in one context window. If a task is too big, the LLM runs out of context before finishing and produces poor code.

Right-sized stories:
- Add a database column and migration
- Add a UI component to an existing page
- Update a server action with new logic
- Add a filter dropdown to a list

Too big (split these):
- "Build the entire dashboard"
- "Add authentication"
- "Refactor the API"

### AGENTS.md Updates Are Critical

After each iteration, Ralph updates the relevant `AGENTS.md` files with learnings. Both Cursor and Claude Code automatically read these files, so future iterations (and future human developers) benefit from discovered patterns, gotchas, and conventions.

Examples of what to add to AGENTS.md:
- Patterns discovered ("this codebase uses X for Y")
- Gotchas ("do not forget to update Z when changing W")
- Useful context ("the settings panel is in component X")

### Feedback Loops

Ralph only works if there are feedback loops:
- Typecheck catches type errors
- Tests verify behavior
- CI must stay green (broken code compounds across iterations)

### Stop Condition

When all stories have `passes: true`, Ralph outputs `<promise>COMPLETE</promise>` and the loop exits.

## Debugging

Check current state:

```bash
# See which stories are done
jq '.userStories[] | {id, title, passes}' prd.json

# See learnings from previous iterations
cat progress.txt

# Check git history
git log --oneline -10
```

## Customizing the Prompt

Edit `prompt-unified.md` to customize Ralph's behavior for your project:
- Add project-specific quality check commands
- Include codebase conventions
- Add common gotchas for your stack

## Archiving

Ralph automatically archives previous runs when you start a new feature (different `branchName`). Archives are saved to `archive/YYYY-MM-DD-feature-name/`.

## Documentation

| Document | Description |
|----------|-------------|
| **[USAGE_GUIDE.md](./USAGE_GUIDE.md)** | Step-by-step practical guide with examples |
| [prd.json.example](./prd.json.example) | Example PRD format |
| [prompt-unified.md](./prompt-unified.md) | Agent instructions (customize for your project) |
| [.env.example](./.env.example) | Environment variables template |

## References

- [Geoffrey Huntley's original Ralph article](https://ghuntley.com/ralph/) - The pattern that started it all
- [Ryan Carson's Ralph implementation](https://x.com/ryancarson/status/2008548371712135632) - The implementation this version is based on
- [Cursor CLI documentation](https://cursor.com/docs/cli/overview)
- [Claude Code documentation](https://docs.anthropic.com/en/docs/claude-code)
