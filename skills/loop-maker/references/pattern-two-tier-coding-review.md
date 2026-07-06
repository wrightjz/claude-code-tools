# Pattern: Two-Tier Coding Review

**Default pattern when the loop writes or modifies code and "done" includes
quality** — clean, simple, readable, maintainable, and good enough to pass a
senior/principal engineer review. Use this instead of the plain deterministic
verifier whenever the acceptance bar is partly subjective.

---

## When to use

- The loop generates or edits source code.
- "Done" is more than "it runs": the output must also be clean, simple, and
  reviewable by a human engineer without embarrassment.
- Part of the criterion is program-checkable (tests pass, typecheck clean,
  lint clean, build green) and part is a judgment call (is this the simplest
  design? is it readable? are the tests meaningful?).

If the whole criterion is program-checkable, drop to
`pattern-react-deterministic-verifier.md` — it is simpler. If none of it is
program-checkable, use `pattern-evaluator-optimizer.md`.

For a complete filled-in loop — contract, calibrated rubric, a passing and a
failing iteration, and the kickoff command — see
`references/example-two-tier-coding-loop.md`.

---

## The two tiers

Verification runs in two stages. Tier 2 only runs if tier 1 passes — there is
no point grading the taste of code that does not compile.

```
act (generate / edit code)
  ↓
TIER 1 — deterministic gate  (verifier.sh)
   tests + typecheck + lint + build → binary exit code
  ↓ exit 0                     ↓ exit 1
TIER 2 — rubric review        restart within budget (see below)
   adversarial reviewer scores
   against review-rubric.md
   → review_gate.py (binary)
  ↓ exit 0                     ↓ exit 1
accept + advance state        restart within budget
```

### Tier 1 — deterministic gate

A standalone script (`verifier.sh`, from `scripts/verifier_template.sh`) that
runs the project's own checks and exits 0 only if all pass:

```
pnpm test && pnpm typecheck && pnpm lint && pnpm build
```

No AI model. Exit code is the only signal. This tier covers "passes all tests."

### Tier 2 — rubric-scored adversarial reviewer

A **separate agent, with its own context window**, told from the first message
that the code is broken and its job is to prove it. It does not see the
generator's reasoning. It scores the diff against `review-rubric.md` — five
axes (correctness, simplicity, readability, maintainability, test quality),
each 0–1 — and emits a JSON score plus one paragraph naming the biggest gap.

The subjective score is then made **binary** by a deterministic gate:
`review_gate.py` reads the JSON, computes the weighted total, and exits 0 only
if the overall score ≥ 0.85 **and** every axis ≥ 0.70. The loop reads the exit
code, never the prose. This is how a taste judgment still ends in a hard gate.

**Prefer a different model for the reviewer than the generator.** Same model =
shared blind spots; the generator and reviewer agree on the same subtle errors.

---

## The contract is what gets graded

Before the generator writes a line, it drafts `CONTRACT.md` — a checklist of
testable assertions describing what "done" means — and the reviewer pushes back
until they agree. The original goal predicate (Q1) is the boundary; the
contract is the graded artifact. Both tiers check against the contract, not
against a vague memory of the request. A too-short contract (a handful of
assertions) gets rubber-stamped; aim for enough that "done" is unambiguous.

The contract requires human approval before the first live run (gate G0). This
is the one place a human belongs on rule V's terms: you gate the *contract*,
not the *build*.

---

## Restart within budget, don't halt on every red

A failed tier-1 or tier-2 check is a normal event, not an emergency. Within the
budget in `HUMAN-GATES.md`, the loop retries or throws the iteration away and
restarts from a clean state — no human involved. Older loops patched until the
code became archaeology; a clean restart at iteration nine that ships at
iteration eleven is the loop working correctly.

A human is pulled in only when:

- the **contract itself** is wrong (the assertions describe the wrong thing), or
- the **budget** (max iterations / cost / wall-clock) is exhausted, or
- an **irreversible action** is about to run (merge, publish, delete) — these
  gates never go away.

Do not interrupt an ordinary restart.

---

## State

Use `loops/<name>/STATE.md` for single-worker runs, plus an append-only
`loops/<name>/log.md` (one `## [YYYY-MM-DD] op | title` entry per event) for the
audit trail. The loop must be able to crash, lose its session, and resume by
reading three files: `CONTRACT.md` (what done means), `STATE.md` (where it left
off), and `log.md` (what happened). If you cannot describe the loop's state in
three files, the state is too complicated — simplify before scaffolding.

Update state **after** both tiers pass, never before.

---

## Anti-patterns

- **One tier only**: grading taste without a deterministic gate (accepts broken
  code that reads nicely) or gating tests without a review tier (ships ugly code
  that passes). Both tiers are required when quality is part of "done".
- **Reviewer is the generator**: the model that wrote the code also grades it.
  Guarantees agreement on the same errors. Separate context window, ideally a
  separate model.
- **Prose verdict**: the review gate parses "looks good" from text. Exit codes
  only — `review_gate.py` turns the score into a binary.
- **Halting on every red build**: burns a human on normal failures and defeats
  rule V. Restart within budget; gate the contract, not the build.
- **Contract in the skill file**: `CONTRACT.md` is negotiated and can change, so
  it is a runtime artifact, not durable skill logic.
