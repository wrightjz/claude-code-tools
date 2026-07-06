# Worked Example: A Two-Tier Coding Loop

A complete, copy-able reference for the two-tier pattern
(`pattern-two-tier-coding-review.md`). It shows every artifact filled in for one
realistic loop, one passing iteration, one failing iteration (to show
restart-within-budget), and the exact command to kick the loop off.

Use it as a template: change the scenario, keep the shapes.

---

## Scenario

> A TypeScript/Next.js project has ~12 exported utility functions in `src/lib/`
> that lack explicit return types and unit tests. Goal: give each an explicit
> return type and a meaningful test, **one function per iteration**, until all
> are done — and every change must be clean enough to pass a senior review.

This is a single-worker, item-by-item loop with a partly-subjective bar → the
two-tier pattern is the default.

---

## The blueprint (Phase 4a)

```
┌─ LOOP BLUEPRINT ───────────────────────────────────┐
│ GOAL      all lib fns typed+tested · tests+review  │
│ CONTRACT  8 assertions · G0                        │
│ TRIGGER   run-until-done (self-paced /loop)        │
│ VERIFY    tier1: pnpm test+typecheck+lint · tier2  │
│ STATE     loops/typed-lib/STATE.md                 │
│ GATES     G0 contract · merge=human · 30 iters max │
└────────────────────────────────────────────────────┘
```

Folder scaffolded:

```
~/.claude/skills/typed-lib/          # durable
  SKILL.md
  verifier.sh
  review-rubric.md
  review_gate.py
  HUMAN-GATES.md
  TRIGGER.md
loops/typed-lib/                     # changing (in the working tree)
  CONTRACT.md
  STATE.md
  log.md
```

---

## `loops/typed-lib/CONTRACT.md` (filled, awaiting G0)

```markdown
# typed-lib — Contract

**Goal predicate (boundary):** every exported function in src/lib/ has an
explicit return type and at least one meaningful test; `pnpm test`, `typecheck`,
and `lint` are green.

## Testable assertions

| # | Assertion | Verified by | Status |
|---|-----------|-------------|--------|
| A1 | All existing and new tests pass | tier-1 | pending |
| A2 | `pnpm typecheck` reports no errors | tier-1 | pending |
| A3 | `pnpm lint` reports no errors | tier-1 | pending |
| A4 | `pnpm build` succeeds | tier-1 | pending |
| A5 | The target function has an explicit, non-`any` return type | tier-1 | pending |
| A6 | The target function has a test asserting real behavior (not a smoke test) | tier-2 | pending |
| A7 | The change touches only the target function + its test (no drive-by edits) | tier-2 | pending |
| A8 | Naming and structure match the surrounding file's conventions | tier-2 | pending |

## Amendment log
- (scaffold) initial contract drafted from goal predicate — awaiting G0 approval
```

> A5 moved to tier-1 because "has an explicit non-`any` return type" is
> program-checkable (a lint rule / AST check), so the deterministic gate owns
> it. Only the genuinely-subjective assertions (A6–A8) live in tier-2. That
> split is the whole point of two tiers.

---

## `review-rubric.md` — using the shipped default, calibrated

The five default axes/weights/threshold are unchanged (overall ≥ 0.85, every
axis ≥ 0.70). Only the **calibration references** are filled in for this repo:

```markdown
## Calibration references

Good (should score ≥ 0.85):
- src/lib/formatCurrency.ts        — tight, typed, one clear test
- src/lib/parseCursor.ts           — handles edge cases, readable

Slop (should score < 0.70 on ≥ 1 axis):
- src/lib/legacyDateHack.ts        — `any` types, no tests, copy-pasted
- git show HEAD~40:src/lib/util.ts — 300-line grab-bag, tautological tests
```

Before the first live run, point the reviewer at these four and confirm the
scores separate them. If `legacyDateHack.ts` scores 0.8, the rubric is too
loose — tighten the axis descriptions.

---

## One passing iteration

**Act:** the generator adds `: Money` return type to `formatDiscount()` and
writes `formatDiscount.test.ts`.

**Tier 1 — deterministic gate:**

```bash
$ ./verifier.sh "tier-1 checks" bash -c "pnpm test && pnpm typecheck && pnpm lint && pnpm build"
PASS: tier-1 checks
$ echo $?
0
```

**Tier 2 — adversarial reviewer** (separate agent, told the code is broken)
emits its score to `loops/typed-lib/.review.json`:

```json
{
  "correctness": 0.95,
  "simplicity": 0.90,
  "readability": 0.90,
  "maintainability": 0.85,
  "test_quality": 0.80
}
```

…followed by its one-paragraph gap note:

> Biggest gap: `test_quality`. The test asserts the happy path and one zero
> case, which is meaningful, but it does not cover the negative-discount branch
> the function guards against. Add one assertion for a negative input to close
> it. Everything else is clean and matches the file's style.

**Review gate turns the score into a verdict:**

```bash
$ python3 review_gate.py loops/typed-lib/.review.json
PASS: overall=0.895 (>= 0.85), all axes >= 0.70
$ echo $?
0
```

Both tiers passed → advance state, append to log, continue.

---

## One failing iteration → restart within budget (no human)

**Act:** the generator types `parseFilters()` but writes a tautological test
(`expect(parseFilters(x)).toEqual(parseFilters(x))`).

**Tier 1:** passes (it compiles and the tautological test is green).

**Tier 2 reviewer score:**

```json
{
  "correctness": 0.90,
  "simplicity": 0.85,
  "readability": 0.85,
  "maintainability": 0.80,
  "test_quality": 0.55
}
```

> Biggest gap: `test_quality`. The test compares the function to itself and
> would pass even if the body were `return null`. Replace it with assertions on
> known input→output pairs, including an empty-filter case.

**Review gate:**

```bash
$ python3 review_gate.py loops/typed-lib/.review.json
FAIL: test_quality=0.55 < floor 0.70; overall=0.825 < threshold 0.85
$ echo $?
1
```

Verdict is exit 1. **This is normal, not an emergency.** The loop increments
`consecutive_fails`, logs the reason, throws the bad test away, and restarts the
iteration using the reviewer's gap note — no human involved. A human is only
pulled in if this fails **N consecutive times** (gate G2) or the 30-iteration
budget is hit.

---

## State after these two iterations

`loops/typed-lib/STATE.md`:

```
## Last run
timestamp        : 2026-07-01T14:32:10Z
iteration        : 7
consecutive_fails : 0
outcome          : passed (formatDiscount typed + tested)
exit code        : 0
```

`loops/typed-lib/log.md` (append-only):

```markdown
## [2026-07-01] act | formatDiscount: add return type + test
Typed as Money; added happy-path + zero-case test.

## [2026-07-01] verify | formatDiscount PASS (tier1=0, tier2=0.895)
Both tiers green. Advanced to next function.

## [2026-07-01] act | parseFilters: add return type + test
Typed as Filter[]; test written.

## [2026-07-01] verify | parseFilters FAIL (tier2=0.825, test_quality=0.55)
Tautological test. consecutive_fails=1. Restarting iteration per reviewer note.

## [2026-07-01] act | parseFilters: rewrite test (attempt 2)
Replaced with input→output assertions incl. empty-filter case.

## [2026-07-01] verify | parseFilters PASS (tier1=0, tier2=0.88)
consecutive_fails reset to 0. Advanced.
```

Note the loop recovers from exactly three files — `CONTRACT.md`, `STATE.md`,
`log.md`. If a run crashes here, the next cold start reads them and resumes at
function 8.

---

## Kicking it off

`loop-maker` writes the loop; it does not run it. After clearing gate G0
(approve `CONTRACT.md`), start it self-paced so it iterates until the goal
predicate holds or the budget trips:

```
/loop Read loops/typed-lib/CONTRACT.md, STATE.md, and log.md plus the typed-lib
SKILL.md, then run one iteration of the typed-lib loop.
```

- Omit the interval (as above) for **run-until-done** self-pacing — the fit for
  a goal-predicate loop.
- Add an interval (`/loop 10m …`) to poll on a cadence instead.
- Use `/schedule` for an unattended cloud routine, or paste the same prompt into
  a fresh session to run one iteration by hand.

> **Flag:** `/loop` and `/schedule` availability and syntax are host-specific
> and change between versions — verify against your installed Claude Code docs.
> The host-agnostic fallback (paste the launch prompt into any session) always
> works. See `references/host-adapters.md`.
