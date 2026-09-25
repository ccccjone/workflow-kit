# Claude Code 协作工作流（迁移包）

[English](./README.md) · **简体中文**

一套可以直接套用的 Claude Code CLI 协作流程：spec 分级、plan-first、TDD、混合执行，外加**用代码强制的约束与验证**和**从失败中改进的闭环**。

v2 依据《深入理解 AI Agent》（[bojieli/ai-agent-book](https://github.com/bojieli/ai-agent-book)）的 Harness 工程思路修订，改动见文末。

## 文件清单

`install.sh` 和 README 只留在 kit 里；其余文件会被装进你的项目：

```
claude-workflow-kit/
├── install.sh                       # 装进目标仓库（不覆盖已有文件）
├── CLAUDE.md                        # 5 条硬规则 + 执行默认 + 项目特定段 + 导航
├── .claude/
│   ├── settings.json                # 权限 deny/ask + hooks 注册
│   ├── verify.sh                    # 验收三件套的唯一来源（按栈修改）
│   ├── hooks/
│   │   ├── guard-bash.sh            # 拦截 --no-verify、force push
│   │   └── stop-verify.sh           # 有源码改动时，结束回合前跑 verify.sh
│   ├── agents/                      # subagent 角色；模型只在这里绑定
│   │   ├── implementer.md           # T2/T3 实现（sonnet）
│   │   ├── reviewer.md              # T3 基于执行证据的审查（inherit）
│   │   └── explorer.md              # 只读搜索（haiku）
│   └── skills/                      # 操作细节，按需加载
│       ├── project-init/            # 新项目：选型 → ADR → 填 verify.sh 与项目特定段
│       ├── spec-writing/            # S0/S1/S2 分级 + spec 模板
│       ├── plan-execution/          # plan 结构、T1-T4、熔断、进度交接
│       ├── refactor-flow/           # 纯 refactor 的压缩流程
│       └── lesson-capture/          # 记录失败、提出最小规则更新
└── docs/
    ├── 00-Process/
    │   ├── AI-Workflow.md           # 总览 + 设计理由 + 模型分工
    │   ├── Definition-of-Done.md
    │   └── Doc-Conventions.md
    ├── 03-Specs/
    ├── 04-Plans/
    └── 05-Reviews/lessons.md        # 经验记录
```

## 怎么用

kit 只规定**流程**，不规定语言、框架和架构。技术选型在每个项目里由 `project-init` 和你一起决定，写成 ADR 后才作为该项目的约束。

### 新项目（从零开始）

```bash
sh path/to/claude-workflow-kit/install.sh ~/Projects/my-new-app
cd ~/Projects/my-new-app
claude
```

第一句话：

```
运行 project-init。我想做 <一句话描述：做什么、给谁用、跑在哪、有没有偏好的技术>。
```

Claude 会问几个会影响选型的问题，给出推荐和备选；你确认后它会写 ADR 0001、填 `verify.sh` 和 CLAUDE.md 的「项目特定」段，再把最小可运行骨架当作第一个 S1 任务做完。

### 已有项目

同样运行 `install.sh <repo>`。已存在的文件会被跳过并列出，需要手动合并（尤其是 `CLAUDE.md` 和 `.claude/settings.json`）。然后让 Claude 运行 project-init，它会读现有代码来填写「项目特定」段，而不是重新选型。

### install.sh 做了什么

- 复制 `CLAUDE.md`、`.claude/`、`docs/`，不覆盖已有文件
- 没有 git 仓库时 `git init`
- 添加 `.git/hooks/pre-commit`，内容为 `exec .claude/verify.sh`（人和 Claude commit 走同一道门）

hooks 依赖 `jq`（macOS 15+ 自带；否则 `brew install jq`）。

### 为什么要拷进项目，而不是让 Claude"读一下 kit"

Claude Code 只会从**当前项目**加载 `CLAUDE.md`、`.claude/settings.json`（hooks、权限）、`.claude/agents/` 和 `.claude/skills/`。让 Claude 读另一个文件夹里的 kit，它只是看到了文字：hooks 不会生效，skills 和 subagent 也不会注册。

### 未配置时的行为

`verify.sh` 在 project-init 之前是占位状态，直接放行并提示"尚未配置"，所以空仓库里 Stop hook 和 pre-commit 不会挡住你。选型确定后才真正开始把关。

### 权限

`settings.json` 只放与技术栈无关的规则：禁止 `--no-verify`、force push、读取 `.env` 与证书；`git push`、`reset --hard`、`git clean`、`rm -rf` 需要确认。项目特有的危险命令（数据库重置、生产部署等）由 project-init 追加到该项目自己的副本里。

## 关于 hooks 的注意事项

- **Stop hook 只在有未提交的源码改动时运行**，纯对话和纯文档改动不受影响。测试很慢时可以临时 `SKIP_STOP_VERIFY=1 claude` 启动。
- 同一回合最多拦截一次（依据 `stop_hook_active`），不会陷入无限循环。
- **hooks 里只放确定性命令，不要调用模型**（例如自动生成 commit message）。错误路径里再调模型容易引发连锁失败（书中第 5 章的"死亡螺旋"）。
- `permissions.deny` 只做前缀匹配，所以 `guard-bash.sh` 再兜底检查参数出现在中间的情况。

## 设计原则

- **约束优先于指导**：能用 hook / lint / 测试强制的规则，不只写在文档里。
- **Review 要有新信息**：审查者自己跑测试、看截图，不只读 diff。
- **Spec 按风险分级**：小改动不走访谈，高风险改动必须确认。
- **按角色写模型，在一处绑定**：文档里不出现模型名，`agents/*.md` 用别名；换档之前先用历史 task 做对比。
- **CLAUDE.md 短而稳定，细节放 skills**：常驻上下文尽量少，完整说明按需加载。
- **从失败中改进**：出现 2 次以上、能一句话说清的问题，才升级成规则；优先放进代码层。
- **文档源在仓库内**：`git mv` 即归档，`grep` 即检索。

## 按需裁剪

- 个人小项目：S1 可以更短，但 test-first 和 verify gate 不建议放宽。
- 团队项目：补 `docs/01-Requirements/`、`docs/02-Architecture/`，把 `settings.json` 的 deny 规则收紧。

## 致谢

设计思路主要来自李博杰《深入理解 AI Agent：设计原理与工程实践》（[bojieli/ai-agent-book](https://github.com/bojieli/ai-agent-book)），尤其是第 1 章 Harness 工程、第 2 章上下文与 Skills、第 5 章 Coding Agent 的故障恢复、第 9 章持续进化和第 10 章多 Agent 协作。

## v2 改动（相对初版）

- 新增 `.claude/settings.json`、hooks、`verify.sh`：硬规则 4 由代码强制
- 新增三个 subagent 定义；模型从文档中移出，只在 `agents/*.md` 里绑定
- 流程细节从 AI-Workflow.md 移到 4 个 skills；AI-Workflow.md 只保留总览和设计理由
- Spec 分 S0/S1/S2；reviewer 必须基于执行证据
- 新增熔断规则、Progress 交接段、5 行变更说明、`lesson-capture` 和 `lessons.md`
- DoD 新增：证据要求、UI 截图、产品内 LLM 功能的评估集门槛
- kit 保持技术栈无关：`verify.sh` 默认为占位；选型由 `project-init` 决定并写成 ADR
- 新增 `install.sh`

## 许可证

[MIT](../LICENSE)
