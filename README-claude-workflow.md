# Claude Code 协作工作流（迁移包）

一套可直接套用的 Claude Code CLI 协作流程：spec-first / plan-first / TDD / 混合执行。从一个跑了一段时间的实战项目里抽取，去掉了栈特定内容（移动端 / iOS / 特定工具链），保留通用核心。

## 文件清单

```
<your-repo>/
├── CLAUDE.md                       # 5 条硬规则 + 导航 + 推荐 skills（Claude Code 启动时自动读）
└── docs/
    ├── 00-Process/
    │   ├── AI-Workflow.md          # 完整流水线：spec → plan → test → code → review → commit
    │   ├── Definition-of-Done.md   # 完成标准（lint / 类型 / test / commit / no-TODO 等）
    │   └── Doc-Conventions.md      # 命名 / 归档 / ADR 格式 / 链接规则
    ├── 03-Specs/                   # 放 YYYY-MM-DD-<topic>.md 的 spec
    └── 04-Plans/                   # 放与 spec 同名的 plan
```

## 怎么用（5 分钟上手）

### 1. 拷到自己 repo 根目录

```bash
cd <your-repo>
cp -r path/to/this/kit/CLAUDE.md ./
cp -r path/to/this/kit/docs ./
```

`docs/03-Specs/` 和 `docs/04-Plans/` 暂时是空的，第一次 spec 写完就有内容。

> 如果你 repo 已经有 `CLAUDE.md`，合并而不是覆盖。本套规则推荐放在你现有 CLAUDE.md 的顶部。

### 2.（推荐）装 superpowers plugin

工作流里推荐用的几个 skill（brainstorming / writing-plans / executing-plans 等）来自 [superpowers](https://github.com/obra/superpowers) plugin。

在 Claude Code CLI 里运行：

```
/plugin
```

按提示安装 `superpowers`。装完之后 `/brainstorming`、`/writing-plans` 等 slash command 就能直接用。

不装也能跑——只是 spec / plan / review 都要你自己（或让 Claude 自由发挥）拼。

### 3.（推荐）加 pre-commit hook 强制验收门

`CLAUDE.md` 第 4 条硬规则要求 commit 前跑 lint / 类型检查 / tests。靠自觉容易漏，建议加 hook。Node/TS 项目示例（`.husky/pre-commit`）：

```bash
#!/bin/sh
npm run lint && npx tsc --noEmit && npm test
```

其它栈类比替换。

### 4. 第一次和 Claude 协作（开场白模板）

新开一个 Claude Code session，第一条消息可以是：

```
我想做 <一句话需求>。按 docs/00-Process/AI-Workflow.md 的流程走：
先 brainstorming 对齐需求，输出 spec 到 docs/03-Specs/；
spec 我确认后，写 plan 到 docs/04-Plans/；
plan 我确认后，按混合模式执行（参考 AI-Workflow.md §Subagent vs Inline）。
```

Claude 会自动读 `CLAUDE.md` 和 `docs/` 引用的文件，按这套规则走。

## 设计原则（为什么是这样）

- **5 条硬规则刻进 CLAUDE.md**：Claude Code 每次启动都会读 `CLAUDE.md`，所以最高优先级的约束写在那里、其它细节下沉到 `docs/`。
- **Spec 和 plan 都是 checklist，不是 code dump**：1500 行的 plan 在执行时大量会被 subagent 重写，浪费 token 又和实际类型冲突——只写 task boundary + verification command + commit message。
- **混合执行（subagent + inline）是默认**：T1（trivial 改动）和 T4（架构决策）inline 做；T2/T3（实现性多文件改动）派 subagent。Plan 通过后不要再问用户「subagent 还是 inline」。
- **文档源在 in-repo**：不依赖 Obsidian / Notion / chat 历史。`git mv` 即归档，`grep` 即检索。

详见 [docs/00-Process/AI-Workflow.md](./docs/00-Process/AI-Workflow.md)。

## 按需裁剪

这套是一份**起点**，不是教条。

- 项目刚起步、没多少文件 → ADR 目录、Architecture 目录、Reviews 目录都可以先不建，等真需要再加。
- 个人小项目 → 5 条硬规则里的 spec/plan 可以放宽到「一段话需求 + 一段话计划」，但 test-first 和 verification gate 不建议放。
- 团队项目 → 反过来，可能要在 `docs/01-Requirements/` 加 backlog、在 `docs/02-Architecture/` 加 code-layout，看实际需要补。

## 进一步可选

CLAUDE.md 里没强制但实战很有用：

- **graphify**（可选）—— 自动维护代码知识图谱，跨模块查询比 grep 强。但需要单独装，且当前仅支持部分语言。
- **memory 系统**（可选）—— Claude Code 内置的 `~/.claude/projects/.../memory/` 跨会话记忆，需要在 system prompt 里自行启用。
- **graphify-out / 知识图谱 hook**——可以在 `.claude/settings.json` 里加 PreToolUse hook，让 Claude 搜索代码前先看知识图谱。本包未含，自行查 Claude Code hooks 文档。
