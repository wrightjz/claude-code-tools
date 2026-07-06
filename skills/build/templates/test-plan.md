# Test Plan Template

Use this template to plan tests before writing implementation code.

---

## Test Plan: [Story Title]

**Story ID**: [TICKET-ID or reference]
**Test File**: [path/to/test/file.test.ts]

---

### Happy Path Tests

Tests that verify the feature works correctly under normal conditions.

| # | Test Name | Input | Expected Output | Priority |
|---|-----------|-------|-----------------|----------|
| 1 | should [behavior] when [condition] | [input] | [output] | P0 |
| 2 | should [behavior] when [condition] | [input] | [output] | P0 |

---

### Edge Case Tests

Tests for boundary conditions and unusual but valid inputs.

| # | Test Name | Input | Expected Output | Priority |
|---|-----------|-------|-----------------|----------|
| 3 | should [behavior] when [edge case] | [input] | [output] | P1 |
| 4 | should [behavior] when [boundary] | [input] | [output] | P1 |

---

### Error Case Tests

Tests for invalid inputs and failure scenarios.

| # | Test Name | Input | Expected Behavior | Priority |
|---|-----------|-------|-------------------|----------|
| 5 | should [error behavior] when [invalid input] | [input] | [throw/return error] | P1 |
| 6 | should [error behavior] when [failure condition] | [input] | [throw/return error] | P2 |

---

### Integration Tests (if applicable)

Tests that verify the feature works with other system components.

| # | Test Name | Setup Required | Verifies |
|---|-----------|----------------|----------|
| 7 | should [integration behavior] | [mock/stub needed] | [integration point] |

---

## Test Dependencies

- [ ] Mock: [external service/API to mock]
- [ ] Fixture: [test data needed]
- [ ] Setup: [database state, auth context, etc.]

---

## Test Order

Execute tests in this order (dependencies first):

1. [Test #] - [reason it's first]
2. [Test #] - [depends on #1]
3. ...

---

## Notes

- [Any implementation hints discovered during test planning]
- [Patterns observed in existing tests]
- [Potential complications to watch for]

---

*After all tests are written and failing, proceed to implementation.*
