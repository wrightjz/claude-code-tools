# Agent Delegation Rules

## When to Use Subagents

Use subagents when:
- A task benefits from focused context
- Parallel workstreams don't overlap
- A specialized agent matches the task
- Main context is getting crowded

## Agent Selection Guide

| Task Type | Agent | Model |
|-----------|-------|-------|
| Feature planning & breakdown | **planner** | Sonnet |
| Write tests first | **tdd-guide** | Sonnet |
| System design decisions | **systems-architect** | Opus |
| PRD creation/refinement | **product-manager** | Opus |
| UI/UX design | **ui-ux-designer** | Sonnet |
| Clean code from specs | **elegant-code-architect** | Opus |
| Deep codebase audit & tech debt | **codebase-auditor** | Opus |
| Workflow design | **workflow-architect** | Opus |
| Workflow implementation | **workflow-implementer** | Sonnet |
| Build/type errors | **build-error-resolver** | Haiku |

## Model Selection Logic

| Model | Use For | Context Cost |
|-------|---------|--------------|
| **Haiku** | Quick fixes, simple tasks, fast lookups | Lowest |
| **Sonnet** | Standard dev, research, execution | Medium |
| **Opus** | Complex planning, architecture, deep analysis | Highest |

## Delegation Best Practices

1. **Provide clear instructions**: Give subagents specific, actionable prompts
2. **Include relevant context**: Share what they'll need to do the job
3. **Let them complete**: Don't interrupt subagent work prematurely
4. **Review output**: Verify subagent results before proceeding

## Context Management

- **Fork conversations** for parallel non-overlapping work (`/fork`)
- **Use subagents** to offload exploration (preserve main context)
- **Compact context** when it gets heavy (`/compact`)
- **Don't spawn** too many concurrent agents

## Common Delegation Patterns

### New Feature Development
```
1. planner → Break down the feature
2. tdd-guide → Write tests first
3. elegant-code-architect → Implement
4. codebase-auditor → Deep cleanup if needed
```

### Architecture Work
```
1. product-manager → Create/refine PRD
2. systems-architect → Design architecture
3. planner → Break into tasks
4. elegant-code-architect → Implement
```

### Bug Fixing
```
1. build-error-resolver → Fix immediate errors
2. tdd-guide → Add test for the bug
3. elegant-code-architect → Fix properly
```

### UI Feature
```
1. ui-ux-designer → Design the interface
2. planner → Break into tasks
3. elegant-code-architect → Implement
```

## When NOT to Delegate

- Simple, one-off tasks (just do them)
- When context is already minimal
- Quick questions or lookups
- Tasks that require full conversation history
