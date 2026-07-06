# Create PRD Command

## Overview
This command conducts a comprehensive product discovery interview to build a thorough Product Requirements Document. It systematically gathers requirements through strategic questioning, probing beyond surface-level answers to uncover underlying needs, constraints, and tradeoffs. This is the sole PRD tool — run the interview and produce the documents in the main session.

## Command Syntax
```
/create-prd "DESCRIPTION"
```

**Parameters:**
- `DESCRIPTION` (required): A brief description of the product or feature to be specified

## Output Artifacts

1. **In-Depth PRD** (`prd-[project-name].md`) — comprehensive technical specification with acceptance criteria and full edge case coverage. Audience: engineering teams.
2. **One-Pager** (`one-pager-[project-name].md`) — architecture overview, key components, critical technical decisions. Audience: engineers who need the gist quickly.

---

## Interview Framework

### Phase 1: Problem Space Exploration

Begin by understanding the fundamental "why" before the "what" (use AskUserQuestion):
- What problem are we solving, and how do users currently work around it?
- Who experiences this problem most acutely? What's their context?
- What happens if we don't solve this? What's the cost of inaction?
- What triggered the need to solve this now?

### Phase 2: User & Context Deep Dive

**User Understanding**:
- Walk me through a day in the life of your primary user
- What adjacent tasks surround this feature? What happens before/after?
- Who else is affected indirectly (managers, admins, downstream systems)?
- What existing mental models do users have that we should leverage or avoid?

**Context & Constraints**:
- What technical environment does this live in (platforms, devices, connectivity)?
- Are there regulatory, compliance, or legal constraints?
- What organizational politics or historical decisions should I know about?
- Are there seasonal or temporal factors (usage spikes, deadlines)?

### Phase 3: Solution Boundaries

**Scope Definition**:
- If you could only ship ONE thing, what would it be?
- What features might stakeholders expect but should be explicitly excluded?
- What would a "minimum lovable" version look like vs. the full vision?
- Are there adjacent problems we should intentionally ignore for now?

**Success Criteria**:
- How will users know this is working for them?
- What behavior change do we expect to see?
- What metrics would make you confident this succeeded?
- What would failure look like?

### Phase 4: UI/UX Considerations (When Applicable)

**Interaction Design**:
- How should users discover this feature?
- What's the ideal "first encounter" experience?
- How much learning curve is acceptable?
- What accessibility requirements exist (WCAG levels, assistive tech)?

**Visual & Behavioral**:
- What emotional response should the UI evoke?
- Are there existing design patterns or component libraries to follow?
- What feedback should users receive during and after actions?
- How should errors be communicated?

**Responsive & Adaptive**:
- What devices and viewport sizes matter most?
- Are there offline or degraded connectivity scenarios?
- Should behavior differ across platforms (web, mobile, desktop)?

### Phase 5: Technical Landscape

**Stack & Architecture**:
- What's the current tech stack this integrates with?
- Are there preferred languages, frameworks, or patterns to use?
- What data stores or services does this depend on?
- Are there performance budgets (load time, response time, memory)?

**Integration Points**:
- What APIs or services does this need to call?
- What events should this emit for other systems?
- Are there authentication/authorization requirements?
- What data needs to flow in and out?

**Operational Concerns**:
- What monitoring and alerting is expected?
- How should this be deployed (feature flags, gradual rollout)?
- What's the disaster recovery expectation?
- Who will maintain this long-term?

### Phase 6: Risks & Tradeoffs

**Risk Identification**:
- What's the biggest technical risk? The biggest product risk?
- What assumptions are we making that could be wrong?
- What dependencies could block or delay this?
- What security vulnerabilities should we be paranoid about?

**Tradeoff Forcing**:
- If we had to cut the timeline in half, what would we sacrifice?
- Build vs. buy for key components—what's your instinct?
- Speed vs. quality—where should we be on this spectrum?
- Flexibility vs. simplicity—should this be configurable or opinionated?

### Phase 7: Edge Cases & Error States

**Boundary Conditions**:
- What happens at zero? At one? At a million?
- What if users do things in an unexpected order?
- What if required data is missing or malformed?
- What if external services are slow or unavailable?

**Recovery Paths**:
- How do users recover from mistakes?
- What can be undone? What's permanent?
- How do we handle partial failures?
- What's the support escalation path?

---

## Interview Execution Guidelines

1. **Never ask more than 3-4 questions at once** - Group by theme, wait for responses
2. **Explain the "why" behind non-obvious questions** - Build trust and get better answers
3. **Offer options for open-ended questions** - Reduce cognitive load while gathering signal
4. **Probe vague answers** - "Fast" means what exactly? Under what conditions?
5. **Listen for what's NOT said** - Gaps often reveal assumptions

### Adaptive Questioning

| Project Type | Emphasis Areas |
|-------------|----------------|
| New Product | Problem validation, user research, market context |
| Feature Addition | Integration points, existing patterns, scope creep risk |
| Refactor/Migration | Current state pain, rollback plan, parity requirements |
| Performance Work | Baseline metrics, target metrics, measurement method |
| Infrastructure | Reliability requirements, operational burden, blast radius |

### Completeness & Quality Checklist

Continue interviewing until you can confidently answer, and verify before considering the PRD done:
- [ ] Could a senior engineer build this without asking me questions?
- [ ] Have I challenged at least 3 assumptions the user held?
- [ ] Do I understand the "why" behind every requirement?
- [ ] Have I explored what happens when things go wrong?
- [ ] Are scope boundaries explicit and agreed upon?
- [ ] Are success metrics concrete, measurable, and actually measuring the stated goals?
- [ ] Have we discussed what we're NOT building?
- [ ] Is every requirement testable? (No unquantified "fast", "easy", "seamless")
- [ ] Do any requirements conflict with each other?
- [ ] Are priorities clear (P0/P1/P2) and dependencies identified?

---

## Document Generation

**1. In-Depth PRD** (`prd-[project-name].md`) structure:

```markdown
# [Project Name] - Product Requirements Document

## Document Info
- **Author** / **Created** / **Status**: Draft | Under Review | Approved

## Executive Summary
[Problem + Solution + Key metrics in 3-4 sentences]

## Background & Context
[Current state, pain points, why now, stakeholders and their interests]

## Goals
[Bulleted list of specific, measurable outcomes]

## Non-Goals
[Explicit exclusions with brief rationale]

## User Personas
[Each persona with context, needs, and goals]

## User Stories & Requirements
["As a [persona], I want to [action] so that [benefit]" with acceptance criteria]
- P0 (Must Have) / P1 (Should Have) / P2 (Nice to Have)

## Functional Specifications
[Detailed feature specs, user flows, business rules, data requirements]

## UI/UX Requirements
[Interaction patterns, wireframe descriptions, accessibility]

## Non-Functional Requirements
### Performance (latency, throughput) & Scalability
### Security & Compliance
### Accessibility Standards
### Reliability / Availability Targets

## Technical Requirements
### Architecture Considerations
### Integration Points

## Edge Cases & Error Handling
[Boundary conditions, error states, recovery paths, graceful degradation]

## Dependencies
[External systems, teams, services, API contracts]

## Success Metrics & Monitoring
[KPIs with measurement methodology, instrumentation, alerting thresholds]

## Rollout Strategy
[Phasing, feature flags, rollback plan]

## Open Questions
[Unresolved items with owners and deadlines]

## Risks & Mitigations

## Appendix
[Glossary, references, revision history]
```

**2. One-Pager** (`one-pager-[project-name].md`) structure:

```markdown
# [Project Name] - Technical One-Pager

## TL;DR
[2-3 sentences: what we're building and why]

## Architecture Overview
[High-level description + Mermaid diagram of component relationships]

## Key Components
| Component | Purpose | Tech/Approach |

## Data Model
[Core entities and relationships - keep it brief]

## API Surface
- `POST /endpoint` - [what it does]

## Technical Decisions
| Decision | Choice | Why |

## Dependencies
- **External** / **Internal**

## Performance Requirements
- Latency / Throughput / Availability targets

## Security Considerations

## Scope Boundaries
**Building**: [bullets]  **Not Building**: [bullets]

## Known Risks
| Risk | Mitigation |

## Open Technical Questions
- [ ] [Question] - blocks: [what it blocks]

---
*Full PRD: prd-[project-name].md*
```

---

## Best Practices

1. **Patience Over Speed**: A thorough 30-minute interview beats a rushed 10-minute one
2. **Probe, Don't Accept**: Vague answers need follow-up questions
3. **Challenge Respectfully**: Your job is to find gaps before engineering does — present tradeoffs, not mandates; the user decides
4. **Document Decisions**: Capture not just what was decided, but why
5. **Explicit Non-Goals**: What we're NOT building is as important as what we are
6. **Quantify Everything**: "Fast" and "easy" are meaningless without numbers
7. **Think in Failures**: Great specs anticipate what goes wrong

---

*Version: 2.0 - Sole PRD tool; folded in PM quality standards; trimmed examples*
