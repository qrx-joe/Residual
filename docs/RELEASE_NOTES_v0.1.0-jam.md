# RESIDUAL — Vibe Jams #01 Submission

《残留项》是一款玩家与存档系统互相驯化的 AI 原生时间循环游戏。

## 运行方式

1. 下载并解压 `RESIDUAL-Windows.zip`
2. 保持 `RESIDUAL.exe` 与 `RESIDUAL.pck` 位于同一目录
3. 双击 `RESIDUAL.exe`

## 本次提交内容

- 三个调查区域与每轮四次行动
- 三轮时间循环
- 会保留玩家知识、人格和残留数据的 SAVE_03
- 坦白、交换、隐瞒、强制覆盖四种谈判行为
- “99% 倒退”与幽灵存档固定高光
- 三种关系表现与两个本地确定性结局
- 断网时可完整通关的本地 fallback

## 构建信息

- 平台：Windows
- 引擎：Godot `4.7.1.stable.official`
- SHA-256：`59BEB1BCFDEA49D21C298287DDCAE80D3D34CEE0709E92E6DBA434EA326903AF`

## 已知限制

- 网络 AI 反应默认关闭；完整游戏流程不依赖网络
- 当前包使用同版本 Godot Windows 运行二进制与 PCK 配对，体积大于标准导出模板构建
- 正式 3D 模型和配音不阻塞本次核心玩法提交
