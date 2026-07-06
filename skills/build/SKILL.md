---
name: build
description: "Unified TDD workflow for implementing stories. Works with Linear tickets, plan.md, or inline descriptions. Executes: write tests → implement → verify → commit → update Linear → suggest next. Integrates with /spec → /plan → /sync-linear pipeline."
---

# Build Skill

Executes a complete TDD implementation cycle for stories, fully integrated with the development pipeline.

## Invocation

```
/build TICKET-ID           # Build from Linear ticket (e.g., /build ENG-123)
/build E1-S1               # Build from plan.md story ID
/build next                # Build next story from plan.md execution order
/build "story description" # Build from inline description
/build                     # Interactive - shows options
```

## Pipeline Integration

```
┌─────────────────────────────────────────────────────────────────────┐
│  FULL PIPELINE                                                       │
│                                                                      │
│  /spec → docs/spec.md                                               │
│      ↓                                                               │
│  /plan → docs/plan.md                                               │
│      ↓                                                               │
│  /sync-linear → Linear tickets + plan.md updated with IDs           │
│      ↓                                                               │
│  /build → TDD implementation cycle (repeats per story)              │
│      ↓                                                               │
│  /audit → Codebase cleanup after epic                               │
└─────────────────────────────────────────────────────────────────────┘
```

The `/build` skill is aware of:
- **plan.md**: Reads execution order, dependencies, story details
- **Linear**: Fetches ticket details, updates status, adds comments
- **Previous builds**: Knows what's been completed via git history + plan state

---

## Workflow Overview

```
┌─────────────────────────────────────────────────────────────────────┐
│                         /build [TARGET]                              │
└─────────────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────────┐
│  Phase 0: Context Loading                                           │
│  - Check for docs/plan.md                                           │
│  - Identify completed vs pending stories                            │
│  - Resolve target to specific story                                 │
└─────────────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────────┐
│  Phase 1: Story Intake                                              │
│  - Fetch from Linear if ticket ID                                   │
│  - Parse from plan.md if story ID                                   │
│  - Extract acceptance criteria                                      │
│  - Check dependencies are satisfied                                 │
└─────────────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────────┐
│  Phase 2: Test Planning (TDD Red)                                   │
│  - Analyze acceptance criteria                                      │
│  - List test cases needed                                           │
│  - Write failing tests                                              │
│  - Verify tests fail for the right reason                           │
└─────────────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────────┐
│  Phase 3: Implementation (TDD Green)                                │
│  - Write minimum code to pass tests                                 │
│  - Follow existing patterns in codebase                             │
│  - No over-engineering                                              │
│  - Run tests after each change                                      │
└─────────────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────────┐
│  Phase 4: Refactor (TDD Refactor)                                   │
│  - Clean up implementation                                          │
│  - Ensure code follows project conventions                          │
│  - Tests must stay green                                            │
│  - Keep changes minimal and focused                                 │
└─────────────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────────┐
│  Phase 5: Quality Gates                                             │
│  - Run full test suite                                              │
│  - Run typecheck (if applicable)                                    │
│  - Run linter (if applicable)                                       │
│  - All must pass before proceeding                                  │
└─────────────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────────┐
│  Phase 6: Commit & Update                                           │
│  - Stage relevant files                                             │
│  - Commit with conventional message                                 │
│  - Update Linear ticket status                                      │
│  - Mark story complete in plan.md                                   │
│  - Output completion summary with next story                        │
└─────────────────────────────────────────────────────────────────────┘
```

---

## Phase 0: Context Loading

**Always runs first to understand the current state.**

```
1. Check for docs/plan.md
   - If exists: Parse execution order, identify completed stories
   - If not: Proceed without plan context

2. Check for Linear integration
   - If plan has ticket IDs: Can update Linear
   - If no ticket IDs: Local-only mode

3. Resolve the target:
   - "next" → First incomplete story in execution order
   - "E1-S2" → Specific story from plan
   - "ENG-123" → Linear ticket (cross-reference with plan if exists)
   - Description → Create ad-hoc story

4. Verify dependencies:
   - Check if blocking stories are complete
   - Warn if dependencies not satisfied (but allow override)
```

**Context Summary Output:**
```markdown
## Build Context

**Plan**: docs/plan.md (5 stories, 2 complete)
**Target**: E1-S3 - Apply Theme to Document
**Linear**: ENG-204

**Dependencies**:
- [x] E1-S1 (ENG-202) - Complete
- [x] E1-S2 (ENG-203) - Complete

Ready to proceed.
```

---

## Phase 1: Story Intake

### From Linear Ticket
```
1. Use mcp__claude_ai_Linear__get_issue with ticket ID
2. Extract:
   - Title → Story name
   - Description → Parse for acceptance criteria
   - Estimate → Expected complexity
   - State → Current status
   - Parent → Epic context
3. Cross-reference with plan.md for additional context
```

### From Plan Story ID
```
1. Parse plan.md for story with matching ID
2. Extract:
   - Title
   - Goal
   - Acceptance criteria
   - Technical notes
   - Dependencies
3. If Linear ticket ID exists, fetch additional context
```

### From "next"
```
1. Parse plan.md execution order
2. Find first story where:
   - Not marked complete in plan
   - Linear ticket not in "Done" state (if linked)
   - Dependencies are satisfied
3. Present story for confirmation
```

**Story Summary Template:**
```markdown
## Story: [Title]

**Plan ID**: [E1-S3] | **Linear**: [ENG-204]
**Size**: [S] | **Points**: [2]

**Goal**: [One sentence]

**Acceptance Criteria**:
- [ ] [Criterion 1]
- [ ] [Criterion 2]
- [ ] Tests pass

**Technical Notes**:
- [From plan.md]

**Dependencies**: All satisfied
- [x] E1-S1: Create ThemeContext
- [x] E1-S2: Add localStorage

Ready to proceed with TDD? (Confirm or adjust)
```

---

## Phase 2: Test Planning (Red)

Follow the TDD Guide approach:

```
1. Analyze each acceptance criterion
   - What behavior does it require?
   - What are the inputs and outputs?
   - What edge cases exist?

2. Create test case list:

   ## Test Cases for [Story]

   ### Happy Path
   - [ ] [Basic success case]
   - [ ] [Another valid scenario]

   ### Edge Cases
   - [ ] [Boundary condition]
   - [ ] [Empty/null input]

   ### Error Cases
   - [ ] [Invalid input]
   - [ ] [Failure scenario]

3. Write the tests (they should fail):
   - Use the project's existing test framework
   - Follow AAA pattern (Arrange, Act, Assert)
   - Descriptive test names: "should [behavior] when [condition]"

4. Run tests to confirm they fail:
   - "Tests failing as expected - ready for implementation"
   - If tests pass unexpectedly, investigate
```

**Test Template:**
```typescript
import { describe, it, expect } from 'vitest';

describe('[Feature/Function Name]', () => {
  describe('[Scenario Group]', () => {
    it('should [expected behavior] when [condition]', () => {
      // Arrange
      const input = {};

      // Act
      const result = functionUnderTest(input);

      // Assert
      expect(result).toEqual(expectedOutput);
    });
  });
});
```

---

## Phase 3: Implementation (Green)

```
1. Start with the simplest failing test
   - Write minimum code to make it pass
   - No extra features, no "while I'm here" improvements

2. Run tests after each change
   - One test passing at a time
   - If a test breaks, fix immediately

3. Follow existing patterns:
   - Check how similar features are implemented
   - Use project conventions (path aliases, naming, etc.)
   - Reuse existing utilities and components

4. Keep implementation focused:
   - Only code required for THIS story
   - No refactoring of surrounding code
   - No "nice to have" additions
```

---

## Phase 4: Refactor

```
1. All tests must be passing before refactor

2. Review implementation for:
   - Duplication that can be extracted
   - Names that could be clearer
   - Complex logic that can be simplified
   - Code that doesn't match project conventions

3. Make small refactoring changes:
   - Run tests after each change
   - If tests fail, revert and try differently

4. Keep refactoring minimal:
   - This is cleanup, not redesign
   - Stop when code is "good enough"
```

---

## Phase 5: Quality Gates

Run all quality checks. ALL must pass before commit.

```bash
# Typical quality gate commands (adapt to project):

# 1. Full test suite
pnpm test
# or: npm test, vitest, pytest, go test ./...

# 2. Type check (if TypeScript)
pnpm typecheck
# or: tsc --noEmit

# 3. Linter
pnpm lint
# or: eslint ., ruff check .

# 4. Build (optional but recommended)
pnpm build
```

**If any gate fails:**
```
1. Fix the issue
2. Re-run all gates
3. Do not proceed until all pass
4. If stuck after 3 attempts, report blocker
```

---

## Phase 6: Commit & Update

### Commit

**Format:**
```
feat(scope): [Ticket ID] - [Brief description]

[Optional body explaining the change]

Co-Authored-By: Claude <noreply@anthropic.com>
```

**Process:**
```bash
git add [specific files changed]
git commit -m "$(cat <<'EOF'
feat(theme): ENG-204 - Apply theme to document element

Syncs theme context with DOM via data-theme attribute.
Tests verify attribute updates on theme change.

Co-Authored-By: Claude <noreply@anthropic.com>
EOF
)"
```

### Update Linear

```
Use mcp__claude_ai_Linear__save_issue:
  - id: [ticket ID]
  - state: "Done"

Use mcp__claude_ai_Linear__save_comment:
  - issueId: [ticket ID]
  - body: [Implementation summary - see template]
```

**Linear Comment Template:**
```markdown
## Implementation Complete

### Changes
- `src/contexts/ThemeContext.tsx` - Added DOM sync effect
- `src/__tests__/ThemeContext.test.tsx` - Added 3 tests

### Tests
3 tests added, all passing

### Commit
`a1b2c3d` - feat(theme): ENG-204 - Apply theme to document element

---
*Built via /build skill*
```

### Update plan.md

Mark the story as complete:

```markdown
### Story 1.3: Apply Theme to Document

**ID**: `E1-S3`
**Linear**: [ENG-204](https://linear.app/...) ✅  <!-- Add checkmark -->
**Status**: Complete  <!-- Add status -->
**Completed**: 2024-01-15  <!-- Add date -->
...
```

### Completion Summary

```markdown
## Build Complete: Apply Theme to Document

**Story**: E1-S3 | **Ticket**: ENG-204 → Done
**Commit**: `a1b2c3d`

**Changes**:
- `src/contexts/ThemeContext.tsx`: Added DOM sync
- `src/__tests__/ThemeContext.test.tsx`: 3 tests

**Quality Gates**: All passing

---

## Next Story

**E2-S1**: Create ThemeToggle Component
**Linear**: ENG-205
**Dependencies**: ✅ All satisfied

Continue? `/build next` or `/build ENG-205`

---

## Epic Progress: Theme Infrastructure

[████████░░] 3/3 stories complete

🎉 **Epic Complete!**

Consider running `/audit` to clean up before starting next epic.
```

---

## Modes

### Single Story Mode (Default)
```
/build ENG-123
```
Builds one story, shows next suggestion, waits for user.

### Continuous Mode
```
/build --continue
```
After completing a story, automatically starts the next one.
Stops at epic boundaries for audit checkpoint.

### Epic Mode
```
/build --epic "Theme Infrastructure"
```
Builds all stories in the specified epic sequentially.
Runs audit at the end.

---

## Dependency Handling

### Satisfied Dependencies
```
Dependencies for E1-S3:
- [x] E1-S1 (ENG-202) - Complete
- [x] E1-S2 (ENG-203) - Complete

All dependencies satisfied. Proceeding.
```

### Unsatisfied Dependencies
```
Dependencies for E2-S2:
- [x] E2-S1 (ENG-205) - Complete
- [ ] E1-S3 (ENG-204) - IN PROGRESS

⚠️ Dependency E1-S3 is not complete.

Options:
A) Build E1-S3 first (recommended)
B) Override and build E2-S2 anyway (risky)
C) Cancel and review plan
```

---

## Error Handling

### Tests Won't Pass
```
After 3 implementation attempts:
1. Summarize what was tried
2. Identify the specific blocker
3. Ask user:
   A) Adjust the test expectation
   B) Try a different implementation approach
   C) Mark story as blocked in Linear and move on
```

### Quality Gate Failures
```
If typecheck/lint fails:
1. Attempt automatic fix
2. If still failing, show specific errors
3. Ask for guidance
```

### Linear Update Fails
```
If MCP call fails:
1. Log the failure
2. Continue with commit (don't block on Linear)
3. Provide manual update instructions
```

### Blocked Story
```
If user chooses to mark as blocked:
1. Update Linear: state → "Blocked", add blocker comment
2. Update plan.md: status → "Blocked"
3. Skip to next non-dependent story
```

---

## Configuration Detection

| Aspect | Detection Method | Fallback |
|--------|-----------------|----------|
| Plan file | `docs/plan.md` | No plan mode |
| Test framework | `vitest.config.*`, `jest.config.*` | Ask user |
| Test command | `package.json` scripts | `npm test` |
| Type check | `tsconfig.json` presence | Skip |
| Lint command | `package.json` scripts | Skip |
| Commit convention | Recent git history | `feat(scope): message` |

---

## Examples

### Example 1: Build Next from Plan

```
User: /build next

Agent:
## Build Context

**Plan**: docs/plan.md (5 stories, 2 complete)
**Next**: E1-S3 - Apply Theme to Document
**Linear**: ENG-204

**Dependencies**:
- [x] E1-S1 (ENG-202) - Complete
- [x] E1-S2 (ENG-203) - Complete

## Story: Apply Theme to Document

**Goal**: Theme value reflects in DOM for CSS targeting

**Acceptance Criteria**:
- [ ] data-theme attribute set on document.documentElement
- [ ] Attribute updates when theme changes
- [ ] Tests pass

Proceeding with TDD...

[... TDD cycle ...]

## Build Complete

Continue with next story?
- E2-S1: Create ThemeToggle Component (ENG-205)
```

### Example 2: Build Specific Linear Ticket

```
User: /build ENG-456

Agent:
Fetching ENG-456 from Linear...

## Story: Add rate limiting to API endpoints

**Linear**: ENG-456 (not in plan.md - standalone ticket)

**Goal**: Prevent API abuse by limiting requests per user

**Acceptance Criteria**:
- [ ] 100 requests/minute/user limit
- [ ] 429 status when exceeded
- [ ] Retry-After header included

No plan.md context - proceeding as standalone story.

[... TDD cycle ...]
```

### Example 3: Epic Complete Flow

```
Agent:
## Build Complete: Add Toggle to Settings Page

**Story**: E2-S2 | **Ticket**: ENG-206 → Done

---

## Epic Progress: Theme UI

[██████████] 2/2 stories complete

🎉 **Epic Complete: Theme UI**

All stories in this epic are done.

**Recommendation**: Run `/audit` to:
- Clean up any accumulated complexity
- Ensure consistent patterns across the epic
- Verify all tests still pass

Then continue to next epic or merge.
```

---

## Autonomous execution

For fully autonomous execution, use the **loop-maker** skill with `docs/plan.md` as the work source — it scaffolds a self-running loop (contract + two-tier verification) that works through the stories unattended. The `/build` skill is the manual, interactive version of that loop.

---

## Templates Reference

All templates are in `skills/build/templates/`:
- `story-summary.md` - Story intake format
- `test-plan.md` - Test case planning
- `test-file.ts` - Vitest test scaffold
- `completion-summary.md` - Build completion report
- `linear-comment.md` - Linear update comment

---

*Version: 2.0 - Full pipeline integration with plan.md and Linear*
