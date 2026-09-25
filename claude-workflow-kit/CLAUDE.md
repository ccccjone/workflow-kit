# CLAUDE.md

本文件为 Claude Code 提供本仓库的协作规则。

> **角色**：硬规则 + 导航。操作细节在 `.claude/skills/`（按需加载），背景说明在 [docs/](./docs/)。
> 本文件每次会话都会载入，保持短、少改动（稳定前缀有利于 prompt cache）。
> 本文件只规定流程，不规定语言、框架与架构；这些以下方「项目特定」段和 ADR 为准。

## 5 条硬规则

1. **Spec 按风险分级**：开工前先判定 S0 / S1 / S2，写在回复第一行。S0 说明假设后直接做；S1 写短 spec；S2 写完整 spec 并等用户确认。见 `spec-writing` skill。
2. **Plan-first（S1/S2）**：spec 配一个同名 plan，plan 是 checklist 不是代码。见 `plan-execution` skill。
3. **Test-first**：feature 先写红测试；bug 先写能重现的回归测试；纯 refactor 现有测试不破即可（见 `refactor-flow` skill）。
4. **Verification gate**：`.claude/verify.sh` 是验收三件套的唯一来源。声称完成时必须贴出它的输出摘录；禁止 `--no-verify`（已由 hook 强制）。
5. **Single source of truth**：权威信息只放在仓库内（`docs/`、`.claude/`）。仓库外的笔记和聊天记录不算。

## 执行默认

- 默认混合执行（T1/T4 主会话做，T2/T3 派 `implementer`，大范围搜索派 `explorer`），**不要问用户选执行模式**。
- 需要用户确认的只有：S2 spec、plan 边界变化、删除性 / 不可逆操作、BLOCKED。
- 同一命令或测试连续失败 3 次且没有进展 → 停止，写下假设，换策略或上报。
- 出现返工、被纠正、被打回时，用 `lesson-capture` 记录。

## 项目特定

> 由 `project-init` skill 填写。仍是占位符时，先运行 project-init，不要自行假设技术栈。

- **技术栈**：_未定_（见 ADR 0001）
- **目录约定**：_未定_
- **运行 / 测试**：见 `.claude/verify.sh`
- **UI 视觉验证方式**：_未定_

## 导航

| 想做什么 | 去哪 |
|---|---|
| 工作流总览与设计理由 | [docs/00-Process/AI-Workflow.md](./docs/00-Process/AI-Workflow.md) |
| 完成标准 | [docs/00-Process/Definition-of-Done.md](./docs/00-Process/Definition-of-Done.md) |
| 文档约定 / ADR 格式 | [docs/00-Process/Doc-Conventions.md](./docs/00-Process/Doc-Conventions.md) |
| Spec / Plan | [docs/03-Specs/](./docs/03-Specs/) · [docs/04-Plans/](./docs/04-Plans/) |
| 经验记录 | [docs/05-Reviews/lessons.md](./docs/05-Reviews/lessons.md) |
| 验收命令 | [.claude/verify.sh](./.claude/verify.sh) |
| 新项目初始化 | `project-init` skill |

> 视项目追加：`docs/01-Requirements/`、`docs/02-Architecture/`（含 ADR）、`docs/06-Testing/`、`docs/07-Runbooks/`。
