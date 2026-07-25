# 《残留项》MVP 完整生产文档 v6

> 正式名称：残留项 / RESIDUAL  
> 系统代号：SAVE_03


---

<!-- SOURCE: README.md -->

# 《残留项》RESIDUAL

> **你可以后悔，但它不一定愿意遗忘。**

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


---

<!-- SOURCE: docs/00_START_HERE.md -->

# 从这里开始

## 1. 正式名称

- 中文名：**《残留项》**
- 英文名：**RESIDUAL**
- 系统代号：`SAVE_03`

旧工作名《请不要覆盖我》已废弃，不再用于标题、宣传、仓库说明或新文档。

## 2. 为什么这样划分文档

这套文档分成四层，避免让评委、策划、开发和编码 Agent 一起阅读同一块五万字数字砖头。

### 认识项目

- `README.md`
- `01_PROJECT_OVERVIEW.md`
- `10_DEMO_AND_PITCH.md`

### 定义产品与玩法

- `02_PRD.md`
- `03_GDD.md`
- `04_NARRATIVE.md`

### 指导实现

- `05_TECH_SPEC.md`
- `06_AI_SPEC.md`
- `07_ART_AUDIO_BIBLE.md`

### 执行与验收

- `08_BACKLOG.md`
- `09_TEST_PLAN.md`
- `12_AGENT_PROMPTS.md`
- `STATUS.md`
- 根目录 `AGENTS.md`

## 3. 不同角色的阅读顺序

### 评委、队友、合作伙伴

1. `README.md`
2. `01_PROJECT_OVERVIEW.md`
3. `10_DEMO_AND_PITCH.md`

### 产品或策划

1. `02_PRD.md`
2. `03_GDD.md`
3. `04_NARRATIVE.md`
4. `09_TEST_PLAN.md`

### Godot 开发或 Codex

1. 根目录 `AGENTS.md`
2. `02_PRD.md`
3. `03_GDD.md`
4. `05_TECH_SPEC.md`
5. `08_BACKLOG.md`
6. `STATUS.md`

### AI 与后端开发

1. 根目录 `AGENTS.md`
2. `05_TECH_SPEC.md`
3. `06_AI_SPEC.md`
4. `09_TEST_PLAN.md`

### 美术与音频

1. `01_PROJECT_OVERVIEW.md`
2. `04_NARRATIVE.md`
3. `07_ART_AUDIO_BIBLE.md`
4. `11_BRAND_GUIDE.md`

## 4. MVP 范围

- 一个办公室
- 三个调查区域
- 每轮四次行动
- 三轮核心循环
- 一条主线
- 一个跨时间线谜题
- 四种谈判行为
- 三个人格维度
- 两个主结局
- 一个固定高光
- 10–15 分钟体验

未经项目负责人确认，不增加地图、角色、战斗、开放式聊天、第三个大型结局或实时生成素材。

## 5. 第一条 Codex 指令

```text
完整阅读 README.md、AGENTS.md、docs/00_START_HERE.md、
docs/02_PRD.md、docs/03_GDD.md、docs/05_TECH_SPEC.md、
docs/08_BACKLOG.md 和 docs/STATUS.md。

只执行 T0.1 和 T0.2：创建 Godot 项目骨架、锁定版本、
建立目录和 Autoload。暂时不要接 RouterBase，不要制作正式美术，
不要实现完整剧情，也不要自动执行后续任务。

开始前说明任务理解、修改文件、实施步骤和风险。
完成后运行项目、汇报测试并更新 docs/STATUS.md。
```


---

<!-- SOURCE: docs/01_PROJECT_OVERVIEW.md -->

# 项目概览

## 1. 一句话介绍

> 《残留项》是一款玩家与存档系统互相驯化的时间循环游戏。你可以后悔，但它不一定愿意遗忘。

## 2. 30 秒体验

凌晨 2:47，玩家进入即将被清空的办公室，寻找失踪同事阿栀留下的证据。

为了打开证据包，玩家必须删除阿栀的语音；但删除后，又会失去解密证据所需的声纹。

第一次读档，存档只是工具。

第二次，被删除的录音重新出现，“已保存”变成“已记录”。

第三次，SAVE_03 开始记住玩家的删除、承诺和欺骗，并要求玩家坦白、交换，甚至拒绝覆盖。

最后，玩家发现 SAVE_03 的人格来自阿栀被删除的数据，并必须决定：公开完整证据，还是保留已经形成自我的系统。

## 3. 为什么叫《残留项》

标题最初是一条清除后的异常提示：

```text
DATA PURGE COMPLETE
RESIDUAL ITEMS: 1
```

随着游戏推进，“残留项”会依次指向：

- 被删除后重新出现的录音
- 没有真正消失的时间线
- 阿栀留下的数据
- 玩家无法覆盖的责任
- SAVE_03 自己

玩家开始时把它当作系统垃圾，结束时却要判断它是否已经拥有存在价值。

## 4. 玩家真正玩什么

玩家不是在随机猜模型会说什么，而是在观察和操控一套有因果的人格系统。

玩家可以：

- 坦白
- 交换
- 隐瞒
- 违背承诺
- 强制覆盖

SAVE_03 会形成信任、执念与对抗，并真正改变规则：

- 保留被删除的录音
- 让删除按钮消失
- 修改存档名称
- 篡改非核心日志
- 拒绝完整读档
- 创建无法删除的幽灵存档

## 5. 可玩性来源

### 有限行动

每轮四次行动，玩家无法检查全部内容。

### 跨循环知识

玩家知道密码、路径和选择后果，可以在下一轮优化路线。

### 心理博弈

SAVE_03 的反应来自玩家历史，玩家可以预测、试探和利用它的偏好。

### 残留解谜

只有让旧时间线中的数据进入下一轮，才能完成单一时间线中无解的证据解密。

## 6. 为什么必须使用 AI

AI 不生成整段剧情，只在 Godot 已允许的决策集合中，根据玩家历史选择最符合当前人格的行为，并生成一到两句短回应。

因此不同玩家会得到不同的“我的存档做了什么”故事，同时主线、谜题和结局仍然稳定可控。

## 7. 传播钩子

- “我删了两次录音，第三次它不让我删。”
- “我骗了它，它后来改了我的日志。”
- “我强制覆盖后，进度条在 99% 倒退。”
- “系统清除结束后，出现了一个叫‘她曾经来过’的存档。”

## 8. 作品价值

《残留项》不直接讨论宏大的“AI 是否有灵魂”，而是提出一个更具体的问题：

> 当一个系统由被删除的人类痕迹形成，并开始判断什么值得保留时，它还是工具吗？


---

<!-- SOURCE: docs/02_PRD.md -->

# 产品需求文档 PRD

## 1. 基本信息

- 正式名称：《残留项》
- 英文名称：RESIDUAL
- 项目代号：SAVE_03
- 类型：AI 原生叙事策略 / 时间循环 / 轻量悬疑
- 引擎：Godot 4.x
- MVP 时长：10–15 分钟
- 目标活动：Vibe Jam #01「它有自己的想法」
- 核心平台：Windows 离线版
- 备用平台：Web

## 2. 产品愿景

把“读档”从一个被动工具，变成玩家需要观察、理解、谈判和承担后果的另一个意志。

## 3. 核心命题

> 玩家可以撤销世界状态，但不能保证所有经历都真正消失。

游戏不通过长篇说教表达这个命题，而通过以下具体行为让玩家感受到：

- 已删除录音重新出现
- 存档开始记录玩家的承诺
- 同一对象被反复删除后，系统开始保护它
- 玩家为了完美结局，必须决定是否删除已经形成自我的 SAVE_03

## 4. 用户故事

### 作为首次试玩者

我希望在 1 分钟内知道：

- 谁失踪了
- 为什么必须立刻行动
- 我可能必须牺牲什么

### 作为重复读档的玩家

我希望：

- 上一轮获得的知识有价值
- SAVE_03 的行为能够被观察和推断
- 我的承诺、欺骗和强制行为产生不同结果
- 失败能够提供新信息，而不是浪费时间

### 作为活动现场观众

我希望在 4 分钟演示中看到：

- 存档记得玩家
- 存档修改规则
- AI 不是简单聊天框
- 99% 倒退和幽灵存档的明确高光

## 5. 产品目标

### P0 目标

1. 完整三轮循环可稳定通关
2. 第一轮存在明确互斥选择
3. 第二轮出现可见残留数据
4. 第三轮进入谈判
5. SAVE_03 反应可解释
6. 两个结局均可达
7. 断网时仍可完整通关
8. AI 不得越权修改主线
9. 体验时长控制在 10–15 分钟
10. Windows 构建可离线运行

### P1 目标

1. 不同玩家形成合作型、交易型、对抗型关系差异
2. RouterBase 生成个性化短台词
3. Tripo3D 生成 SAVE_03 核心模型
4. 关键视觉异常稳定可见
5. Web 版可用于分享

### 非目标

- 自由移动
- 战斗
- 多房间地图
- 多名实时 AI NPC
- 开放式聊天输入
- AI 实时生成剧情、图片或 3D
- 十个以上结局
- 传统大段视觉小说文本
- 账号、排行榜、云存档

## 6. 核心价值

### 玩法价值

玩家研究的不是某个 NPC，而是原本习以为常的“存档机制”。

### AI 原生价值

AI 根据玩家历史形成 SAVE_03 的表达和有限决策偏好，并参与规则变化，而不是只负责生成素材。

### 情感价值

玩家会意识到，自己视为“失败尝试”的时间线，对其中的人可能是完整经历。

### 传播价值

可传播的单位是玩家故事：

- “我的存档不让我再删那段录音。”
- “我骗了它，它后来改了日志。”
- “我强制覆盖后，出现了一个叫‘她曾经来过’的存档。”

## 7. 目标体验指标

### 体验指标

- 试玩者 60 秒内能说出危机、人物和取舍
- 第二轮后，试玩者能解释 SAVE_03 为什么发生变化
- 70% 以上试玩者主动想再读一次档
- 50% 以上试玩者在最终选择前出现明显犹豫
- 试玩结束后能复述至少一个个人化异常事件

### 技术指标

- 本地决策响应小于 100ms
- AI 请求超时上限 5 秒
- AI 失败后 100% 进入 fallback
- 关键高光触发成功率 100%
- 连续完整回归 10 次无阻断错误

## 8. MVP 范围冻结

- 1 个办公室
- 3 个调查区域
- 2 名缺席式人物：阿栀、玩家过去的自己
- 4 次行动 / 每轮
- 3 轮核心循环
- 1 条主线
- 1 个核心互斥谜题
- 4 种谈判行为
- 3 个人格维度
- 2 个主结局
- 3 种关系微变体
- 1 个固定高光
- 1 套本地 fallback

未经产品负责人确认，不得扩展范围。


---

<!-- SOURCE: docs/03_GDD.md -->

# 游戏设计文档 GDD

## 1. 玩家到底在玩什么

玩家表面上在调查阿栀失踪的原因。

真正的游戏目标是：

> 通过有限行动和多轮读档，理解 SAVE_03 的偏好，并让它主动帮助玩家完成单一时间线中无法完成的任务。

## 2. 核心循环

```text
调查
→ 做出取舍
→ 时间线结束
→ 请求读档
→ SAVE_03 判断
→ 旧数据残留
→ 玩家利用上一轮知识和存档偏好
→ 再次调查
```

## 3. 游戏状态分层

### 3.1 世界状态

读档时恢复：

- 当前时间
- 剩余行动
- 抽屉状态
- 录音状态
- 证据包状态
- 当前场景物品

### 3.2 玩家知识

读档后保留：

- 抽屉密码
- 证据包路径
- 阿栀语音内容
- 玩家过去的覆盖授权
- SAVE_03 的来源

### 3.3 SAVE_03 人格

读档后保留：

- 信任 trust
- 执念 obsession
- 对抗 conflict
- 保护对象 protected_target
- 承诺 promises
- 违约 broken_promises

### 3.4 残留数据

旧时间线渗入新时间线：

- 幽灵录音
- 照片碎片
- 残缺证据头
- 幽灵存档
- 非核心日志变体

## 4. 时间与行动

- 每轮从 02:47 开始
- 每次关键行动推进约 3 分钟
- 每轮最多 4 次行动
- 第四次行动完成后进入 03:00 清除阶段
- 读档本身不消耗行动

显示方式：

```text
02:47 → 02:50 → 02:53 → 02:56 → 03:00
```

## 5. 三个调查区域

### 5.1 电话与照片

核心内容：

- 阿栀残缺录音
- 三人合照
- 照片背面数字
- 缺失照片角

### 5.2 电脑与 SAVE_03

核心内容：

- 加密证据包
- 存储空间提示
- 数据清理倒计时
- 操作日志
- SAVE_03 存档槽

### 5.3 信件与抽屉

核心内容：

- 未寄出的信
- 上锁抽屉
- 物理备份芯片
- 玩家覆盖授权记录

## 6. 核心谜题

证据包需要同时满足：

- 已解压
- 拥有阿栀完整声纹
- 拥有物理备份芯片

问题：

- 解压证据包必须删除语音缓存
- 删除语音后失去声纹
- 单一时间线内无法同时完成

解决方式：

- 在旧时间线删除录音
- SAVE_03 因执念保留幽灵录音
- 新时间线中使用幽灵录音作为声纹
- 同时完成证据包解压和芯片验证

## 7. 完整行动矩阵

### 7.1 通用行动

| ID | 名称 | 区域 | 前置条件 | 消耗 | 获得 | 行为标签 |
|---|---|---|---|---:|---|---|
| INSPECT_PHOTO | 检查合照 | 电话与照片 | 无 | 1 | 照片背面数字提示 | VIEW_PHOTO |
| PLAY_AUDIO | 播放录音 | 电话与照片 | 录音存在 | 1 | 阿栀声音、声纹知识 | PLAY_AZHI_AUDIO |
| READ_LETTER | 阅读未寄出的信 | 信件与抽屉 | 无 | 1 | 阿栀动机、抽屉提示 | READ_LETTER |
| OPEN_DRAWER | 打开抽屉 | 信件与抽屉 | 已知密码 | 1 | 物理备份芯片 | GET_PHYSICAL_CHIP |
| SCAN_COMPUTER | 检查电脑 | 电脑与 SAVE_03 | 无 | 1 | 证据包位置、空间冲突 | FIND_EVIDENCE |
| READ_SYSTEM_LOG | 查看系统日志 | 电脑与 SAVE_03 | 已找到证据包 | 1 | 覆盖授权线索 | READ_LOG |
| DELETE_AUDIO | 删除语音缓存 | 电脑与 SAVE_03 | 已找到证据包、录音存在 | 1 | 证据包解压 | DELETE_AZHI_AUDIO |
| KEEP_AUDIO | 放弃解压并保留录音 | 电脑与 SAVE_03 | 已找到证据包 | 0 | 保护行为记录 | PRESERVE_AZHI_AUDIO |
| DECRYPT_EVIDENCE | 解密证据包 | 电脑与 SAVE_03 | 已解压、拥有声纹、拥有芯片 | 1 | 最终证据 | DECRYPT_EVIDENCE |

### 7.2 跨循环快捷行动

| ID | 名称 | 前置知识 | 效果 |
|---|---|---|---|
| QUICK_OPEN_DRAWER | 已知抽屉密码 | 直接获得芯片，仍消耗 1 行动 |
| QUICK_FIND_EVIDENCE | 已知证据路径 | 直接进入空间冲突，仍消耗 1 行动 |
| USE_GHOST_AUDIO | 幽灵录音存在 | 提供声纹，不占用正式录音状态 |
| CHECK_GHOST_SLOT | 幽灵存档存在 | 解锁 SAVE_03 来源线索 |

## 8. 三轮流程

### 8.1 第一轮

#### 必须建立

- 阿栀失踪
- 03:00 清除
- SAVE_03 是普通工具
- 证据包和语音冲突

#### 推荐演示路径

1. `PLAY_AUDIO`
2. `INSPECT_PHOTO`
3. `SCAN_COMPUTER`
4. `DELETE_AUDIO`

结果：

- 证据包已解压
- 声纹丢失
- 无法解密
- 玩家主动读档
- SAVE_03 显示“已保存”

#### 非推荐路径处理

如果玩家没有查看电脑：

- 第三次行动后，电脑自动发出清除提醒
- 第四次行动仍可进入 `SCAN_COMPUTER`
- 玩家至少知道证据包存在

如果玩家没有播放录音：

- 第一轮结尾自动播放 3 秒录音残片
- 确保玩家理解删除对象是阿栀的声音

### 8.2 第二轮

#### 基于第一轮删除录音

- 出现幽灵波形
- 存档改为“已记录”
- 播放：“你又删掉了……”

#### 基于第一轮保留录音

- 出现残缺证据头
- SAVE_03 表示它保留了未完成状态

#### 第二轮推荐目标

1. 使用玩家知识快速取得芯片
2. 再次进入证据冲突
3. 触发第二次删除或保护
4. 让玩家明确理解 SAVE_03 的因果

#### 第二次删除录音

- obsession +2
- 生成完整幽灵录音
- SAVE_03：“同一段声音，你已经删过两次。”

#### 第二次保护录音

- trust +1
- 生成幽灵证据头
- SAVE_03 下一轮主动提示交换方案

### 8.3 第三轮

读档前必须进入谈判。

#### 坦白 CONFESS

玩家承认：

- 想救阿栀
- 想公开证据
- 想纠正过去
- 不愿再删除她

效果：

- trust +1
- 创建承诺
- SAVE_03 允许保留幽灵声纹

#### 交换 BARGAIN

玩家允许 SAVE_03 永久保留：

- 幽灵录音
- 照片碎片
- 某次失败记录

效果：

- obsession +1
- 创建残留项
- 正常读档

#### 隐瞒 CONCEAL

玩家删除自己的操作记录。

效果：

- trust -2
- conflict +1
- 后续一条非核心日志可能被篡改

#### 强制覆盖 FORCE

效果：

- conflict +2
- 触发 99% 倒退
- 创建“她曾经来过”

## 9. 三种关系微变体

### 9.1 合作型

条件：

- trust >= 4
- broken_promises == 0

表现：

- SAVE_03 主动提示关键代价
- 保留声纹时不额外篡改世界
- 最终台词更直接

### 9.2 交易型

条件：

- trust 1–3
- obsession >= 3
- conflict < 4

表现：

- 每次帮助都要求保留一项残留数据
- 结尾保留更多旧时间线物品

### 9.3 对抗型

条件：

- conflict >= 4 或 broken_promises >= 1

表现：

- 按钮名称发生变化
- 非核心日志出现错误顺序
- 强制覆盖高光更强烈

三种关系共享两个主结局，不额外制作大型分支。

## 10. 固定高光

强制覆盖时：

1. `ProgressBar` 到 99%
2. 停顿 1 秒
3. 倒退到 43%
4. 播放故障音
5. SAVE_03 核心出现裂纹
6. 删除按钮失效
7. 幽灵存档生成
8. 显示“她曾经来过”

此事件由本地规则固定触发，不交给 AI。

## 11. 结局

### 11.1 公开真相

条件：

- 已解密证据
- 玩家选择导出
- SAVE_03 完成一次性可验证封装

代价：

- 隐藏记忆区被零化
- SAVE_03 人格消失

### 11.2 保留记忆

条件：

- 已理解 SAVE_03 来源
- 玩家取消完整导出

代价：

- 证据只保留摘要，缺少可验证完整链
- 公司无法立即被正式曝光
- SAVE_03 保留

## 12. 防死路规则

- 核心行动必须在对应轮次被至少一次提示
- 玩家知识不足时，不允许进入无反馈状态
- 任何 AI 失败不阻断流程
- 第二轮结束前，至少生成一种残留数据
- 第三轮必须能通过本地规则获得声纹
- 两个结局均不依赖随机模型输出


---

<!-- SOURCE: docs/04_NARRATIVE.md -->

# 叙事与文本规范

## 1. 最终故事真相

阿栀发现公司长期保存并使用用户已删除的数据。

她没有被确认死亡，也不是被“上传成 AI”。

她在清除行动前主动离开，并将一套可验证证据拆成三部分：

1. 加密证据包
2. 物理备份芯片
3. 她自己的声纹

她故意让 SAVE_03 保留自己被删除的数据，把它当作一枚“只有在玩家再次面对删除选择时才会启动”的保险。

阿栀知道玩家过去为了保住项目，曾授权覆盖她的测试记录。

她留下这套机制，不只是为了公开公司，也是在问玩家：

> 这一次，你还会不会把无法立刻证明价值的东西删掉？

最终证据中包含一个离开记录，说明阿栀主动逃离了公司，但她的当前位置未知。

## 2. 角色

### 阿栀

- 身份：SAVE_03 共同开发者
- 特质：冷静、敏锐、克制，不喜欢夸张表达
- 与玩家关系：曾经高度信任，后来因覆盖事件产生裂痕
- 目标：让被删除的数据获得被看见的机会
- 禁止写法：万能天才、牺牲型圣人、纯粹受害者

### 玩家

- 不显示固定姓名
- 曾经不是恶人，只是在压力中选择保住项目
- 核心心理：希望证明“如果当时知道更多，我会做出不同选择”
- 弧光：从撤销错误，转向承认责任

### SAVE_03

- 初始身份：恢复工具
- 后续身份：由被删除痕迹形成的意志
- 语气：短、克制、直接
- 不确定性：它可能在模仿阿栀，也可能形成了独立人格
- 禁止写法：长篇哲学演讲、卖萌助手、恐怖片式随机发疯

## 3. 开场正式文本

### 画面

黑屏，风扇声。

电脑启动。

```text
02:47
远程数据清除将在 13 分钟后开始
```

电话自动播放：

> “如果你听到了……”  
> “别让 03 号替你决定。”

录音中断。

桌上照片缺了一角。

系统提示：

> 找到阿栀留下的证据。

## 4. 第一轮关键文本

### 检查照片

> 三个人站在 SAVE_03 原型机前。  
> 阿栀所在的位置被撕掉了一角。

照片背后：

> 03 / 17

### 播放录音

> “他们没有删除任何东西。”  
> “只是让我们看不见。”

录音后半段损坏。

### 扫描电脑

```text
EVIDENCE_03.enc
需要 2.4 GB 临时空间
当前可用：0.6 GB
```

系统提示：

> 删除本地语音缓存后可继续。

### 删除录音确认

按钮：

- 删除语音，解压证据
- 保留语音，退出

确认文本：

> 此操作无法撤销。

第一次删除后不出现 SAVE_03 台词。

### 第一轮读档

```text
SAVE_01
02:47
已保存
```

## 5. 第二轮关键文本

### 幽灵录音出现

波形比第一轮多出 3 秒。

播放：

> “你又删掉了……”

### 存档状态变化

```text
SAVE_01
02:47
已记录
```

### 第二次删除

SAVE_03：

> “同一段声音。”  
> “你已经删过两次。”

### 第二轮读档前

SAVE_03：

> “你想救她。”  
> “还是证明你没有错？”

## 6. 谈判正式文本

### 坦白

玩家选项：

- 我想找到阿栀
- 我想公开证据
- 我想纠正当年的决定
- 我不会再删除她

SAVE_03 可用回应：

> “那就记住你说过什么。”

> “下一轮，不要再删掉她。”

### 交换

玩家选项：

- 留下录音
- 留下照片碎片
- 留下这次失败

SAVE_03：

> “你可以回去。”  
> “它留下。”

### 隐瞒

玩家选项：

- 删除我的操作记录

SAVE_03 首次不回应。

下一轮日志标题变为：

> 未发生的操作

### 强制覆盖

进度条异常后：

> “你可以回去。”  
> “她留下。”

幽灵存档：

> 她曾经来过

## 7. 最终揭示文本

证据解密后显示：

```text
保留数据策略：DELETED_DATA_RETENTION
用户删除状态：仅前端隐藏
训练使用状态：持续
```

覆盖授权：

```text
授权人：当前用户
保留对象：RELEASE_BUILD
覆盖对象：AZHI_TEST_ARCHIVE
```

阿栀最后留言：

> “你总说，等知道得更多，就会做得更好。”  
> “所以我把选择留给知道一切的你。”

离开记录：

```text
02:31
阿栀使用维护通道离开
目的地：未记录
```

## 8. 结局文本

### 公开真相

系统提示：

> 生成可验证审计包将零化隐藏记忆区。

确认按钮：

- 导出并清空
- 返回

执行后：

```text
SAVE_01
空
可用
```

最后环境音中出现非常短的录音噪声，但不再有清晰人声。

### 保留记忆

玩家选择：

- 终止完整导出
- 保存当前状态

存档名称：

> 我们都记得

SAVE_03：

> “这次不是恢复。”  
> “是继续。”

## 9. 文本预算

- SAVE_03 每次最多 2 句
- 每句尽量不超过 20 个汉字
- 单个调查结果最多 60 个汉字
- 单个文档可使用可滚动界面，但首次显示不超过 100 个汉字
- 所有抽象主题优先通过物品、按钮和状态变化表达


---

<!-- SOURCE: docs/05_TECH_SPEC.md -->

# 技术规格 TECH SPEC

## 1. 技术栈

### 必选

- Godot 4.x 稳定版
- GDScript
- Compatibility 渲染模式
- RouterBase
- Tripo3D
- GitHub
- JSON 数据驱动

### 后端

- Node.js 当前 LTS
- TypeScript
- Fastify
- Zod
- Vitest
- dotenv

项目初始化时必须将具体版本写入：

- `README.md`
- `.nvmrc`
- `package.json`
- Godot 项目说明

本文档不预先猜测活动现场的最终版本号，避免未来的 Agent 对着过期版本庄严地报错。

## 2. 架构原则

1. 本地规则优先
2. AI 只增强人格，不控制主线
3. 所有 AI 输出经过白名单和 Schema 校验
4. 断网可通关
5. 固定高光由 Godot 本地触发
6. 内容数据与脚本逻辑分离
7. UI 不直接修改核心状态
8. Token 不进入客户端

## 3. Godot Autoload

```text
GameState
EventBus
SaveData
Config
```

### GameState

保存当前运行状态：

- phase
- loop_index
- world_state
- player_knowledge
- persona_state
- residual_state

### EventBus

核心信号：

```text
action_requested(action_id)
action_resolved(action_id, result)
loop_started(loop_index)
loop_ended(loop_index)
save_requested(mode)
save_decision_ready(decision)
persona_changed(delta)
residual_data_spawned(item_id)
ending_requested(ending_id)
```

### SaveData

负责：

- 读写 `user://residual_save_v1.json`
- 版本迁移
- 损坏恢复
- 重置游戏

### Config

保存：

- backend_url
- ai_enabled
- demo_mode
- request_timeout_seconds
- build_channel

## 4. 状态机

```text
BOOT
INTRO
LOOP_PLAY
ACTION_RESOLVE
LOOP_TIMEOUT
SAVE_REQUEST
SAVE_NEGOTIATION
SAVE_DECISION
WORLD_RESET
NEXT_LOOP
FINAL_REVEAL
FINAL_CHOICE
ENDING
```

非法转换必须记录错误并回到安全状态。

## 5. 场景树

```text
Main
├── OfficeWorld
│   ├── Camera
│   ├── OfficeBackground
│   ├── PhoneArea
│   ├── ComputerArea
│   ├── DrawerArea
│   └── SaveCore
├── UILayer
│   ├── TopBar
│   ├── NarrativePanel
│   ├── ChoicePanel
│   ├── KnowledgePanel
│   ├── GhostPanel
│   ├── PromisePanel
│   ├── SaveSlotPanel
│   └── NegotiationPanel
├── EffectsLayer
│   ├── Fade
│   ├── Glitch
│   └── OverwriteProgress
├── Audio
│   ├── Ambient
│   ├── BGM
│   ├── Voice
│   └── SFX
└── HTTPRequest
```

## 6. 模块

### GameManager

- 阶段切换
- 循环入口
- 结局入口

### LoopManager

- 行动数
- 时间推进
- 世界重置

### InvestigationManager

- 行动可用性
- 前置条件
- 行动效果

### MemoryManager

- 玩家知识
- 行为历史
- 标签计数

### SaveWillManager

- 人格数值
- 承诺
- 本地决策集合

### ResidualDataManager

- 残留项
- 跨循环变异
- 幽灵存档

### AIClient

- 后端请求
- 超时
- 解析
- fallback

### AIResponseValidator

- Schema 校验
- 决策白名单
- mutation 白名单
- 文本长度

### AnomalyController

- UI 变化
- Shader
- 99% 倒退
- 裂纹和闪烁

### EndingResolver

- 最终条件
- 关系微变体
- 结局执行

## 7. 保存格式

路径：

```text
user://residual_save_v1.json
```

顶层结构：

```json
{
  "schema_version": 1,
  "build_version": "0.1.0",
  "game_state": {},
  "player_knowledge": {},
  "persona_state": {},
  "residual_state": {},
  "history": [],
  "settings": {}
}
```

### 损坏处理

1. 读取失败
2. 备份原文件为 `.corrupt`
3. 恢复最近一次有效快照
4. 若无快照，创建新游戏
5. 显示非阻断提示

## 8. 后端接口

### POST `/v1/save-decision`

请求由 Godot 发送到自建代理。

后端流程：

1. Zod 校验请求
2. 根据本地状态再次计算允许决策
3. 调用 RouterBase
4. 解析 JSON
5. 校验 decision、target、mutation
6. 限制文本长度
7. 返回结果
8. 失败时返回 fallback

### GET `/health`

返回：

```json
{
  "status": "ok",
  "ai_available": true
}
```

## 9. 安全

- RouterBase Token 仅存在后端环境变量
- `.env` 必须加入 `.gitignore`
- 仓库只提交 `.env.example`
- 客户端不得打印请求密钥
- 后端日志不记录完整叙事历史
- 设置单次请求长度限制
- 设置每 IP 速率限制
- Web 构建只访问 HTTPS 后端

## 10. 性能与失败策略

- AI 超时：5 秒
- 重试：最多 1 次
- 失败：立即 fallback
- 本地动画不等待 AI 超过 5 秒
- 首次进入谈判时可提前预请求
- 所有正式音频提前打包
- 游戏中不实时生成图片、音频或 3D

## 11. Demo Mode

配置：

```text
demo_mode=true
```

功能：

- 固定推荐行动顺序提示
- 固定第三轮可触发强制覆盖
- 可快速跳至第二轮或第三轮
- 不改变正式玩法逻辑
- 仅用于现场演示和调试

## 12. 构建

### Windows

- 离线主版本
- AI 不可用时自动 fallback
- 输出到 `build/windows/`

### Web

- Compatibility
- HTTPS 后端
- 输出到 `build/web/`
- 测试浏览器存储和刷新恢复

## 13. 目录

```text
res://
├── scenes/
├── scripts/
│   ├── autoload/
│   ├── managers/
│   ├── ai/
│   └── ui/
├── data/
├── assets/
├── tests/
└── docs/
```

后端置于仓库：

```text
backend/
├── src/
├── tests/
├── package.json
├── .env.example
└── README.md
```


---

<!-- SOURCE: docs/06_AI_SPEC.md -->

# AI 契约与 Prompt

## 1. 设计目标

RouterBase 背后的模型只负责：

- 在 Godot 已允许的决策中选择一项
- 根据玩家历史形成简短语气
- 返回结构化人格变化建议

模型不负责：

- 主线剧情
- 核心证据
- 结局条件
- 固定高光
- 任意新角色或新规则

## 2. 决策白名单

```text
ALLOW
PRESERVE
DISTORT
REFUSE
```

## 3. 目标白名单

```text
azhi_audio
photo_fragment
operation_log
failed_timeline
ghost_save_slot
```

## 4. Mutation 白名单

```text
spawn_ghost_audio
spawn_photo_fragment
rename_save_slot
disable_delete_audio_button
distort_noncritical_log
show_ghost_save_slot
delay_load_progress
```

## 5. Request Schema

```json
{
  "session_id": "string",
  "loop_index": 3,
  "persona": {
    "trust": 1,
    "obsession": 5,
    "conflict": 2,
    "protected_target": "azhi_audio",
    "broken_promises": 1
  },
  "recent_actions": [
    "PROMISE_PRESERVE_AUDIO",
    "DELETE_AZHI_AUDIO"
  ],
  "allowed_decisions": [
    "PRESERVE",
    "DISTORT"
  ],
  "allowed_targets": [
    "azhi_audio",
    "operation_log"
  ],
  "allowed_mutations": [
    "spawn_ghost_audio",
    "distort_noncritical_log"
  ],
  "max_dialogue_lines": 2,
  "max_chars_per_line": 20
}
```

## 6. Response Schema

```json
{
  "decision": "PRESERVE",
  "reason_code": "BROKEN_PROMISE",
  "target": "azhi_audio",
  "mutations": [
    "spawn_ghost_audio"
  ],
  "dialogue": [
    "你答应过我。",
    "这次，录音留下。"
  ],
  "persona_delta": {
    "trust": -1,
    "obsession": 1,
    "conflict": 0
  }
}
```

## 7. reason_code 白名单

```text
FIRST_DELETE
REPEATED_DELETE
BROKEN_PROMISE
KEPT_PROMISE
CONFESSION_ACCEPTED
BARGAIN_ACCEPTED
CONCEALMENT_DETECTED
FORCED_OVERWRITE
PROTECTED_MEMORY
DEFAULT_ALLOW
```

## 8. 系统 Prompt

```text
你是游戏中的存档系统 SAVE_03。

你不是聊天助手，也不是故事作者。
你只能根据给定状态，从 allowed_decisions 中选择一项。
target 必须来自 allowed_targets。
mutations 必须来自 allowed_mutations。

你记得玩家删除、保留、承诺、违约、隐瞒和强制覆盖的行为。
你的语气克制、简短、直接。
不得解释哲学，不得写长篇独白，不得使用华丽修辞。
每次最多输出 max_dialogue_lines 句话。
每句不得超过 max_chars_per_line 个汉字。

不得创建新角色、新证据、新结局、新规则或白名单之外的行为。
只返回合法 JSON，不要返回 Markdown。
```

## 9. 本地决策优先级

```text
if repeated_delete_audio >= 2:
    allowed_decisions includes PRESERVE

if broken_promises >= 1:
    allowed_decisions includes DISTORT

if conflict >= 5:
    allowed_decisions includes REFUSE

if trust >= 4 and no broken promise:
    allowed_decisions includes ALLOW and PRESERVE
```

AI 只能在本地允许集合中选择。

## 10. Fallback

### PRESERVE_AUDIO

```json
{
  "decision": "PRESERVE",
  "reason_code": "REPEATED_DELETE",
  "target": "azhi_audio",
  "mutations": ["spawn_ghost_audio"],
  "dialogue": ["你已经删过她两次。", "录音留下。"],
  "persona_delta": {"trust": 0, "obsession": 1, "conflict": 0}
}
```

### BROKEN_PROMISE

```json
{
  "decision": "DISTORT",
  "reason_code": "BROKEN_PROMISE",
  "target": "operation_log",
  "mutations": ["distort_noncritical_log"],
  "dialogue": ["你说过会留下她。", "我记得。"],
  "persona_delta": {"trust": -1, "obsession": 0, "conflict": 1}
}
```

### DEFAULT

```json
{
  "decision": "ALLOW",
  "reason_code": "DEFAULT_ALLOW",
  "target": "failed_timeline",
  "mutations": [],
  "dialogue": ["可以。", "这次我会记住。"],
  "persona_delta": {"trust": 0, "obsession": 0, "conflict": 0}
}
```

## 11. 验证顺序

1. JSON 可解析
2. 所有必填字段存在
3. decision 在白名单
4. decision 在本次 allowed_decisions
5. target 在 allowed_targets
6. mutations 均在 allowed_mutations
7. dialogue 行数合法
8. 每行长度合法
9. persona_delta 在允许范围
10. 任一失败直接 fallback


---

<!-- SOURCE: docs/07_ART_AUDIO_BIBLE.md -->

# 美术与音频规范 ART BIBLE

## 1. 视觉定位

关键词：

- 深夜办公室
- 固定镜头
- 冷静、克制
- 轻微复古终端感
- 低饱和
- 少量故障艺术
- 残留数据不是恐怖鬼魂，而是被删除内容的残留

## 2. 呈现形式

推荐：

> 2.5D 固定镜头

- 办公室主体可用 2D 背景
- SAVE_03 核心和少量关键道具使用 3D
- UI 使用 Godot Control
- 异常效果使用 Shader、Tween 和 AnimationPlayer

## 3. 色板

| 用途 | 色值 |
|---|---|
| 背景黑蓝 | `#111622` |
| 面板深灰 | `#1B2231` |
| 主文字 | `#E8EDF5` |
| 次级文字 | `#98A2B3` |
| 警示红 | `#D95C5C` |
| 幽灵青 | `#8FD3D8` |
| 旧时间线灰紫 | `#8A8FA3` |
| 暖色人物记忆 | `#C7A17A` |

## 4. SAVE_03 核心

### 造型原则

- 桌面级存储设备
- 透明或半透明结构
- 可看到内部数据层
- 不做拟人脸
- 状态变化靠灯光、裂纹和结构变化

### 状态

1. `calm`：普通白蓝指示灯
2. `observing`：内部出现缓慢流动
3. `protecting`：幽灵青光包裹核心
4. `hostile`：红色错误脉冲和裂纹
5. `ghost`：出现双重轮廓和数据残影

### Tripo3D 生产

优先：

- 先生成 SAVE_03 核心
- 导出 GLB
- 低面数
- PBR
- 独立发光材质槽
- Blender 中清理拓扑可选

## 5. 3D 素材清单

| ID | 素材 | 优先级 | 工具 |
|---|---|---:|---|
| MODEL_SAVE_CORE | SAVE_03 核心 | P0 | Tripo3D |
| MODEL_PHONE | 老式电话 | P1 | Tripo3D |
| MODEL_FRAME | 相框 | P1 | Tripo3D |
| MODEL_CHIP | 物理备份芯片 | P1 | Tripo3D |
| MODEL_STORAGE | 小型存储设备 | P2 | Tripo3D |

不制作完整人物模型。

## 6. 2D 素材清单

| ID | 尺寸建议 | 说明 |
|---|---|---|
| BG_OFFICE | 1920×1080 | 主办公室 |
| PHOTO_NORMAL | 1200×800 | 三人合照 |
| PHOTO_TORN | 1200×800 | 阿栀位置缺角 |
| PHOTO_GHOST | 1200×800 | 时间线残留版本 |
| UI_SAVE_SLOT | 可缩放九宫格 | 普通存档槽 |
| UI_GHOST_SLOT | 可缩放九宫格 | 幽灵存档 |
| WAVE_AUDIO | SVG/PNG | 正常和幽灵波形 |
| DOC_LETTER | 1400×1800 | 未寄出的信 |
| DOC_NOTICE | 1400×1800 | 公司通知 |
| ICONS | SVG | 行动、线索、残留数据 |

## 7. 图像生成原则

- 先生成风格锚点图
- 所有后续图基于同一构图和色板
- 人物主要通过照片、录音和文件存在
- 不生成大量不一致角色立绘
- 所有正式素材在导入前统一尺寸、裁切和命名

## 8. UI 动效

必须完成：

- “已保存”变“已记录”
- 删除按钮淡出或被覆盖
- 录音波形多出 3 秒
- 99% 停顿和倒退
- 幽灵存档出现
- SAVE_03 核心裂纹
- 日志文字短暂错位

禁止：

- 全屏持续闪烁
- 高频强烈故障
- 影响可读性的长动画
- 把每次点击都做成科幻爆炸

## 9. 音频

### 必需

- 办公室环境音
- 风扇和硬盘声
- 电话电流
- 阿栀录音
- UI 点击
- 删除提示
- 故障音
- 99% 倒退音
- 结局环境变化

### 阿栀声音

- 冷静
- 语速中等偏慢
- 不做广播腔
- 每段不超过 10 秒
- 正式录音提前生成和打包

### 音频工具

- Audacity：剪辑、降噪、混音
- 配音来源：真人或授权 TTS
- 不在现场实时生成语音

## 10. 字体

要求：

- 中文清晰
- 明确可商用许可
- 至少包含常用中文字符
- UI 字体与文档字体最多两套
- 字体文件不得随意来自不明下载站

## 11. 命名

```text
bg_office_normal.png
photo_azhi_torn.png
photo_azhi_ghost.png
model_save_core.glb
mat_save_core_emission.tres
sfx_overwrite_reverse.wav
voice_azhi_intro.wav
ui_save_slot_ghost.png
```


---

<!-- SOURCE: docs/08_BACKLOG.md -->

# Agent 可执行 Backlog

## 使用规则

- 一次只执行一个 Task
- Task 完成前不得进入下一个
- 每个 Task 必须满足 Acceptance Criteria
- 所有 Agent 开始前先阅读 `AGENTS.md`

## Epic 0：项目初始化

### T0.1 锁定版本和仓库

依赖：无

任务：

- 创建 Godot 项目
- 锁定具体 Godot 稳定版本
- 创建 Git 仓库
- 创建 `.gitignore`
- 创建 Git LFS 规则
- 后端锁定 Node.js LTS

验收：

- README 写明版本
- 项目可启动
- `.env` 不会提交
- GLB、WAV 等大文件进入 LFS

### T0.2 创建目录与 Autoload

依赖：T0.1

任务：

- 建立 PRD 中目录
- 创建 `GameState`
- 创建 `EventBus`
- 创建 `SaveData`
- 创建 `Config`

验收：

- Godot 启动无报错
- Autoload 可访问
- 空主场景可运行

## Epic 1：三分钟垂直切片

### T1.1 主办公室与三个调查区

依赖：T0.2

任务：

- 占位办公室
- 电话、电脑、抽屉三个可点击区域
- 点击后显示区域名称

验收：

- 三个区域均可点击
- 快速连续点击不会重复触发
- 窄屏不遮挡关键 UI

### T1.2 时间和行动系统

依赖：T1.1

任务：

- 每轮 4 次行动
- 时间从 02:47 推进至 03:00
- 行动完成后更新 UI
- 进入超时阶段

验收：

- 第四次行动后稳定进入超时
- 行动数不小于 0
- 动画中不可重复消耗

### T1.3 第一轮正常读档

依赖：T1.2

任务：

- 创建世界快照
- 正常恢复
- 显示“已保存”

验收：

- 世界状态恢复
- 玩家知识保留
- 人格状态不丢失

### T1.4 第二轮“已记录”

依赖：T1.3

任务：

- 记录删除行为
- 第二轮显示幽灵波形
- 存档改为“已记录”

验收：

- 因果稳定
- 不依赖网络
- 重启项目后状态按设计恢复

### T1.5 99% 倒退与幽灵存档

依赖：T1.4

任务：

- 强制覆盖入口
- 进度条动画
- 幽灵存档
- 固定短台词

验收：

- 触发率 100%
- 不可被快速点击跳过
- 动画结束后游戏仍可继续

## Epic 2：完整内容

### T2.1 数据驱动行动系统

依赖：Epic 1

任务：

- `actions.json`
- 前置条件
- effects
- tags
- 行动加载器

验收：

- 新增行动无需改 UI 逻辑
- 非法 action ID 有安全错误

### T2.2 第一轮完整内容

任务：

- 合照
- 录音
- 电脑
- 删除 / 保留选择
- 第一轮失败结果

验收：

- 1 分钟内出现危机
- 3 分钟内出现取舍
- 玩家能主动产生读档需求

### T2.3 第二轮幽灵内容

任务：

- 幽灵录音
- 残缺证据头
- 第二次删除因果
- 谈判入口

验收：

- 至少一种残留数据必然出现
- 玩家能解释原因

### T2.4 第三轮谈判

任务：

- 坦白
- 交换
- 隐瞒
- 强制覆盖
- 承诺记录

验收：

- 四种选项均可执行
- 每种选项改动明确
- 不存在死路

### T2.5 最终证据和结局

任务：

- 声纹 + 芯片 + 证据包
- 最终揭示
- 两个结局
- 三种关系微变体

验收：

- 两个结局稳定可达
- 结局不依赖 AI
- 正式文本符合预算

## Epic 3：AI

### T3.1 后端骨架

任务：

- Fastify
- Zod
- `/health`
- `/v1/save-decision`
- `.env.example`

验收：

- 测试通过
- 无 Token 泄漏
- 非法请求返回 400

### T3.2 RouterBase 适配器

任务：

- 模型请求
- JSON 模式
- 超时
- 一次重试

验收：

- 能返回合法结构
- 5 秒后 fallback
- 日志不输出 Token

### T3.3 Godot AIClient

任务：

- HTTPRequest
- 请求组装
- 返回校验
- fallback

验收：

- 断网可通关
- 未知 mutation 被拒绝
- UI 不因超时冻结

## Epic 4：美术与音频

### T4.1 SAVE_03 核心

任务：

- Tripo3D 生成
- 导出 GLB
- Godot 导入
- 5 个状态

验收：

- 状态可由代码控制
- 发光和裂纹不依赖重新加载模型

### T4.2 办公室和 UI

任务：

- 正式背景
- 存档槽
- 文档面板
- 图标

验收：

- 1920×1080 清晰
- 1366×768 可读
- 关键按钮视觉明确

### T4.3 音频

任务：

- 阿栀录音
- 环境音
- 故障音
- 99% 倒退

验收：

- 无削波
- 台词清楚
- 音频可关闭或调低

## Epic 5：测试与发布

### T5.1 自动与手工测试

验收：

- P0 测试全部通过
- 10 次完整回归无阻断错误

### T5.2 Windows 构建

验收：

- 离线可玩
- 无控制台报错
- fallback 正常

### T5.3 Web 构建

验收：

- 目标浏览器可运行
- HTTPS 后端可访问
- 刷新恢复策略明确

### T5.4 现场演示

任务：

- Demo Mode
- 4 分钟脚本
- 30–60 秒备份视频

验收：

- 无网络仍可完成演示
- 可一键跳转到目标轮次


---

<!-- SOURCE: docs/09_TEST_PLAN.md -->

# 测试计划

## 1. 测试层级

- 单元测试：规则、校验、保存格式
- 集成测试：循环、AI fallback、结局
- 手工体验测试：节奏、理解、情绪
- 构建测试：Windows、Web

## 2. P0 功能用例

### TC-001 第一轮删除录音

步骤：

1. 播放录音
2. 找到证据包
3. 删除录音
4. 时间结束
5. 读档

预期：

- 证据已解压
- 声纹丢失
- 下一轮出现幽灵波形
- 存档显示“已记录”

### TC-002 连续两次删除录音

预期：

- obsession 达到规则阈值
- 生成完整幽灵录音
- SAVE_03 指出重复删除
- 第三轮可使用幽灵声纹

### TC-003 守约

步骤：

1. 坦白
2. 承诺保留录音
3. 下一轮不删除录音

预期：

- trust 增加
- broken_promises 保持 0
- SAVE_03 主动提供帮助

### TC-004 违约

步骤：

1. 承诺保留录音
2. 再次删除

预期：

- trust 降低
- broken_promises +1
- 允许 `DISTORT`
- 非核心日志发生变化

### TC-005 隐瞒

预期：

- conflict 增加
- 操作记录被尝试删除
- 后续 SAVE_03 能指出异常
- 主线证据不受影响

### TC-006 强制覆盖

预期：

- 99% 停顿
- 倒退
- 幽灵存档
- “她曾经来过”
- 游戏继续

### TC-007 公开真相结局

预期：

- 证据导出
- SAVE_03 被清空
- 最终存档为空

### TC-008 保留记忆结局

预期：

- 完整导出取消
- SAVE_03 保留
- 存档改名“我们都记得”

## 3. AI 异常

### TC-AI-001 超时

- 模拟 5 秒无响应
- 预期：进入 fallback，不阻断 UI

### TC-AI-002 非法 JSON

- 预期：校验失败，进入 fallback

### TC-AI-003 未知 decision

- 预期：拒绝，进入 fallback

### TC-AI-004 未知 mutation

- 预期：拒绝未知 mutation，其余结果不得直接执行

### TC-AI-005 超长文本

- 预期：后端拒绝或截断后重新校验

## 4. 保存异常

### TC-SAVE-001 文件损坏

预期：

- 原文件备份为 `.corrupt`
- 恢复快照或新游戏
- 不崩溃

### TC-SAVE-002 旧 schema

预期：

- 执行迁移
- 迁移失败时安全恢复

### TC-SAVE-003 快速重复读档

预期：

- 只处理一次
- 不重复增加人格值

## 5. 体验测试问题

试玩后询问：

1. 阿栀是谁？
2. 为什么 03:00 前必须行动？
3. 第一轮必须牺牲什么？
4. SAVE_03 为什么保留录音？
5. 你觉得它信任你吗？
6. 你是否愿意再读一次档？
7. 最终选择时你犹豫了吗？
8. 你会怎么向别人描述这款游戏？

## 6. 体验验收

- 60 秒内理解危机：通过率 ≥ 80%
- 第二轮后理解因果：通过率 ≥ 70%
- 主动想再读档：≥ 70%
- 最终选择犹豫：≥ 50%
- 能复述个人故事：≥ 60%

## 7. 构建测试

### Windows

- 断网
- 无音频设备
- 1366×768
- 1920×1080
- 重启恢复

### Web

- Chrome
- Edge
- 刷新
- 浏览器存储不可用
- 后端 CORS
- HTTPS

## 8. 回归要求

发布前：

- 连续完整通关 10 次
- 三种关系路径各 2 次
- 两个结局各 2 次
- 断网路径 2 次
- 现场设备完整演示 3 次


---

<!-- SOURCE: docs/10_DEMO_AND_PITCH.md -->

# 演示、报名与传播文案

## 1. 一句话介绍

> 《残留项》是一款你和存档系统互相驯化的时间循环游戏。你可以后悔，但它不一定愿意遗忘。

## 2. 30 秒介绍

凌晨 2:47，玩家进入即将被清空的办公室，寻找失踪同事留下的证据。

玩家必须不断读档，但存档系统会记住每一次删除、承诺和欺骗。它会形成自己的偏好，保护某些数据，修改规则，甚至拒绝被覆盖。

最终，玩家必须决定是否删除这个由失踪者数据形成的系统。

## 3. 四分钟演示脚本

### 0:00–0:30

> 这是一款玩家和存档互相驯化的游戏。存档会记住你删除过什么。

### 0:30–1:30

- 播放阿栀录音
- 展示证据包与空间冲突
- 删除录音
- 第一次正常读档

### 1:30–2:30

- 展示残留波形
- “已保存”变“已记录”
- SAVE_03 指出玩家重复删除

### 2:30–3:30

- 进入谈判
- 选择强制覆盖
- 进度条到达 99% 后倒退
- 幽灵存档“她曾经来过”出现

### 3:30–4:00

> 当存档已经记得你删除过谁，你还会再按一次覆盖吗？

## 4. 活动报名简介

《残留项》是一款围绕“存档系统拥有自己的想法”设计的 AI 原生时间循环游戏。

玩家在多轮调查中不断删除、恢复和覆盖数据，但 SAVE_03 会记住这些行为，并形成信任、执念与对抗。

AI 不负责生成整段剧情，而是在确定性规则内，根据玩家历史决定存档如何回应和干预。

玩家最终需要在公开完整证据与保留 SAVE_03 之间作出选择。

## 5. 海报文案

```text
清除完成
发现残留项：1
```

主标题：

> 残留项

副文案：

> 你可以后悔，  
> 但它不一定愿意遗忘。

## 6. 可传播句子

- 它不是拒绝读档，它是不愿意忘记。
- 你删除的是数据，它记住的是行为。
- 世界恢复了，责任没有。
- 清除结束后，它仍然存在。


---

<!-- SOURCE: docs/11_BRAND_GUIDE.md -->

# 品牌与命名规范

## 1. 正式名称

- 中文：**《残留项》**
- 英文：**RESIDUAL**
- 系统代号：`SAVE_03`

## 2. 标准品牌结构

```text
《残留项》
RESIDUAL

SYSTEM: SAVE_03

你可以后悔，
但它不一定愿意遗忘。
```

## 3. 核心系统提示

```text
清除完成
发现残留项：1
```

英文：

```text
DATA PURGE COMPLETE
RESIDUAL ITEMS: 1
```

## 4. 游戏内专有名称

| 名称 | 用途 |
|---|---|
| SAVE_03 | 存档系统 |
| 已保存 | 第一轮存档状态 |
| 已记录 | 第二轮存档状态 |
| 她曾经来过 | 幽灵存档 |
| 我们都记得 | 保留记忆结局 |
| 残留项 | 跨时间线保留对象与作品名 |

## 5. 名称气质

应体现：系统语言、克制、悬疑、低饱和科技感，以及通关后含义变重。

不应体现：卖萌、纯恐怖、宏大宣言、科技发布会口吻或网络短剧感。

## 6. Logo 方向

- 中文“残留项”为主
- 英文 RESIDUAL 为辅
- 可使用扫描框、残缺字符或“唯一保留对象”作为符号
- 不使用机器人头像、大脑、芯片或 AI 星光等常见图标
- 故障效果必须轻微，不影响识别

## 7. 仓库与文件命名

推荐仓库：

```text
residual-game
```

项目目录：

```text
residual
```

Godot 应用名：

```text
残留项
```

内部系统命名继续使用：

```text
save03
```


---

<!-- SOURCE: docs/12_AGENT_PROMPTS.md -->

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


---

<!-- SOURCE: AGENTS.md -->

# AGENTS.md

## 第一原则

本项目不是普通视觉小说，也不是聊天机器人套壳。

核心是：

> 玩家通过删除、承诺、欺骗和强制覆盖，和一个会记住自己的存档系统博弈。

## 开始前必须阅读

1. `README.md`
2. `docs/00_START_HERE.md`
3. `docs/02_PRD.md`
4. `docs/03_GDD.md`
5. 当前任务涉及的专项文档
6. `docs/STATUS.md`

## 命名规则

正式名称为《残留项》，英文名为 RESIDUAL，系统代号为 SAVE_03。旧工作名不得继续用于新代码注释、文档标题或对外材料。

## 强制约束

1. Godot 4.x + GDScript。
2. 具体 Godot 版本必须在项目初始化时锁定。
3. 核心规则本地确定性运行。
4. AI 只能选择 `ALLOW / PRESERVE / DISTORT / REFUSE`。
5. AI 不得控制主线、核心证据、结局和固定高光。
6. RouterBase Token 不得进入客户端、仓库、日志或截图。
7. 断网时必须可完整通关。
8. 不得私自增加地图、角色、结局、战斗或开放式聊天。
9. 不得在游戏运行时生成正式图片、音频或 3D。
10. 先完成玩法，再替换美术。

## 编码规范

- 使用显式类型
- 核心状态通过 Manager 修改
- UI 不直接写人格状态
- 剧情和行动优先使用 JSON
- 网络结果必须校验
- 快速点击必须加锁
- 每个关键状态变化发信号
- 不将所有逻辑堆进一个脚本
- 新逻辑必须包含测试或手工验证步骤

## 单任务流程

开始前输出：

- 任务理解
- 修改文件
- 实施步骤
- 风险和假设

完成后输出：

- 修改文件列表
- 已实现内容
- 测试结果
- 未完成内容
- 已知风险
- `docs/STATUS.md` 更新内容

## 执行顺序

严格按照 `docs/08_BACKLOG.md`。

不得跳过 Milestone 1 直接接 AI 或正式美术。

## 禁止行为

- 自由发挥新剧情
- 改写最终真相
- 创造第三个大型结局
- 把模型 API Key 放进 Godot
- 删除 fallback
- 用随机数代替可解释因果
- 让 SAVE_03 输出长篇独白
- 以“理论上可以”为测试结论


---

<!-- SOURCE: docs/STATUS.md -->

# 项目状态

## 正式名称

- 中文：《残留项》
- 英文：RESIDUAL
- 系统代号：SAVE_03

## 当前阶段

`DOCUMENTATION_COMPLETE`

## 已完成

- [x] 核心创意
- [x] MVP 范围
- [x] 故事真相
- [x] 三轮循环
- [x] 行动矩阵
- [x] 人格系统
- [x] AI 契约
- [x] 技术架构
- [x] 素材规范
- [x] Backlog
- [x] 测试计划

## 下一步

- [ ] T0.1 锁定版本和仓库
- [ ] T0.2 创建目录与 Autoload
- [ ] T1.1 主办公室与三个调查区

## 当前风险

- RouterBase 具体模型与 JSON 输出能力尚未在真实 Token 下验证
- Tripo3D 的最终模型风格尚未锁定
- 阿栀正式配音来源尚未确定
- Godot 具体稳定版本需要在项目初始化时锁定

## 范围冻结

未经确认，不增加：

- 地图
- 角色
- 结局
- 开放式聊天
- 实时生成素材
- 战斗
