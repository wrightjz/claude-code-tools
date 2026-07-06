# Claude Code Dev Tools

A collection of agents, commands, rules, and skills to supercharge your [Claude Code](https://claude.ai/claude-code) development workflow.

## What's Included

| Component | Count | Description |
|-----------|-------|-------------|
| **Agents** | 2 | Specialized subagents for audits and architecture |
| **Commands** | 6 | Slash commands for a spec → plan → build pipeline |
| **Rules** | 4 | Coding standards and best practices |
| **Skills** | 6 | On-demand capabilities (TDD builds, loops, diagrams, UI) |
| **Hooks** | 3 | Safety guards and formatting checks |

> **Design philosophy (2026 update):** always-loaded rules are kept small; anything task-specific lives in on-demand skills. Custom agents exist only where they carry knowledge the built-in agents (Explore, Plan, general-purpose) don't. The old Ralph autonomous loop has been retired in favor of the `loop-maker` skill.

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

Custom subagents for tasks the built-in agents don't cover. Both inherit your session's model (no pins).

| Agent | Purpose |
|-------|---------|
| **codebase-auditor** | Whole-repo tech-debt audit with a risk-tiered report; applies only zero-risk cleanups |
| **systems-architect** | Turn a PRD into a technical architecture document and phased implementation plan |

For planning, exploration, and general delegation, use Claude Code's built-in Plan, Explore, and general-purpose agents.

### Commands

A coherent development pipeline producing durable artifacts:

| Command | Description |
|---------|-------------|
| `/spec "description"` | One round of questions → `docs/spec.md` |
| `/plan` | Spec → `docs/plan.md` with epics, atomic stories, dependency order |
| `/sync-linear` | Push the plan to Linear as epics/stories with blocking relations |
| `/audit` | Post-epic audit: tech debt + requirements-alignment vs spec/plan |
| `/create-prd "description"` | Discovery interview → comprehensive PRD (heavier than /spec) |
| `/read-gdoc [url]` | Fetch and parse Google Docs as Markdown |

The `build` **skill** closes the loop: `/build ENG-123` runs a full TDD cycle per story.

### Rules

Always-loaded standards — deliberately lean (keep your global CLAUDE.md under 200 lines; move task-specific material into skills):

| Rule | Focus |
|------|-------|
| **coding-style.md** | TypeScript best practices, naming, DRY, file organization |
| **git-workflow.md** | Conventional commits, branch and PR hygiene |
| **security.md** | Secrets handling, input validation |
| **caveman.md** | Opt-in terse response mode ("caveman mode") for token savings |

### Skills

On-demand capabilities — they cost no context until invoked:

| Skill | Description |
|-------|-------------|
| **build** | Unified TDD workflow per story (tests → implement → verify → commit → update Linear) |
| **loop-maker** | Scaffold self-running, self-verifying agent loops (contract + two-tier verification). Successor to Ralph. Fork of [EricTechPro/loop-maker](https://github.com/EricTechPro/loop-maker) with a Karpathy LOOPS.md-style upgrade |
| **codemap-updater** | Generate CODEMAP.md files for codebase navigation |
| **diagrams** | Mermaid-first diagram standards and beautiful-mermaid theming |
| **ui-implementation** | Tactical UI checklist: shadcn/ui, forms, focus, loading states, a11y |
| **web-design-guidelines** | Audit UI code against Vercel's Web Interface Guidelines (fetched fresh each run) |

### Hooks

Safety mechanisms that run before/after tool execution:

| Hook | Protection |
|------|------------|
| **block-dangerous-commands.py** | Blocks `rm -rf`, `git push --force`, etc. |
| **prettier-before-push.sh** | Blocks `git push` when outgoing files fail `prettier --check` (never rewrites your commits) |
| **hooks.json** | Example warnings: npm vs pnpm, stray markdown creation, console.log |

## Directory Structure

```
claude-code-tools/
├── agents/           # Custom subagents
├── commands/         # Slash commands (pipeline)
├── rules/            # Always-loaded standards
├── skills/           # On-demand capabilities
├── hooks/            # Safety guards
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
---

Instructions for the agent...
```

Omit `model:` to inherit the session model (recommended); write subagent prompts to state assumptions and proceed — subagents run one-shot and cannot ask you questions mid-task.

### Adding Your Own Skills

Create `~/.claude/skills/my-skill/SKILL.md`:

```markdown
---
name: my-skill
description: One sentence Claude uses to decide when to auto-invoke this.
---

Instructions loaded when the skill triggers (also callable as /my-skill)...
```

Prefer skills over always-loaded rules for anything task-specific — they load on demand and keep your context lean.

### Adding Your Own Rules

Create a markdown file in `~/.claude/rules/`. Add `paths:` frontmatter to scope a rule to specific file types so it only loads when relevant:

```markdown
---
paths:
  - "**/*.ts"
  - "**/*.tsx"
---

# My TypeScript Rules
```

## Requirements

- Node.js 20+
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

Built for the Claude Code community. `loop-maker` is forked from [EricTechPro/loop-maker](https://github.com/EricTechPro/loop-maker) (MIT). Inspired by the need for consistent, high-quality AI-assisted development workflows.
