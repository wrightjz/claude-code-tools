# Ralph - Autonomous AI Agent Loop

## Overview

Ralph is an autonomous AI agent loop that repeatedly runs an AI coding assistant until all PRD items are complete. Each iteration spawns a fresh instance with clean context.

**Supported CLI Tools:**
- **Cursor CLI** (`cursor agent`)
- **Claude Code CLI** (`claude`)

## Quick Start

```bash
# Run with Cursor CLI
./ralph-unified.sh --cursor

# Run with Claude Code CLI
./ralph-unified.sh --claude

# Specify max iterations
./ralph-unified.sh --cursor 20

# Use environment variable
RALPH_CLI=cursor ./ralph-unified.sh 15
```

## Key Files

| File | Purpose |
|------|---------|
| `ralph-unified.sh` | Main loop script (supports both CLIs) |
| `prompt-unified.md` | Instructions for each iteration |
| `prd.json` | Product Requirements with user stories |
| `progress.txt` | Append-only learnings log |
| `.cursor/cli.json` | Cursor CLI permissions config |
| `.cursor/rules` | Cursor behavior rules |
| `.claude/settings.json` | Claude Code hooks config |

## Workflow Pattern

1. Each iteration spawns a fresh CLI instance with autonomous permissions
2. Memory persists ONLY via:
   - Git history (commits from previous iterations)
   - `progress.txt` (learnings and discovered patterns)
   - `prd.json` (which stories are complete)
3. Stories should be small enough to complete in one context window
4. The completion signal `<promise>COMPLETE</promise>` ends the loop

## CLI Comparison

| Feature | Cursor CLI | Claude Code CLI |
|---------|-----------|-----------------|
| Autonomous flag | `--force` | `--dangerously-skip-permissions` |
| Non-interactive | `-p` | `-p` |
| Output format | `--output-format text` | (default text) |
| Model selection | `--model` | `--model` |
| Auth | `CURSOR_API_KEY` env var | Built-in |

## Environment Variables

```bash
# Required for Cursor CLI
export CURSOR_API_KEY=your_key_here

# Optional: Set default CLI
export RALPH_CLI=cursor  # or "claude"

# Optional: Override model
export RALPH_MODEL=claude-sonnet
```

## PRD Format

See `prd.json.example` for the required format:

```json
{
  "project": "my-feature",
  "branchName": "ralph/my-feature",
  "description": "Feature description",
  "userStories": [
    {
      "id": "US-001",
      "title": "Story title",
      "description": "As a..., I want..., so that...",
      "acceptanceCriteria": ["Criterion 1", "Criterion 2"],
      "priority": 1,
      "passes": false,
      "notes": ""
    }
  ]
}
```

## Quality Requirements

- ALL commits must pass typecheck, lint, and tests
- Do NOT commit broken code
- Keep changes focused and minimal
- Follow existing code patterns
- Update AGENTS.md files with discovered patterns

## Important Patterns

- **One story per iteration** - stories must be completable in one context window
- **Read progress.txt first** - check Codebase Patterns section before starting
- **Verify frontend changes** - browser/UI testing required for frontend stories
- **Commit format**: `feat: [Story ID] - [Story Title]`
