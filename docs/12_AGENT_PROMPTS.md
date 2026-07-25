
# Agent 启动提示词

## Milestone 0

```text
完整阅读 README.md、AGENTS.md、docs/02_PRD.md、docs/03_GDD.md、
docs/05_TECH_SPEC.md、docs/08_BACKLOG.md 和 docs/STATUS.md。

只执行 T0.1 与 T0.2。

目标：
1. 创建 Godot 4.x + GDScript 项目；
2. 锁定具体 Godot 稳定版本；
3. 建立目录；
4. 创建 GameState、EventBus、SaveData、Config；
5. 创建可运行的主场景；
6. 初始化 backend 目录，但暂不接 RouterBase。

不要实现正式剧情、AI、美术或完整循环。

开始前先输出：
- 任务理解
- 计划修改文件
- 实施步骤
- 风险

完成后：
- 运行项目
- 列出文件
- 汇报测试
- 更新 docs/STATUS.md
- 不要自动执行下一个 Task
```

## Milestone 1

```text
阅读全部项目文档和现有代码。

只执行 Epic 1：三分钟垂直切片。

必须实现：
- 一个占位办公室
- 三个调查区
- 四次行动
- 第一轮正常读档
- 第二轮“已记录”和幽灵波形
- 强制覆盖 99% 倒退
- 幽灵存档“她曾经来过”

不得接 RouterBase。
不得使用正式 3D 素材。
所有逻辑必须断网可运行。
```

## AI 接入

```text
只执行 Epic 3。

严格遵守 docs/06_AI_SPEC.md。
AI 只能在本地 allowed_decisions 中选择。
所有返回经过 Zod 和 Godot 双重校验。
RouterBase Token 只能存在后端环境变量。
任何错误必须进入 fallback。
```
