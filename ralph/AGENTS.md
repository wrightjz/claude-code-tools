# Ralph Agent Instructions

## Overview

Ralph is an autonomous AI agent loop that repeatedly runs an AI coding assistant until all PRD items are complete. Each iteration spawns a fresh instance with clean context.

**Supported CLI Tools:**
- **Cursor CLI** (`cursor agent --force`)
- **Claude Code CLI** (`claude --dangerously-skip-permissions`)

## Commands

```bash
# Run Ralph with Cursor CLI
./ralph-unified.sh --cursor

# Run Ralph with Claude Code CLI
./ralph-unified.sh --claude

# Run with custom max iterations
./ralph-unified.sh --cursor 20
```

## Key Files

- `ralph-unified.sh` - Main loop script (Cursor + Claude Code support)
- `prompt-unified.md` - Instructions for each iteration
- `prd.json.example` - Example PRD format
- `.cursor/cli.json` - Cursor CLI permissions config
- `.cursor/rules` - Cursor behavior rules
- `.claude/settings.json` - Claude Code hooks config

## Patterns

- Each iteration spawns a fresh CLI instance with clean context
- Memory persists via git history, `progress.txt`, and `prd.json`
- Stories should be small enough to complete in one context window
- Always update AGENTS.md with discovered patterns for future iterations
