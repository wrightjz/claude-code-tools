# Claude Code Dev Tools Setup Guide

A step-by-step guide for setting up Claude Code with the development tools.

## Table of Contents

1. [Quick Start](#quick-start)
2. [Setup Levels](#setup-levels)
3. [Prerequisites](#prerequisites)
4. [Installing Claude Code](#installing-claude-code)
5. [Installing Dev Tools](#installing-dev-tools)
6. [Optional: MCP Servers](#optional-mcp-servers)
7. [What Each Component Does](#what-each-component-does)
8. [Verification](#verification)
9. [Troubleshooting](#troubleshooting)

---

## Quick Start

```bash
# Clone the repo
git clone https://github.com/wrightjz/claude-code-tools.git
cd claude-code-tools

# Run the installer
./install.sh
```

---

## Setup Levels

You can install components progressively based on your needs:

### Base Setup (Quick Start)

**What you get:**
- 10 custom agents (planner, product-manager, systems-architect, etc.)
- 3 custom commands (/create-prd, /refactor-clean, /read-gdoc)
- 1 custom skill (codemap-updater)

**Time:** ~2 minutes

### Standard Setup (Recommended)

Everything in Base, plus:
- 7 rule files (coding-style, testing, git-workflow, etc.)
- Safety hooks (block dangerous commands, console.log warnings)

**Time:** ~3 minutes

### Full Setup (Power Users)

Everything in Standard, plus:
- MCP servers (GitHub, Linear, Context7)
- Custom status line configuration

**Time:** ~10 minutes

---

## Prerequisites

Before starting, ensure you have:

- **macOS, Linux, or Windows** (WSL recommended for Windows)
- **Node.js 18+** ([download](https://nodejs.org/))
- **Git** installed and configured
- **Anthropic API key** or Claude Max/Pro subscription

Verify your setup:

```bash
node --version  # Should be 18.x or higher
git --version   # Should be 2.x or higher
```

---

## Installing Claude Code

Claude Code is Anthropic's official CLI for Claude. Install it globally:

```bash
npm install -g @anthropic-ai/claude-code
```

After installation, run it once to complete authentication:

```bash
claude
```

This will open a browser window for authentication. After authenticating, Claude Code is ready to use.

---

## Installing Dev Tools

### Option 1: Automated Install (Recommended)

Clone the repository and run the installer:

```bash
git clone https://github.com/wrightjz/claude-code-tools.git
cd claude-code-tools
./install.sh
```

The script will:
- Verify prerequisites
- Create the necessary directories (`~/.claude/agents/`, etc.)
- Copy all agents, commands, rules, skills, and hooks

### Option 2: Manual Install

If you prefer manual installation:

```bash
# Create directories
mkdir -p ~/.claude/agents
mkdir -p ~/.claude/commands
mkdir -p ~/.claude/rules
mkdir -p ~/.claude/skills
mkdir -p ~/.claude/hooks

# Clone the repository
git clone https://github.com/wrightjz/claude-code-tools.git
cd claude-code-tools

# Copy components
cp agents/*.md ~/.claude/agents/
cp commands/*.md ~/.claude/commands/
cp rules/*.md ~/.claude/rules/
cp -r skills/* ~/.claude/skills/
cp hooks/* ~/.claude/hooks/
```

### Verify Installation

```bash
ls ~/.claude/agents/    # Should show 10 .md files
ls ~/.claude/commands/  # Should show 3 .md files
ls ~/.claude/rules/     # Should show 7 .md files
ls ~/.claude/skills/    # Should show codemap-updater/
ls ~/.claude/hooks/     # Should show hooks.json and .py file
```

---

## Optional: MCP Servers

MCP (Model Context Protocol) servers extend Claude Code's capabilities. Add these to your Claude Code settings:

### GitHub MCP Server

For GitHub integration (PRs, issues, etc.):

```json
{
  "mcpServers": {
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "your-token-here"
      }
    }
  }
}
```

### Context7 MCP Server

For up-to-date SDK documentation:

```json
{
  "mcpServers": {
    "context7": {
      "command": "npx",
      "args": ["-y", "@context7/mcp"]
    }
  }
}
```

### Linear MCP Server

For Linear issue tracking:

```json
{
  "mcpServers": {
    "linear": {
      "command": "npx",
      "args": ["-y", "@linear/mcp-server"]
    }
  }
}
```

---

## What Each Component Does

### Agents

| Agent | Purpose | When to Use |
|-------|---------|-------------|
| **planner** | Break down tasks | Feature planning, task decomposition |
| **product-manager** | Create PRDs | New features, requirements gathering |
| **systems-architect** | Technical architecture | System design, API design |
| **elegant-code-architect** | Write clean code | Quality implementations |
| **codebase-auditor** | Deep code audit | Tech debt, periodic cleanup |
| **tdd-guide** | Test-driven development | Writing tests first |
| **ui-ux-designer** | Design interfaces | UI features, accessibility |
| **workflow-architect** | Design workflows | Process automation |
| **workflow-implementer** | Implement workflows | Building from designs |
| **build-error-resolver** | Fix build errors | Unblock development |

### Commands

| Command | Purpose |
|---------|---------|
| `/create-prd` | Conduct discovery interview and create product requirements |
| `/refactor-clean` | Clean up dead code, unused files, improve quality |
| `/read-gdoc` | Fetch and parse Google Docs as Markdown |

### Rules

| Rule | What it Enforces |
|------|------------------|
| **coding-style.md** | TypeScript, imports, formatting |
| **testing.md** | Vitest, TDD, coverage patterns |
| **git-workflow.md** | Conventional commits, PR guidelines |
| **agents.md** | When to delegate to subagents |
| **security.md** | Secrets handling, input validation |
| **performance.md** | Model selection, context management |
| **ui-implementation.md** | Touch targets, animation, forms, accessibility |

### Hooks

| Hook | Trigger | Action |
|------|---------|--------|
| **Dangerous command blocker** | rm -rf, git push --force | Blocks execution |
| **TypeScript check** | Edit .ts/.tsx | Runs tsc --noEmit |
| **Prettier format** | Edit JS/TS | Auto-formats if config exists |
| **console.log warning** | Edit any file | Warns if console.log present |

---

## Verification

After installation, verify everything is working:

### 1. Check Agents

In Claude Code, type:
```
What agents are available?
```

You should see the list of installed agents.

### 2. Check Commands

Try running a command:
```
/refactor-clean
```

### 3. Check Rules

Ask Claude Code:
```
What coding style rules are active?
```

### 4. Test Hooks

Edit a TypeScript file - you should see type checking run automatically.

---

## Troubleshooting

### Claude Code won't start

```bash
# Reinstall Claude Code
npm uninstall -g @anthropic-ai/claude-code
npm install -g @anthropic-ai/claude-code
```

### Commands not appearing

1. Restart Claude Code completely
2. Verify files exist: `ls ~/.claude/commands/`
3. Check file permissions: files should be readable

### Agents/Commands not found

Verify the files are in the correct location:

```bash
ls ~/.claude/agents/
ls ~/.claude/commands/
```

### MCP Server not connecting

1. Run `/mcp` to see status
2. Check the server is installed correctly
3. Verify environment variables are set
4. Try removing and re-adding the server

### Hooks not working

1. Check `~/.claude/hooks/` for configuration files
2. Ensure hook files have correct permissions:
   ```bash
   chmod +x ~/.claude/hooks/*.py
   chmod +x ~/.claude/hooks/*.sh
   ```
3. Hooks require specific tool names in matchers

---

## Updating

To update to the latest version:

```bash
cd /path/to/claude-code-tools
git pull
./install.sh
```

Or manually copy updated files to `~/.claude/`.

---

## Directory Structure

After installation, your Claude config should look like:

```
~/.claude/
├── agents/
│   ├── planner.md
│   ├── product-manager.md
│   ├── systems-architect.md
│   ├── elegant-code-architect.md
│   ├── codebase-auditor.md
│   ├── tdd-guide.md
│   ├── ui-ux-designer.md
│   ├── workflow-architect.md
│   ├── workflow-implementer.md
│   └── build-error-resolver.md
├── commands/
│   ├── create-prd.md
│   ├── refactor-clean.md
│   └── read-gdoc.md
├── rules/
│   ├── agents.md
│   ├── coding-style.md
│   ├── git-workflow.md
│   ├── performance.md
│   ├── security.md
│   ├── testing.md
│   └── ui-implementation.md
├── skills/
│   └── codemap-updater/
└── hooks/
    ├── hooks.json
    └── block-dangerous-commands.py
```

---

## Getting Help

- Check the [README.md](./README.md) for component documentation
- Review individual agent/command files for usage details
- Open an issue on GitHub for bugs or feature requests
