
# 《残留项》RESIDUAL

> **你可以后悔，但它不一定愿意遗忘。**

## 锁定开发环境

- Godot：`4.7.1.stable.official`（Compatibility 渲染）
- GDScript：随 Godot `4.7.1.stable.official`
- Node.js：`24.13.0`
- npm：`11.6.2`
- Git：`2.50.1.windows.1`
- Git LFS：`3.7.0`

Godot 可执行文件由本机开发环境提供；项目配置以 `project.godot` 为准。Node.js 版本由 `.nvmrc` 与 `package.json` 双重锁定。

## 30 秒理解这款游戏

凌晨 2:47，玩家进入一间即将被远程清空的办公室，寻找失踪同事阿栀留下的证据。

玩家每轮只能执行 4 次关键行动。为了打开证据包，玩家必须删除阿栀的语音；但删除语音后，又会失去解密证据所需的声纹。

玩家只能读档重来。

第一次，存档只是工具。  
第二次，被删除的录音回来了，存档状态从“已保存”变成“已记录”。  
第三次，存档开始要求玩家坦白、交换、守约，甚至拒绝被覆盖。

玩家最终发现：SAVE_03 的人格，正是由阿栀那些被删除的数据形成的。

最后，玩家必须选择：

- 导出完整证据，让真相公开，但清空 SAVE_03；
- 保留已经拥有自我的 SAVE_03，但接受证据并不完整。


## 为什么叫《残留项》

“残留项”最初只是系统清除结束后的异常提示：

```text
DATA PURGE COMPLETE
RESIDUAL ITEMS: 1
```

开始时，它像一项应该被清理的数据。游戏结束时，玩家必须决定它是否已经不再只是数据。

## 这款游戏真正玩的是什么

表面玩法是调查办公室、收集线索和时间循环。

真正的玩法是：

> **观察、预测并博弈一个会记住玩家行为的存档系统。**

玩家可以：

- 坦白自己的读档目的
- 用残留数据和存档交换
- 隐瞒自己的删除行为
- 违背承诺
- 强制覆盖

SAVE_03 会根据这些行为形成：

- 信任
- 执念
- 对抗

它不只是说不同的话，还会真正改变游戏规则：

- 保留被删除的录音
- 让删除按钮消失
- 修改存档名称
- 篡改非核心日志
- 拒绝完整读档
- 创建无法删除的幽灵存档

## 为什么必须使用 AI

AI 不负责随机生成剧情，也不负责代替游戏设计。

Godot 本地规则先决定：

- 当前允许哪些决策
- 哪些目标可以被保护
- 哪些世界状态允许修改
- 哪些高光必须固定触发

RouterBase 调用的模型只负责：

- 根据玩家历史，在允许决策中选择最符合当前人格的一项
- 用一到两句短话表达 SAVE_03 的态度
- 让不同玩家获得不同但可解释的存档关系

所以 AI 是人格与关系的放大器，不是随时可能把剧情开进沟里的方向盘。

## MVP 范围

- 单一办公室场景
- 三个调查区域
- 每轮 4 次行动
- 三轮核心循环
- 一条主线谜题
- 一项无法在单一时间线中完成的任务
- 四种谈判行为
- 三个人格维度
- 两个主结局
- 10–15 分钟完整体验
- Windows 离线版优先，Web 版备用

## 固定演示高光

玩家选择强制覆盖后：

1. 读取进度到 99%
2. 停顿
3. 进度条开始倒退
4. SAVE_03 核心出现裂纹或异常发光
5. 一个无法删除的新存档出现

名称：

> **她曾经来过**

SAVE_03 只说：

> “你可以回去。”  
> “她留下。”

## 技术与工具

| 用途 | 工具 |
|---|---|
| 游戏引擎 | Godot 4.x 稳定版，项目初始化时锁定具体版本 |
| 编程语言 | GDScript |
| AI 网关 | RouterBase |
| 3D 素材 | Tripo3D |
| 后端代理 | Node.js LTS + TypeScript + Fastify + Zod |
| 后端测试 | Vitest |
| 3D 清理 | Blender，可选 |
| UI 设计 | Figma 或直接在 Godot 中搭建 |
| 2D 后期 | Photopea、Krita 或 Photoshop 三选一 |
| 音频编辑 | Audacity |
| 版本管理 | GitHub + Git LFS |
| Agent 执行 | Codex、Claude Code、Cursor Agent |


## 文档入口

- `docs/00_START_HERE.md`：阅读顺序与项目导航
- `docs/01_PROJECT_OVERVIEW.md`：创意、体验、可玩性与价值
- `docs/02_PRD.md`：产品目标、范围与成功指标
- `docs/03_GDD.md`：完整玩法、三轮流程与行动矩阵
- `docs/04_NARRATIVE.md`：故事真相、人物与正式文本
- `docs/05_TECH_SPEC.md`：Godot、后端和状态架构
- `docs/06_AI_SPEC.md`：AI 契约、Prompt、校验和 fallback
- `docs/07_ART_AUDIO_BIBLE.md`：视觉、3D、UI 与音频规范
- `docs/08_BACKLOG.md`：Agent 可执行任务
- `docs/09_TEST_PLAN.md`：功能、异常和体验测试
- `docs/10_DEMO_AND_PITCH.md`：演示、报名与传播文案
- `docs/11_BRAND_GUIDE.md`：品牌、标题和命名规范
- `docs/12_AGENT_PROMPTS.md`：各阶段 Agent 启动提示词
- `docs/STATUS.md`：当前进度
- `AGENTS.md`：所有编码 Agent 的强制规则

## 推荐启动顺序

```text
Milestone 0：项目骨架
→ Milestone 1：三分钟垂直切片
→ Milestone 2：完整三轮内容
→ Milestone 3：RouterBase 接入
→ Milestone 4：Tripo3D 与视觉演出
→ Milestone 5：测试、导出与现场演示
```

第一阶段不要接 AI，也不要先生成满屋子的 3D 家具。先让“已保存 → 已记录 → 99% 倒退 → 幽灵存档”完整跑通。
