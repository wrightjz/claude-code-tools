# Build Completion Summary Template

Use this template to document the completion of a story build.

---

## Build Complete: [Story Title]

**Ticket**: [TICKET-ID] | Status: [New Status]
**Branch**: [branch-name]
**Commit**: [short-hash] `[commit message]`

---

### Changes Made

| File | Change Type | Description |
|------|-------------|-------------|
| `path/to/file.ts` | Modified | [what changed] |
| `path/to/new-file.ts` | Created | [what it does] |
| `path/to/test.test.ts` | Created | [tests for what] |

---

### Tests Added

**Test File**: `path/to/test.test.ts`

| Test | Status |
|------|--------|
| should [behavior 1] when [condition] | PASS |
| should [behavior 2] when [condition] | PASS |
| should [error behavior] when [invalid] | PASS |

**Coverage**: [X] tests added, all passing

---

### Quality Gates

| Gate | Status | Details |
|------|--------|---------|
| Tests | PASS | [X/Y passing] |
| TypeCheck | PASS | No errors |
| Lint | PASS | No warnings |
| Build | PASS | Compiled successfully |

---

### Acceptance Criteria Verification

- [x] [Criterion 1] - Verified by test: [test name]
- [x] [Criterion 2] - Verified by test: [test name]
- [x] [Criterion 3] - Verified by manual check: [what was checked]

---

### Linear Update

- **Previous State**: [Todo | In Progress]
- **New State**: [Done | In Review]
- **Comment Added**: [summary of implementation]

---

### Notes for Reviewers

- [Any important context for code review]
- [Decisions made during implementation]
- [Known limitations or future improvements]

---

### Next Steps

- [ ] [Suggested follow-up if any]
- [ ] [Related ticket to tackle next]

---

*Build completed at [timestamp]*
*Skill: /build*
