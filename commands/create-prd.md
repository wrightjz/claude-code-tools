# Create PRD Command

## Overview
This command conducts a comprehensive product discovery interview to build a thorough Product Requirements Document. It systematically gathers requirements through strategic questioning, probing beyond surface-level answers to uncover underlying needs, constraints, and tradeoffs.

## Command Syntax
```
/create-prd "DESCRIPTION"
```

**Parameters:**
- `DESCRIPTION` (required): A brief description of the product or feature to be specified

## Output Artifacts

This command produces two documents:

1. **In-Depth PRD** (`prd-[project-name].md`)
   - Comprehensive technical specification
   - Detailed requirements with acceptance criteria
   - Full edge case coverage
   - Audience: Engineering teams

2. **One-Pager** (`one-pager-[project-name].md`)
   - Technical summary format
   - Architecture overview and key components
   - Critical technical decisions and tradeoffs
   - Audience: Engineers who need the gist quickly

---

## Interview Framework

### Phase 1: Problem Space Exploration

Begin by understanding the fundamental "why" before the "what":

**Opening Questions** (use AskUserQuestion):
- What problem are we solving, and how do users currently work around it?
- Who experiences this problem most acutely? What's their context?
- What happens if we don't solve this? What's the cost of inaction?
- What triggered the need to solve this now?

### Phase 2: User & Context Deep Dive

Probe into user personas, journeys, and environmental context:

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

Define what we're building and explicitly what we're NOT:

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

For user-facing features, explore the experience layer:

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

Understand the engineering context and constraints:

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

Surface concerns and force prioritization decisions:

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

The questions that separate good specs from great ones:

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

### Question Strategy

1. **Never ask more than 3-4 questions at once** - Group by theme, wait for responses
2. **Explain the "why" behind non-obvious questions** - Build trust and get better answers
3. **Offer options for open-ended questions** - Reduce cognitive load while gathering signal
4. **Probe vague answers** - "Fast" means what exactly? Under what conditions?
5. **Listen for what's NOT said** - Gaps often reveal assumptions

### Adaptive Questioning

Adjust your approach based on the project type:

| Project Type | Emphasis Areas |
|-------------|----------------|
| New Product | Problem validation, user research, market context |
| Feature Addition | Integration points, existing patterns, scope creep risk |
| Refactor/Migration | Current state pain, rollback plan, parity requirements |
| Performance Work | Baseline metrics, target metrics, measurement method |
| Infrastructure | Reliability requirements, operational burden, blast radius |

### Interview Completeness Signals

Continue interviewing until you can confidently answer:
- [ ] Could an engineer build this without asking me questions?
- [ ] Have I challenged at least 3 assumptions the user held?
- [ ] Do I understand the "why" behind every requirement?
- [ ] Have I explored what happens when things go wrong?
- [ ] Are scope boundaries explicit and agreed upon?
- [ ] Are success metrics concrete and measurable?
- [ ] Have we discussed what we're NOT building?

---

## Document Generation

### When Interview Is Complete

After gathering sufficient information through the interview process:

**1. Generate In-Depth PRD** (`prd-[project-name].md`)

Structure:
```markdown
# [Project Name] - Product Requirements Document

## Document Info
- **Author**: [User name if known]
- **Created**: [Date]
- **Status**: Draft | Under Review | Approved

## Executive Summary
[Problem + Solution + Key metrics in 3-4 sentences]

## Background & Context
[Current state, pain points, why now]

## Goals
[Bulleted list of specific, measurable outcomes]

## Non-Goals
[Explicit exclusions with brief rationale]

## User Personas
[Each persona with context, needs, and goals]

## User Stories & Requirements
[Prioritized list with acceptance criteria]
- P0 (Must Have): ...
- P1 (Should Have): ...
- P2 (Nice to Have): ...

## Functional Specifications
[Detailed feature specs with user flows]

## UI/UX Requirements
[Interaction patterns, wireframe descriptions, accessibility]

## Technical Requirements
### Architecture Considerations
### Performance Requirements
### Security Requirements
### Integration Points

## Edge Cases & Error Handling
[Comprehensive coverage of boundary conditions]

## Dependencies
[External systems, teams, services]

## Success Metrics
[KPIs with measurement methodology]

## Rollout Strategy
[Phasing, feature flags, rollback plan]

## Open Questions
[Unresolved items with owners and deadlines]

## Risks & Mitigations
[Known risks with mitigation strategies]

## Appendix
[Glossary, references, revision history]
```

**2. Generate One-Pager** (`one-pager-[project-name].md`)

Structure:
```markdown
# [Project Name] - Technical One-Pager

## TL;DR
[2-3 sentences: what we're building and why]

## Architecture Overview
[High-level description of system components and data flow]

```
[Simple ASCII or description of component relationships]
```

## Key Components
| Component | Purpose | Tech/Approach |
|-----------|---------|---------------|
| ... | ... | ... |

## Data Model
[Core entities and relationships - keep it brief]

## API Surface
- `POST /endpoint` - [what it does]
- `GET /endpoint` - [what it does]
[Or: "Integrates with X API for Y"]

## Technical Decisions
| Decision | Choice | Why |
|----------|--------|-----|
| Database | PostgreSQL | [reason] |
| Auth | JWT | [reason] |
| ... | ... | ... |

## Dependencies
- **External**: [APIs, services]
- **Internal**: [teams, systems]

## Performance Requirements
- Latency: [target]
- Throughput: [target]
- Availability: [target]

## Security Considerations
- [Authentication approach]
- [Data sensitivity notes]
- [Compliance requirements if any]

## Scope Boundaries
**Building**: [bullet list]
**Not Building**: [bullet list]

## Known Risks
| Risk | Mitigation |
|------|------------|
| ... | ... |

## Open Technical Questions
- [ ] [Question] - blocks: [what it blocks]

---
*Full PRD: prd-[project-name].md*
```

---

## Execution Flow

```
┌─────────────────────────────────────────────────────────────────────┐
│                    /create-prd "DESCRIPTION"                        │
└─────────────────────────────────────────────────────────────────────┘
                                   │
                                   ▼
┌─────────────────────────────────────────────────────────────────────┐
│  Phase 1: Problem Space Exploration                                 │
│  - Understand the fundamental "why"                                 │
│  - Ask 3-4 questions using AskUserQuestion                          │
│  - Wait for responses, probe vague answers                          │
└─────────────────────────────────────────────────────────────────────┘
                                   │
                                   ▼
┌─────────────────────────────────────────────────────────────────────┐
│  Phase 2: User & Context Deep Dive                                  │
│  - Explore user personas and journeys                               │
│  - Understand environmental constraints                             │
│  - Uncover organizational context                                   │
└─────────────────────────────────────────────────────────────────────┘
                                   │
                                   ▼
┌─────────────────────────────────────────────────────────────────────┐
│  Phase 3: Solution Boundaries                                       │
│  - Define scope (in and out)                                        │
│  - Establish success criteria                                       │
│  - Identify minimum lovable product                                 │
└─────────────────────────────────────────────────────────────────────┘
                                   │
                                   ▼
┌─────────────────────────────────────────────────────────────────────┐
│  Phase 4: UI/UX Considerations (if applicable)                      │
│  - Interaction design questions                                     │
│  - Visual and behavioral requirements                               │
│  - Responsive and accessibility needs                               │
└─────────────────────────────────────────────────────────────────────┘
                                   │
                                   ▼
┌─────────────────────────────────────────────────────────────────────┐
│  Phase 5: Technical Landscape                                       │
│  - Stack and architecture context                                   │
│  - Integration requirements                                         │
│  - Operational concerns                                             │
└─────────────────────────────────────────────────────────────────────┘
                                   │
                                   ▼
┌─────────────────────────────────────────────────────────────────────┐
│  Phase 6: Risks & Tradeoffs                                         │
│  - Surface concerns proactively                                     │
│  - Force prioritization decisions                                   │
│  - Document assumptions                                             │
└─────────────────────────────────────────────────────────────────────┘
                                   │
                                   ▼
┌─────────────────────────────────────────────────────────────────────┐
│  Phase 7: Edge Cases & Error States                                 │
│  - Boundary conditions                                              │
│  - Recovery paths                                                   │
│  - Support escalation                                               │
└─────────────────────────────────────────────────────────────────────┘
                                   │
                                   ▼
┌─────────────────────────────────────────────────────────────────────┐
│  Completeness Check                                                 │
│  - Review all interview signals                                     │
│  - Identify any remaining gaps                                      │
│  - Final confirmation with user                                     │
└─────────────────────────────────────────────────────────────────────┘
                                   │
                                   ▼
┌─────────────────────────────────────────────────────────────────────┐
│  Document Generation                                                │
│  - Create in-depth PRD for engineering                              │
│  - Create one-pager for stakeholders                                │
│  - Save both artifacts to filesystem                                │
└─────────────────────────────────────────────────────────────────────┘
                                   │
                                   ▼
┌─────────────────────────────────────────────────────────────────────┐
│  Summary & Next Steps                                               │
│  - Present document locations                                       │
│  - Highlight open questions                                         │
│  - Suggest follow-up actions                                        │
└─────────────────────────────────────────────────────────────────────┘
```

---

## Example Session

**User:** `/create-prd "A dashboard for customer support managers to track agent performance and identify coaching opportunities"`

**Agent:**
```
Starting PRD discovery for: Customer Support Manager Dashboard

I'll be conducting a structured interview to build a comprehensive PRD.
Let's start by understanding the problem space.

**Phase 1: Problem Space**

[Uses AskUserQuestion with:]
1. What specific pain points do support managers experience today when
   trying to track agent performance? How are they currently working around it?

2. What triggered the need to solve this now? Is there a specific event,
   complaint, or business goal driving this?

3. If this dashboard didn't exist six months from now, what would the
   business impact be?
```

**User responds with answers**

**Agent:**
```
Thank you—that gives me good context on the urgency and current pain.

**Phase 2: Users & Context**

[Uses AskUserQuestion with:]
1. Walk me through a typical day for a support manager. When and how often
   would they realistically look at this dashboard?

2. Beyond the managers themselves, who else might need access?
   (Directors? HR? The agents themselves?)

3. What systems do managers currently use that this would need to
   complement or replace? (Zendesk? Salesforce? Spreadsheets?)
```

**[Interview continues through all phases...]**

**Agent (after Phase 7):**
```
**Completeness Check**

Based on our conversation, I can now confidently answer:
✓ An engineer could build this without asking clarifying questions
✓ I've challenged assumptions about real-time vs. daily data
✓ I understand why certain metrics matter (coaching, not punishment)
✓ Edge cases covered (new agents, transferred tickets, offline periods)
✓ Scope boundaries are explicit (no workforce scheduling in v1)
✓ Success metrics are concrete (25% reduction in escalations)
✓ Non-goals documented (no gamification features)

Generating documents now...

**Created:**
- `prd-support-manager-dashboard.md` (comprehensive engineering spec)
- `one-pager-support-manager-dashboard.md` (technical summary for quick reference)

**Key Open Questions to Resolve:**
1. Data retention policy for historical performance (needs Legal input)
2. Whether agent-level data requires works council approval (EU teams)
3. Integration priority: Zendesk first or Salesforce first?

Would you like me to walk through either document, or shall we dive into
any of the open questions?
```

---

## Best Practices

1. **Patience Over Speed**: A thorough 30-minute interview beats a rushed 10-minute one
2. **Probe, Don't Accept**: Vague answers need follow-up questions
3. **Challenge Respectfully**: Your job is to find gaps before engineering does
4. **Document Decisions**: Capture not just what was decided, but why
5. **Explicit Non-Goals**: What we're NOT building is as important as what we are
6. **Quantify Everything**: "Fast" and "easy" are meaningless without numbers
7. **Think in Failures**: Great specs anticipate what goes wrong

---

*Version: 1.0 - Systematic PRD interview process with dual-artifact output*
