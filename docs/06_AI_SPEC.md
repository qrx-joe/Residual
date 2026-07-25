
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
