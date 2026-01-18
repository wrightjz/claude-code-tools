# Claude Code Dev Tools

A collection of agents, commands, rules, and skills to supercharge your [Claude Code](https://claude.ai/claude-code) development workflow.

## What's Included

| Component | Count | Description |
|-----------|-------|-------------|
| **Agents** | 10 | Specialized AI assistants for different tasks |
| **Commands** | 3 | Slash commands for common workflows |
| **Rules** | 7 | Coding standards and best practices |
| **Skills** | 1 | Advanced capabilities |
| **Hooks** | 2 | Safety guards against dangerous operations |
| **Ralph** | 1 | Autonomous AI loop for complex tasks |

## Quick Start

### Option 1: Automated Install

```bash
# Clone the repo
git clone https://github.com/wrightjz/claude-code-tools.git
cd claude-code-tools

# Run the installer
./install.sh
```

### Option 2: Manual Install

```bash
# Create directories
mkdir -p ~/.claude/{agents,commands,rules,skills,hooks}

# Copy components
cp agents/*.md ~/.claude/agents/
cp commands/*.md ~/.claude/commands/
cp rules/*.md ~/.claude/rules/
cp -r skills/* ~/.claude/skills/
cp hooks/* ~/.claude/hooks/
```

## Components

### Agents

Specialized AI assistants that handle specific types of tasks:

| Agent | Purpose | Model |
|-------|---------|-------|
| **planner** | Break down features into actionable tasks | Sonnet |
| **product-manager** | Create and refine PRDs | Opus |
| **systems-architect** | Design technical architecture | Opus |
| **elegant-code-architect** | Write clean, maintainable code | Opus |
| **codebase-auditor** | Deep audit and tech debt analysis | Opus |
| **tdd-guide** | Test-driven development guidance | Sonnet |
| **ui-ux-designer** | UI/UX design and accessibility | Sonnet |
| **workflow-architect** | Design complex workflows | Opus |
| **workflow-implementer** | Implement workflow designs | Sonnet |
| **build-error-resolver** | Fix build and type errors | Haiku |

**Usage**: Agents are automatically used by Claude Code when tasks match their expertise. You can also explicitly request an agent:

```
Use the planner agent to break down this feature
```

### Commands

Slash commands for common development workflows:

| Command | Description |
|---------|-------------|
| `/create-prd "description"` | Conduct a discovery interview and create a comprehensive PRD |
| `/refactor-clean` | Clean up dead code, unused files, and improve code quality |
| `/read-gdoc [url]` | Fetch and parse Google Docs as Markdown |

**Usage**: Type the command in Claude Code:

```
/create-prd "Add user authentication with OAuth"
```

### Rules

Coding standards that Claude Code follows during development:

| Rule | Focus |
|------|-------|
| **coding-style.md** | TypeScript best practices, file organization |
| **testing.md** | Vitest config, TDD practices, coverage |
| **git-workflow.md** | Conventional commits, PR guidelines |
| **agents.md** | When and how to delegate to agents |
| **security.md** | Secrets handling, input validation |
| **performance.md** | Model selection, context management |
| **ui-implementation.md** | Accessibility, animation, forms |

### Skills

Advanced capabilities for specific tasks:

| Skill | Description |
|-------|-------------|
| **codemap-updater** | Generate CODEMAP.md files for codebase navigation |

**Usage**: Skills are invoked automatically when relevant, or manually:

```
Generate a codemap for this project
```

### Hooks

Safety mechanisms that run before/after tool execution:

| Hook | Protection |
|------|------------|
| **block-dangerous-commands.py** | Blocks `rm -rf`, `git push --force`, etc. |
| **hooks.json** | Warns about npm vs pnpm, markdown creation, console.log |

### Ralph (Autonomous Loop)

An autonomous AI agent loop for complex, multi-step tasks. Ralph maintains state across context windows using git and progress files.

See [ralph/README.md](ralph/README.md) for full documentation.

## Directory Structure

```
claude-code-tools/
├── agents/           # Specialized AI assistants
├── commands/         # Slash commands
├── rules/            # Coding standards
├── skills/           # Advanced capabilities
│   └── codemap-updater/
├── hooks/            # Safety guards
├── ralph/            # Autonomous loop tool
├── install.sh        # Automated installer
├── README.md         # This file
└── SETUP.md          # Detailed setup guide
```

## Customization

### Adding Your Own Agents

Create a markdown file in `~/.claude/agents/`:

```markdown
---
name: my-agent
description: What this agent does and when to use it
model: sonnet
---

Instructions for the agent...
```

### Adding Your Own Commands

Create a markdown file in `~/.claude/commands/`:

```markdown
# My Command

Instructions that execute when the user types /my-command
```

### Adding Your Own Rules

Create a markdown file in `~/.claude/rules/`:

```markdown
# My Rules

Guidelines that Claude Code will follow in this project
```

## Requirements

- Node.js 18+
- Git
- [Claude Code](https://claude.ai/claude-code) installed

## Contributing

Contributions welcome! Please:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## License

MIT License - see LICENSE file for details.

## Acknowledgments

Built for the Claude Code community. Inspired by the need for consistent, high-quality AI-assisted development workflows.
