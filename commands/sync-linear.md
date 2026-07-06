# Sync Linear Command

Syncs a plan.md to Linear, creating tickets for each story with proper hierarchy, assignments, and estimates.

## Command Syntax

```
/sync-linear docs/plan.md              # Sync plan to Linear
/sync-linear docs/plan.md --team ENG   # Specify team
/sync-linear docs/plan.md --dry-run    # Preview without creating
```

**Parameters**:
- `PLAN_PATH` (required): Path to plan.md file
- `--team` (optional): Linear team key (prompts if not provided)
- `--dry-run` (optional): Show what would be created without creating

## Output

- Linear tickets created for each story
- `docs/plan.md` updated with ticket IDs
- Summary of created tickets

---

## Process

### Step 1: Parse Plan

```
1. Read plan.md file
2. Extract:
   - Project name and description
   - Epics (as parent issues or projects)
   - Stories with:
     - ID (E1-S1 format)
     - Title
     - Goal
     - Acceptance criteria
     - Size (XS/S/M)
     - Dependencies
     - Technical notes
   - Execution order
```

### Step 2: Determine Team and User

```
If --team not provided:
  1. List available teams using mcp__claude_ai_Linear__list_teams
  2. Ask user to select team

Get current user:
  - Use mcp__claude_ai_Linear__get_user with query: "me"
  - Use this for assignment
```

### Step 3: Map Sizes to Estimates

| Size | Story Points | Rationale |
|------|-------------|-----------|
| XS | 1 | < 1 hour, trivial change |
| S | 2 | 1-2 hours, small feature |
| M | 3 | 2-4 hours, moderate complexity |

### Step 4: Create Epic Issues (Parent)

For each epic in the plan:

```
Use mcp__claude_ai_Linear__save_issue:
  - team: [selected team]
  - title: "Epic: [Epic Name]"
  - description: [Epic goal + story count]
  - labels: ["epic"]
  - state: "Backlog" or "Todo"
```

### Step 5: Create Story Issues

For each story, in execution order:

```
Use mcp__claude_ai_Linear__save_issue:
  - team: [selected team]
  - title: [Story Title]
  - description: [Formatted from story details - see template below]
  - assignee: "me"
  - parentId: [Epic issue ID]
  - estimate: [Story points from size]
  - state: "Todo" (first story) or "Backlog" (others)
  - labels: ["story", epic-name-slug]
```

**Story Description Template**:
```markdown
## Goal
[Story goal]

## Acceptance Criteria
- [ ] [Criterion 1]
- [ ] [Criterion 2]
- [ ] Tests pass

## Technical Notes
[Technical notes from plan]

## Dependencies
- Depends on: [List of dependency ticket IDs]

---
*Plan ID: [E1-S1]*
*Source: [path/to/plan.md]*
```

### Step 6: Set Up Blocking Relations

After all issues are created, set up dependencies:

```
For each story with dependencies:
  Use mcp__claude_ai_Linear__save_issue with the story's id and its
  blocking-relation field (check the tool schema for the current
  parameter name, e.g. blockedBy/relations) set to the dependency issue IDs.
```

### Step 7: Update Plan with Ticket IDs

Update the plan.md file to include Linear ticket IDs:

```markdown
### Story 1.1: Create ThemeContext and Provider

**ID**: `E1-S1`
**Linear**: [ENG-123](https://linear.app/team/issue/ENG-123)  <!-- Added -->
**Size**: S
...
```

### Step 8: Output Summary

```markdown
## Linear Sync Complete

**Project**: [Project Name]
**Team**: [Team Name]
**Tickets Created**: [count]

### Epics
| Epic | Ticket | Stories |
|------|--------|---------|
| [Epic Name] | [ENG-100] | 3 |
| [Epic Name] | [ENG-104] | 2 |

### Stories (Execution Order)
| Order | Plan ID | Ticket | Title | Status |
|-------|---------|--------|-------|--------|
| 1 | E1-S1 | ENG-101 | [Title] | Todo |
| 2 | E1-S2 | ENG-102 | [Title] | Backlog |
| 3 | E1-S3 | ENG-103 | [Title] | Backlog |
| ... | ... | ... | ... | ... |

### Next Steps
1. Review tickets in Linear: [link to board filtered by epic]
2. Start building: `/build ENG-101`
3. Or run autonomously: use the loop-maker skill with docs/plan.md as the work source

---
*Synced by /sync-linear command*
```

---

## Dry Run Mode

When `--dry-run` is specified:

```
1. Parse plan normally
2. Show what WOULD be created:

## Dry Run: Linear Sync Preview

**Would create in team**: [Team Name]
**Total tickets**: [count]

### Epics to Create
1. "Epic: Theme Infrastructure" (3 child stories)
2. "Epic: Theme UI" (2 child stories)

### Stories to Create
| Order | Plan ID | Title | Size | Points | Depends On |
|-------|---------|-------|------|--------|------------|
| 1 | E1-S1 | Create ThemeContext | S | 2 | - |
| 2 | E1-S2 | Add localStorage | XS | 1 | E1-S1 |
| ... | ... | ... | ... | ... | ... |

**Run without --dry-run to create these tickets.**
```

---

## Handling Existing Tickets

If plan.md already has Linear ticket IDs:

```
1. Check if tickets exist in Linear
2. If exist and unchanged: Skip
3. If exist but changed: Prompt to update or skip
4. If not exist: Create new
```

This allows re-running sync after plan updates.

---

## Configuration

The command detects/prompts for:

| Config | Detection | Fallback |
|--------|-----------|----------|
| Team | `--team` flag, previous sync | Prompt user |
| User | Linear MCP "me" query | Prompt user |
| Labels | Check if "epic", "story" exist | Create if missing |
| States | List team states | Use defaults |

---

## Error Handling

### Plan Parsing Errors
```
If plan.md is malformed:
  - Show specific parsing error
  - Point to the problematic section
  - Do not create any tickets
```

### Linear API Errors
```
If ticket creation fails:
  - Log the error with context
  - Continue with remaining tickets
  - Report partial success at end
  - Provide manual creation instructions for failed items
```

### Rate Limiting
```
If rate limited:
  - Pause and retry with backoff
  - Report progress percentage
```

---

## Example Session

```
User: /sync-linear docs/plan.md

Agent:
Reading plan from docs/plan.md...

Found:
- Project: Dark Mode Toggle
- Epics: 2
- Stories: 5

Which team should I create these tickets in?
A) ENG - Engineering
B) SOLN - Solutions
C) Other (specify)

User: A

Agent:
Creating tickets in ENG team, assigned to you (justin@example.com)...

Creating epics...
  ✓ ENG-200: Epic: Theme Infrastructure
  ✓ ENG-201: Epic: Theme UI

Creating stories...
  ✓ ENG-202: Create ThemeContext and Provider (2 pts) → Todo
  ✓ ENG-203: Add localStorage Persistence (1 pt) → Backlog
  ✓ ENG-204: Apply Theme to Document (1 pt) → Backlog
  ✓ ENG-205: Create ThemeToggle Component (2 pts) → Backlog
  ✓ ENG-206: Add Toggle to Settings Page (1 pt) → Backlog

Setting up dependencies...
  ✓ ENG-203 blocked by ENG-202
  ✓ ENG-204 blocked by ENG-202
  ✓ ENG-205 blocked by ENG-202
  ✓ ENG-206 blocked by ENG-205

Updating docs/plan.md with ticket IDs...
  ✓ Plan updated

## Sync Complete

**Tickets Created**: 7 (2 epics, 5 stories)
**Team**: ENG
**Total Points**: 7

View in Linear: https://linear.app/yourteam/project/dark-mode-toggle

### Next Steps
Start building the first story:
  /build ENG-202
```

---

## Integration with /build

After sync, the `/build` skill can:

1. **Pull story details from Linear** using the ticket ID
2. **Update ticket status** as work progresses
3. **Add implementation comments** when complete
4. **Move to next story** based on execution order

The plan.md with ticket IDs serves as the bridge:
- `/sync-linear` creates the structure
- `/build` executes against it
- Linear becomes the source of truth for status

---

## Tips

1. **Sync early**: Create tickets before starting implementation
2. **Use dry-run first**: Verify the structure before creating
3. **Re-sync after changes**: Update tickets if plan changes
4. **Keep plan.md updated**: It's your local reference with ticket links
5. **One sync per project**: Don't create duplicate ticket sets

---

*Version: 1.0 - Plan to Linear synchronization*
