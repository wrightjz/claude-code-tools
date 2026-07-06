# Host Adapters — Claude Code

The skill body describes actions in neutral language ("dispatch a sub-agent",
"schedule a recurring run", etc.). This file maps each abstract action to the
concrete mechanic in **Claude Code**, the primary host.

For non-Claude hosts, verify scheduling/loop mechanics against that host's
current docs before scaffolding.

> **Stability note.** Skill names, tool surfaces, and scheduler mechanics move
> between versions. Facts below are current as of authoring (mid-2026); verify
> against the installed version's docs before wiring anything into a
> production loop.

---

## Action map (Claude Code)

| Abstract action | Claude Code mechanic |
|---|---|
| **Run a loop / run-until-condition** | `/loop` is a **built-in skill**. `/loop <prompt>` runs self-paced until done (the fit for a goal-predicate loop); `/loop <interval> <prompt>` re-fires on a cadence. Inside a running session, the **ScheduleWakeup** tool lets the session self-pace its own wakeups (dynamic `/loop` mode). The loop must still enforce its own budget from `HUMAN-GATES.md`. |
| **Schedule a recurring run** | `/schedule` is a **built-in skill** that creates **cloud routines** — cron-scheduled agents that run unattended in the cloud. It is not an MCP server and needs no external cron. For local machine-level scheduling, an OS cron/`launchd` entry invoking the `claude` CLI with the launch prompt also works (there is **no `claude --skill` CLI flag** — pass the launch prompt itself). |
| **Dispatch a sub-agent** | The **Agent** tool spawns subagents (typed or general-purpose). For deterministic multi-subagent fan-out, the harness also provides a **Workflow** orchestration tool. |
| **Read a file** | The `Read` tool (preferred for known paths), or `Bash` for programmatic pipelines. |
| **Run a shell command** | The `Bash` tool. State does not persist across separate calls — chain with `&&` or write a script. |
| **Search the web** | **WebSearch** and **WebFetch** are built-in tools. MCP search servers remain an option but are not required. |

---

## Notes on portability

- **Never hard-bind scaffolded SKILL.md or TRIGGER.md files to a single host's
  tool names.** Use the abstract action verbs in skill prose; resolve them to
  host specifics only in `TRIGGER.md` and wiring code, with a reference to
  this file.
- The host-agnostic fallback always works: paste the launch prompt
  ("Read CONTRACT.md, STATE.md, and log.md plus the loop's SKILL.md, then run
  one iteration…") into any agent session.
