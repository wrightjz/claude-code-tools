# Loops and Loop Engineering

A knowledge backbone for `loop-maker`. Consult this file when reasoning about
how agent loops work, why they fail, and how to build ones that reliably reach
their goal and stop.

---

## The cold-start fact

Every time an agent loop fires, the agent wakes up with no memory of what it
did before. There is no persistent runtime — each invocation is a fresh
process that reads its environment from disk and starts reasoning from scratch.
This is the cold-start condition, and it is the central constraint of loop
design.

The implication is simple: anything the loop needs to know across runs must
live somewhere other than in the agent's in-context memory. Conventions go in
skill files. State — counters, cursors, which items are done, what happened
last time — goes in an external file the agent reads at the start of each run
and writes before it exits. Without both, the loop cannot make progress; it
just restarts from zero every time.

---

## The minimal loop

A correct loop has three and only three components:

1. **Generator** — the agent that observes the world and takes one step toward
   the goal. It reads the state file to know where it left off, performs one
   action, and writes an updated state file.

2. **Evaluator** (separate from the generator) — a program, script, or checker
   that examines the generator's output and returns a binary verdict: pass or
   fail. "Binary" is literal: an exit code of 0 (success) or 1 (failure), not
   a prose opinion. The evaluator must be a *separate file* from the loop
   skill. A generator that judges its own output is not a loop; it is an
   optimist.

3. **The repeat** — a driver that calls the generator, hands its output to the
   evaluator, and decides what to do next: proceed, retry, escalate to a human,
   or stop because the exit predicate is satisfied.

Remove any one of the three and the loop either runs forever, never verifies
its work, or has no continuity between invocations.

---

## The contract: what actually gets graded

Before the generator writes a line, it should propose what "done" looks like and
the evaluator should push back — the two argue (via markdown files on disk)
until they agree on a checklist of **testable assertions**. That checklist is
the *contract*. The original request is the boundary; the contract is what gets
graded on every iteration.

This is the single change that most reliably moves a loop from "broken demo" to
"working product". A too-short contract — a handful of assertions — gets
rubber-stamped by the evaluator; write enough that "done" is unambiguous. The
contract is a negotiated runtime artifact (`CONTRACT.md`), not durable skill
logic, and a human approves it before the first live run. That approval is the
right place for a human: you gate the *contract*, not the *build*.

---

## The 6 building blocks

Good loop engineering (Addy Osmani uses the term "loop engineering" for this
discipline) means assembling six concerns and knowing what breaks when any one
is missing.

### 1. Scheduling
How the loop is triggered: a cron expression, a filesystem event, a webhook,
an API poll, or a manual dispatch. Without a defined trigger, the loop only
runs when someone remembers to start it — which is not a loop, it is a
one-shot.

### 2. Isolation / worktrees
When a loop does work that modifies files, it should operate in an isolated
workspace (a worktree, a scratch directory, a container) so that partial or
failed work cannot corrupt the main branch. Isolation also enables parallel
execution: multiple workers can act on separate items at the same time without
stepping on each other's changes. Without isolation, a bad iteration leaves
the working tree in an undefined state, and parallel runs produce conflicts.

### 3. Skill
The durable, read-only logic the agent loads each run: the goal definition,
the action procedure, the discovery query, and the call to the verifier. It
does not change between runs. It carries *logic*, never *state*. Without a
stable skill file, each invocation may behave differently because the
instructions drifted.

### 4. Connectors
The interfaces the loop uses to read from and write to the world: a GitHub
API client, a filesystem reader, a database cursor, a message queue consumer.
Without a defined connector, the loop's discovery or action step is
underspecified — it knows *what* to do but not *how* to talk to the system
that holds the data.

### 5. Sub-agents
For work that can be decomposed, the orchestrating loop dispatches sub-agents
to handle individual items in parallel. Each sub-agent is isolated (its own
worktree or scratch space) and reports back a structured result. Without
sub-agents, a loop that processes many items must serialize them all, which
is slow and means one failure blocks everything downstream.

### 6. Memory / state
The external file (or issue tracker, or append-only log) that holds everything
that changes between runs: cursors, counters, item status, iteration history,
accumulated partial results. Without an external state file, the loop re-
discovers what it already did on every cold start, cannot track progress
across interruptions, and has no way to detect when it is done.

---

## The durable-vs-changing rule

Split every piece of information by one question: *does this change between
runs?*

- **No** → it is durable. It belongs in a skill file, loaded read-only at
  the start of each run. Examples: the goal definition, a style guide, a
  rubric, a schema, a list of known-good examples.

- **Yes** → it is changing state. It belongs in an external state file (or
  issue tracker), read at the start of each run and written before the run
  exits. Examples: which items are processed, the current cursor or timestamp,
  the iteration count, intermediate results.

Mutable state stored in a skill file is the most common loop anti-pattern. It
appears to work the first time, then silently disappears on the next cold
start when the skill is reloaded from disk in its original form.

---

## Q6 state-backend menu and isolation rule

The answer to Q6 (what does the loop need to remember?) determines both what
goes in the state file and *which* state backend to use. The choice depends on
the isolation model:

| Isolation model | State backend |
|---|---|
| Single worker — one run at a time | `loops/<name>/STATE.md` — plain markdown file; the agent reads it at run start, overwrites it at run end |
| Parallel / worktree — multiple workers per run | GitHub Project or GitHub Issues — one issue per work item; closing = done; supports concurrent reads and writes without file-lock conflicts |
| Parallel but no GitHub access | `loops/<name>/iterations.jsonl` — append-only; each worker appends one JSON line per completed iteration; no file-lock required because appends are atomic at the OS level |

An optional MCP-backed tracker (task manager, project board) may layer on top
of any of these to provide a richer view, but the backend above is always the
source of truth. If the user overrides this recommendation, document the
override and why in `TRIGGER.md`.

The **isolation rule** follows from the worktree entry: whenever two or more
iterations may run concurrently, each must have its own isolated workspace.
A shared working tree with concurrent writers is not a loop; it is a race
condition.

---

## Three failure modes

### 1. No separate verifier
The generator checks its own output. Self-assessment is systematically biased
toward "looks good" — a model that produced a flawed result is the least
reliable judge of that result. The evaluator must be a separate program with a
checkable criterion. If you cannot write the verifier as a script with an exit
code, the goal is not yet precise enough to automate.

### 2. Mutable state stored in the skill
The skill file is read from disk on every cold start. Any state written into it
during a run is overwritten the next time the loop fires. Counters silently
reset. Progress is lost. Checksums go stale. The fix is always the same: move
the mutable data out of the skill and into the state file.

### 3. No stop condition
A loop that has no checkable exit predicate runs indefinitely — either cycling
through already-completed work, burning tokens on items that will never
satisfy the goal, or silently accumulating cost until something external
(a billing limit, a human killing the process) stops it. Every loop must have
a predicate that the verifier can evaluate to determine "done", and a hard
budget (maximum iterations, cost ceiling, or wall-clock limit) that stops the
loop even if the predicate is never satisfied.

---

## Field rules for loops that run for days

These are the disciplines that separate a loop that survives a multi-day run
from one that quietly rots. They come from watching frontier models drive loops
unattended.

### Let the loop restart

The best behavior current models show is a willingness to throw everything away
and start over when a run goes sideways. Older models patched and patched until
the codebase resembled archaeology; newer ones, given a clean evaluator and a
contract on disk, will delete the work at iteration nine and ship a working
version at iteration eleven. Do not interrupt this — the restart *is* the loop
working. Insert a human only when the contract itself is wrong, not when the
build is red. Restart-within-budget is the default failure policy.

### Recover from three files

Context windows lie: they compact, they rot, they hide what was said an hour ago
behind a summary no one wrote. A file on disk does not. The loop must be able to
crash, lose its session, and resume by reading three files — `CONTRACT.md`
(what "done" means), the state file (where it left off), and an append-only
`log.md` (what happened, one `## [YYYY-MM-DD] op | title` entry per event). If
you cannot describe the loop's state in three files, the state is too
complicated; simplify it before running for days.

### Read the traces

Every real debugging insight about a loop comes from reading the raw transcript,
not from running another experiment. Pipe the loop's output to `log.md`, grep
for the moment its judgment first diverged from yours, and fix the prompt (or
the contract) for that exact moment. This is the same muscle as reading a stack
trace — except the trace is written in English and most of it is the model
talking to itself. Skip this step and you are tuning by vibe.

### Delete the harness

The harness exists to compensate for the model. As the model improves, half of
what you wrote last quarter becomes overhead: context-resetting that was
load-bearing for one model generation is dead weight for the next; scaffolding
that kept a four-hour build coherent becomes a constraint on a model that holds
the whole thing in one pass. Re-read the harness against each new model release
and delete anything the model now does for free. A harness that only ever grows
is a harness someone stopped reading.

### The bottleneck always moves

When coding stops being the bottleneck, planning becomes the bottleneck. When
planning is solved, verification becomes the bottleneck. When verification is
automated, taste becomes the bottleneck. A loop is never "finished" — you find
the next thing to fix. If everything is running smoothly, you are not looking
carefully enough. This is why the review rubric and the contract matter: they
are how you make the *taste* bottleneck visible and gradable once the earlier
ones are handled.

---

## Limitations

### Prompt injection and permanent human gates

Because the generator reads external data (issue bodies, file contents, API
responses), any malicious content in that data can attempt to redirect the
agent's behavior. A compromised loop running with write access is dangerous.
The mitigation is not purely technical: irreversible or high-stakes actions
(sending external messages, pushing to production, deleting data) must have a
permanent human gate regardless of how confident the agent is. No
self-assessed confidence score overrides this gate.

### Verification is the hard part

Writing the generator is usually straightforward. Writing a verifier that
catches all the ways an action can be subtly wrong is the hard problem. A
verifier that only checks "did the file appear?" misses malformed content. A
verifier that checks structure misses semantic errors. Plan verification time
accordingly. The quality of a loop is bounded by the quality of its verifier.

### Token economics: budgets are mandatory

Long-running loops can exhaust context windows, hit rate limits, or spend real
money. Anthropic's *Building Effective Agents* guidance emphasizes setting
explicit token and cost budgets for agentic workflows — not as a soft
suggestion but as a hard stop. Every loop designed with this skill must have
a budget recorded in `HUMAN-GATES.md` before it is considered scaffolded. A
loop without a budget is a liability, not an automation.

---

## Kickoff commands: `/loop` and `/schedule`

On Claude Code, `/loop` and `/schedule` are confirmed built-in skills:
`/loop <prompt>` runs self-paced until done, `/loop <interval> <prompt>` polls
on a cadence, and `/schedule` creates cron-scheduled cloud routines. Their
exact syntax can still shift between versions, so scaffolded output should
point at `references/host-adapters.md` and the installed version's docs. On
non-Claude hosts, verify scheduling/loop mechanics against that host's current
docs before scaffolding. The host-agnostic fallback — paste the launch prompt
into a fresh session — always works.
