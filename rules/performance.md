# Performance & Model Selection Rules

## Model Selection
| Task | Model | Reason |
|------|-------|--------|
| Quick questions, simple edits | Haiku | Fast, cheap |
| Standard development | Sonnet | Balanced |
| Complex architecture, planning | Opus | Best reasoning |
| Code review, refactoring | Opus 4.5 | Deep analysis |

## Context Window Management
- Keep under 10 MCPs enabled per project
- Target under 80 active tools total
- Disable unused MCPs in project config
- Use `/compact` when context gets heavy
- Monitor context % in status line

## Efficient Workflows
- Use subagents to preserve main context
- Fork conversations for parallel tasks
- Let exploration agents burn context, not main
- Batch related requests when possible

## MCP Management
- Configure all MCPs at user level
- Disable per-project in `disabledMcpServers`
- Enable only what you need for current work
- Heavy MCPs: playwright, full cloud integrations
