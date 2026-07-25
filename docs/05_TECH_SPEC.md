
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
