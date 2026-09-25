# Claude Code Collaboration Workflow Kit

**English** · [简体中文](./README.zh-CN.md)

A drop-in collaboration workflow for Claude Code: risk-tiered specs, plan-first, TDD, and mixed inline/subagent execution. It also includes **constraints and verification enforced in code** and **a loop for learning from failures**.

v2 is revised using the harness-engineering approach from *AI Agents in Depth* ([bojieli/ai-agent-book](https://github.com/bojieli/ai-agent-book)). See the changelog at the end.

> **Language note:** the rules, skills and process docs that get installed into your project (`CLAUDE.md`, `.claude/`, `docs/`) are currently written in Chinese. Claude follows them fine either way, and you can translate them if your team prefers English.

## Files

`install.sh` and the READMEs stay in the kit. Everything else is copied into your project:

```
claude-workflow-kit/
├── install.sh                       # install into a target repo (never overwrites)
├── CLAUDE.md                        # 5 hard rules + execution defaults + project-specific section + navigation
├── .claude/
│   ├── settings.json                # permission deny/ask lists + hook registration
│   ├── verify.sh                    # single source of the lint / type-check / test gate
│   ├── hooks/
│   │   ├── guard-bash.sh            # blocks --no-verify and force push
│   │   └── stop-verify.sh           # runs verify.sh before a turn ends if source files changed
│   ├── agents/                      # subagent roles; models are bound only here
│   │   ├── implementer.md           # T2/T3 implementation (sonnet)
│   │   ├── reviewer.md              # T3 evidence-based review (inherit)
│   │   └── explorer.md              # read-only search (haiku)
│   └── skills/                      # procedures, loaded on demand
│       ├── project-init/            # new project: stack choice → ADR → fill verify.sh and project section
│       ├── spec-writing/            # S0/S1/S2 tiers + spec template
│       ├── plan-execution/          # plan structure, T1–T4, circuit breaker, progress handoff
│       ├── refactor-flow/           # slimmed-down flow for pure refactors
│       └── lesson-capture/          # log failures, propose minimal rule updates
└── docs/
    ├── 00-Process/
    │   ├── AI-Workflow.md           # overview + design rationale + model roles
    │   ├── Definition-of-Done.md
    │   └── Doc-Conventions.md
    ├── 03-Specs/
    ├── 04-Plans/
    └── 05-Reviews/lessons.md        # lessons log
```

## Usage

The kit defines **process** only. It does not prescribe languages, frameworks or architecture. Each project chooses its stack with `project-init`, and those choices only become constraints once they are recorded as an ADR.

### New project (from scratch)

```bash
sh path/to/claude-workflow-kit/install.sh ~/Projects/my-new-app
cd ~/Projects/my-new-app
claude
```

First message:

```
Run project-init. I want to build <one line: what it does, who it's for, where it runs, any preferred tech>.
```

Claude asks a few questions that affect the stack choice, then proposes a recommendation plus alternatives. After you confirm, it writes ADR 0001 and fills in `verify.sh` and the "project-specific" section of `CLAUDE.md`. It then builds a minimal runnable skeleton as the first S1 task.

### Existing project

Run `install.sh <repo>` the same way. Files that already exist are skipped and listed, and you merge them by hand (especially `CLAUDE.md` and `.claude/settings.json`). Then ask Claude to run project-init. For an existing codebase it reads the current code and records the stack as it is. It does not re-choose the stack.

### What install.sh does

- Copies `CLAUDE.md`, `.claude/` and `docs/` without overwriting anything
- Runs `git init` if the target is not a git repo
- Adds `.git/hooks/pre-commit` containing `exec .claude/verify.sh`, so your own commits and Claude's pass the same gate

The hooks require `jq` (bundled with macOS 15+; otherwise `brew install jq`).

### Why copy it into the project instead of asking Claude to "read the kit"

Claude Code only loads `CLAUDE.md`, `.claude/settings.json` (hooks, permissions), `.claude/agents/` and `.claude/skills/` from the **current project**. If Claude only reads the kit from another folder, it sees the text, but the hooks don't run and the skills and subagents are never registered.

### Before configuration

Until project-init runs, `verify.sh` is a placeholder. It passes and prints "not configured yet", so the Stop hook and pre-commit won't block you in an empty repo. Checks start being enforced once the stack is chosen.

### Permissions

`settings.json` only contains stack-agnostic rules:

- **Denied:** `--no-verify`, force push, and reading `.env` files and certificates.
- **Ask first:** `git push`, `reset --hard`, `git clean` and `rm -rf`.

project-init adds project-specific dangerous commands (database resets, production deploys, etc.) to that project's own copy.

## Notes on hooks

- **The Stop hook only runs when there are uncommitted source changes.** Plain conversation and doc-only edits are not affected. If the tests are slow, launch with `SKIP_STOP_VERIFY=1 claude`.
- It blocks at most once per turn, using `stop_hook_active`, so it can't loop forever.
- **Hooks run deterministic commands only. Never call a model from a hook** (e.g. to generate a commit message). Calling a model again on an error path can trigger cascading failures, which the book calls a "death spiral" (chapter 5).
- `permissions.deny` only matches prefixes, so `guard-bash.sh` also catches flags that appear mid-command.

## Design principles

- **Constraints over guidance:** a rule that a hook, lint or test can enforce shouldn't live only in docs.
- **Reviews need new information:** the reviewer runs the tests and looks at screenshots instead of only reading the diff.
- **Specs are tiered by risk:** small changes skip the interview, and high-risk changes require confirmation.
- **Name roles, bind models in one place:** docs never mention model names, and `agents/*.md` use aliases. Before switching models, rerun a few past tasks and compare the results.
- **Keep CLAUDE.md short and stable, put details in skills:** always-loaded context stays minimal, and full instructions load on demand.
- **Learn from failures:** an issue becomes a rule only after it recurs (2+ times) and can be stated in one sentence. Prefer enforcing it in code.
- **Docs live in the repo:** archive with `git mv`, search with `grep`.

## Tailoring

- **Small personal projects:** S1 specs can be even shorter, but keep test-first and the verify gate.
- **Team projects:** add `docs/01-Requirements/` and `docs/02-Architecture/`, and tighten the deny list in `settings.json`.

## Acknowledgements

The design draws mainly on Bojie Li's *AI Agents in Depth: Design Principles and Engineering Practice* ([bojieli/ai-agent-book](https://github.com/bojieli/ai-agent-book)):

- Ch. 1: harness engineering
- Ch. 2: context and Skills
- Ch. 5: failure recovery in coding agents
- Ch. 9: continuous improvement
- Ch. 10: multi-agent collaboration

## v2 changes (vs. the initial version)

- Added `.claude/settings.json`, hooks and `verify.sh`, so hard rule 4 is enforced in code
- Added three subagent definitions; models moved out of the docs and are bound only in `agents/*.md`
- Moved procedures from AI-Workflow.md into skills; AI-Workflow.md now holds only the overview and rationale
- Specs tiered S0/S1/S2; the reviewer must work from execution evidence
- Added a circuit breaker, a Progress handoff section, a 5-line change summary, `lesson-capture` and `lessons.md`
- Definition of Done now requires evidence, UI screenshots, and an eval-set gate for in-product LLM features
- Kept the kit stack-agnostic: `verify.sh` starts as a placeholder, and `project-init` chooses the stack and records it as an ADR
- Added `install.sh`

## License

[MIT](../LICENSE)
