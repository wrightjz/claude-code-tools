# Audit Command

Deep codebase audit with requirements alignment check. Unlike `/simplify` (quick cleanup of changed code), `/audit` performs a comprehensive two-phase review: first identifying technical debt and simplification opportunities, then verifying the codebase aligns with original requirements.

## Command Syntax

```
/audit                           # Full audit (audit + alignment)
/audit docs/spec.md              # Audit with specific spec for alignment
/audit --code-only               # Skip alignment check (just codebase audit)
/audit --alignment-only          # Skip audit (just requirements alignment)
```

---

## Phase 1: Deep Codebase Audit (codebase-auditor)

Launch the **codebase-auditor** agent with the following task:

```
Perform a deep codebase audit. Analyze the entire codebase systematically to identify:
1. Dead code that can be deleted
2. Unnecessary abstractions and over-engineering
3. Duplication that can be consolidated
4. Unused dependencies
5. Verbose patterns that can be simplified

Follow your full review process (survey, dead code detection, abstraction analysis,
duplication check, dependency audit, verbosity review).

Generate your risk-tiered Code Simplification Report. Apply zero-risk cleanups
directly with test verification after each; list riskier items as recommendations.
```

Wait for codebase-auditor to complete before proceeding to Phase 2. The agent carries its own report format.

## Phase 2: Requirements Alignment Check (systems-architect)

Launch the **systems-architect** agent with the following task:

```
Perform a requirements alignment review: verify the current implementation aligns
with the original requirements.

1. Locate requirements documents: docs/spec.md, docs/plan.md, any PRD files in
   docs/, Linear tickets if accessible via MCP.
2. For each requirement/story: verify it's implemented, matches acceptance
   criteria, and note deviations or gaps.
3. Classify: fully implemented / partially implemented / missing / scope creep /
   technical deviations from plan.
4. Produce an Alignment Report: summary, per-requirement status table, gaps
   requiring attention, and recommendations for addressing each gap.
```

Relay both reports to the user, with the risky/gap items framed as recommendations for them to decide on.

---

## When to Use /audit vs /simplify

| Use `/audit` when... | Use `/simplify` when... |
|----------------------|-------------------------|
| End of epic/milestone | After a single feature |
| Before handoff | Quick cleanup during dev |
| Periodic maintenance | Remove console.logs |
| Deep tech debt review | Fix verbose patterns in changed code |
| Need requirements alignment check | Just code cleanup |

**Best Practice**: Run `/audit` after completing an epic or before merging to main (`/spec → /plan → /sync-linear → /build → /audit → merge`).

*Version: 2.0 - Trimmed; quick-cleanup comparisons now point to /simplify*
