
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
