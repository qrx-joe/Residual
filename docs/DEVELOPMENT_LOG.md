# 开发记录

## 2026-07-25 09:31 - T0.1

### Question

如何建立可复现、可启动且不会误提交密钥或大文件的《残留项》项目仓库？

### To do

- 创建 Godot 项目并锁定本机稳定版本
- 锁定 Node.js 与 npm 版本
- 初始化本地 Git 和 Git LFS
- 配置忽略规则与大文件跟踪规则
- 完成命令行和 Godot 编辑器启动验收

### Next to do

- T0.2：创建项目目录、四个 Autoload 与空主场景

### Changes

- 创建 `project.godot`，使用 Compatibility 渲染
- 创建 `.nvmrc` 与 `package.json`，锁定 Node.js 和 npm
- 创建 `.gitignore` 与 `.gitattributes`
- 初始化本地 Git `main` 分支和本地 Git LFS hooks
- 在 `README.md` 记录开发环境版本

### Verification

- `Godot_v4.7.1-stable_win64_console.exe --version`：`4.7.1.stable.official.a13da4feb`
- `Godot_v4.7.1-stable_win64_console.exe --headless --editor --path D:\Env\gameDev\Residual --quit`：退出码 `0`，正常环境下无错误
- `git check-attr`：GLB 与 WAV 的 `filter`、`diff`、`merge` 均为 `lfs`
- `git check-ignore`：`.env`、`backend/.env`、`build/`、`.godot/` 均被忽略
- Godot GUI：成功打开 `RESIDUAL - Godot Engine`，状态栏显示 `4.7.1.stable`
- 截图：`docs/evidence/T0.1/godot-editor.jpg`

### Advice

- 当前仅创建本地仓库，未创建远程仓库或推送
- Godot 首次受限运行出现 AppData 写入错误；在正常权限环境复验后错误消失，判定为执行沙箱限制而非项目错误
- RouterBase、Tripo 与正式美术仍不得早于 T1.5

## 2026-07-25 09:40 - T0.2

### Question

如何建立可运行的 Godot 项目骨架，并证明四个核心 Autoload 已被实际加载？

### To do

- 建立场景、脚本、数据、资产与测试目录
- 创建 `GameState`、`EventBus`、`SaveData`、`Config`
- 注册四个 Autoload
- 创建并配置空主场景
- 完成命令行 smoke 与 GUI 运行验收

### Next to do

- T1.1：创建占位办公室与电话、电脑、抽屉三个调查区

### Changes

- 创建四个显式类型 Autoload 脚本
- 创建 `scenes/main.tscn` 与 `scripts/main.gd`
- 在 `project.godot` 注册 Autoload 和主场景
- 建立 `assets`、`data`、`tests`、`scripts/managers`、`scripts/ai`、`scripts/ui`

### Verification

- `Godot_v4.7.1-stable_win64_console.exe --headless --path D:\Env\gameDev\Residual --quit-after 2`：退出码 `0`
- smoke 输出：`T0.2 smoke: GameState, EventBus, SaveData, Config ready`
- Godot GUI：场景树显示 `Main / Background / CenterContainer / StatusLabel`
- 游戏窗口：显示 `RESIDUAL / SAVE_03 / SYSTEM READY`
- 截图：`docs/evidence/T0.2/system-ready.jpg`

### Advice

- 首次 smoke 捕获到编辑器旧进程把 `config/features` 写入 `[autoload]` 的错误；关闭旧进程、修正配置并复验后无报错
- Computer Use 在停止调试窗口时发生窗口句柄错配，已立即停止 UI 输入并改用精确进程清理；运行和截图验收不受影响
- 当前 `SaveData` 只声明路径，持久化必须留到 T1.3

## 2026-07-25 10:05 - T1.1

### Question

如何用占位界面建立可点击、可辨认且不会因快速连续输入重复触发的三个调查区？

### To do

- 创建占位办公室界面
- 创建电话、电脑、抽屉三个调查区
- 点击后显示区域名称和简短说明
- 增加快速点击锁
- 验证 `1366×768` 下关键 UI 可见

### Next to do

- T1.2：实现每轮四次行动、02:47 至 03:00 的时间推进和超时阶段

### Changes

- 创建 `scripts/ui/investigation_area.gd`
- 重建 `scenes/main.tscn` 为响应式占位办公室
- 更新 `scripts/main.gd`，集中处理区域选择反馈
- 创建 `tests/t1_1_smoke.gd`

### Verification

- 自动测试：三个调查区均存在并位于 `1366×768` 实际可见矩形内
- 自动测试：同一调查区同帧连续触发两次只计一次
- Godot GUI：逐一点击电话、电脑和抽屉，底部反馈均正确更新
- 截图：
  - `docs/evidence/T1.1/phone-area.jpg`
  - `docs/evidence/T1.1/computer-area.jpg`
  - `docs/evidence/T1.1/drawer-area.jpg`

### Advice

- 占位办公室只用于玩法验证，不代表正式美术
- 当前点击不消耗行动次数，也不修改核心状态；这些必须由 T1.2 的 Manager 统一处理
- RouterBase 与 Tripo3D 仍不进入当前本地垂直切片

## 2026-07-25 10:24 - T1.2

### Question

如何确保每轮严格只有四次行动，并在动画和快速输入下仍确定性地推进到 03:00？

### To do

- 创建 `LoopManager`
- 实现四次行动与固定时间表
- 在行动解析期间建立全局输入锁
- 第四次行动后进入 `LOOP_TIMEOUT`
- 在 UI 中显示时间、剩余行动和清除状态

### Next to do

- T1.3：创建世界快照、正常恢复并显示“已保存”

### Changes

- 创建 `scripts/managers/loop_manager.gd`
- 创建 `tests/t1_2_smoke.gd`
- 更新 `scripts/main.gd`，由 Manager 接受或拒绝调查请求
- 更新 `scenes/main.tscn`，增加时间、行动数和清除状态

### Verification

- 核心 smoke：固定推进 `02:47 → 02:50 → 02:53 → 02:56 → 03:00`
- 核心 smoke：解析中的第二次请求被拒绝
- 核心 smoke：第四次行动后进入 `LOOP_TIMEOUT`
- 核心 smoke：第五次请求被拒绝，剩余行动保持 `0`
- T1.1 回归：三个区域仍可见，快速点击锁仍通过
- Godot GUI：实际执行四次调查后显示 `03:00 / ACTIONS 0 / 4 / DATA PURGE STARTED`
- Godot GUI：超时后再次点击不改变状态
- 截图：
  - `docs/evidence/T1.2/02-47-start.jpg`
  - `docs/evidence/T1.2/03-00-timeout.jpg`

### Advice

- `LoopManager` 通过 `/root/GameState` 与 `/root/EventBus` 获取 Autoload，避免依赖编辑器全局类缓存
- 动画锁属于全局 Manager，不能只依赖单个按钮锁
- 当前超时只进入状态并阻止继续调查；读档流程留到 T1.3

## 2026-07-25 12:15 - T1.3

### Question

如何让第一次读档恢复世界，同时保留玩家已经知道的事和 SAVE_03 的人格状态？

### To do

- 创建 02:47 世界快照
- 仅恢复 `world_state`
- 保留 `player_knowledge`、`persona_state` 和 `residual_state`
- 显示 `SAVE_01 / 02:47 / 已保存`
- 超时后提供读档入口

### Next to do

- T1.4：记录删除行为、显示幽灵波形，并把存档状态改为“已记录”

### Changes

- 扩展 `scripts/autoload/save_data.gd`，增加深拷贝世界快照
- 更新 `scripts/main.gd`，接入读档请求和世界恢复
- 更新 `scenes/main.tscn`，增加 SAVE_01 存档槽
- 创建 `tests/t1_3_smoke.gd`

### Verification

- T1.3 smoke：世界状态恢复至 02:47 快照
- T1.3 smoke：玩家知识、人格和残留状态未被回滚
- T1.1/T1.2 回归均通过
- Godot GUI：03:00 后 `读取 SAVE_01` 可用
- Godot GUI：读档后恢复 `02:47 / ACTIONS 4 / 4`
- Godot GUI：读档后再次调查可推进到 02:50
- 截图：
  - `docs/evidence/T1.3/03-00-load-ready.jpg`
  - `docs/evidence/T1.3/02-47-restored.jpg`
  - `docs/evidence/T1.3/02-50-continued.jpg`

### Advice

- T1.3 使用进程内快照；跨重启持久化是 T1.4 的验收内容
- 世界快照使用深拷贝，避免嵌套字典被后续修改污染
- 读档入口通过 `SaveData` 恢复，UI 不直接写核心状态

## 2026-07-25 12:31 - T1.4

### Question

如何确保第二轮幽灵录音只由第一轮的删除行为引起，并在退出游戏后仍能准确恢复？

### To do

- 记录录音删除行为及其因果来源
- 仅在删除发生后生成幽灵录音
- 把循环、残留、玩家知识和历史写入 JSON 存档
- 在第二轮显示幽灵波形与“已记录”
- 验证退出并重启后状态仍然存在

### Next to do

- T1.5：实现 99% 倒退、强制覆盖和不可删除的幽灵存档

### Changes

- 扩展 `scripts/autoload/game_state.gd`，增加持久化历史
- 扩展 `scripts/autoload/save_data.gd`，实现 JSON 存档与恢复
- 创建 `scripts/managers/residual_data_manager.gd`
- 更新 `scripts/main.gd`，接入删除行为、幽灵录音和第二轮展示
- 更新 `scenes/main.tscn`，增加删除入口与幽灵波形
- 创建 `tests/t1_4_smoke.gd`

### Verification

- T1.4 smoke：未删除录音时不会生成幽灵录音
- T1.4 smoke：删除后必定生成幽灵录音
- T1.4 smoke：模拟重启后恢复循环、残留、玩家知识和历史
- T1.1、T1.2、T1.3 回归均通过
- Godot GUI：完整执行第一轮删除、超时和读档后，第二轮显示幽灵波形与“已记录”
- Godot GUI：退出并用同一隔离存档重启后，幽灵波形与“已记录”仍然存在
- 截图：
  - `docs/evidence/T1.4/second-loop-recorded.jpg`
  - `docs/evidence/T1.4/restart-recorded.jpg`
- GUI 隔离测试存档已清理，默认正式存档未触碰

### Advice

- 实机点击暴露出删除按钮接近裁切边缘，已把它移入固定存档栏
- 当前删除是垂直切片中的非行动消耗操作；完整行动选择由 T2.2 接入
- T1.4 全程本地确定性运行，未接入 RouterBase 或 Tripo3D
- 损坏存档恢复尚未实现，后续存档稳健性任务需补充

## 2026-07-25 13:10 - T1.5

### Question

如何把强制覆盖做成不可跳过的固定高光，同时确保动画结束后游戏能够继续？

### To do

- 增加强制覆盖入口
- 固定触发 99% 停顿和回退至 43%
- 在演出期间建立全局输入锁
- 创建不可删除的幽灵存档“她曾经来过”
- 显示 SAVE_03 的两句固定短台词
- 动画结束后恢复调查

### Next to do

- T2.1：把行动定义和结果迁移到 JSON，由本地 Manager 统一执行

### Changes

- 创建 `scripts/managers/anomaly_controller.gd`
- 更新 `scripts/main.gd`，接入覆盖流程、输入锁和继续调查
- 更新 `scenes/main.tscn`，增加覆盖层、进度条、幽灵存档槽与固定台词
- 创建 `tests/t1_5_smoke.gd`
- 创建 `docs/evidence/T1.5/` 验收截图

### Verification

- T1.5 smoke：快速二次请求被拒绝，覆盖流程只启动一次
- T1.5 smoke：阶段严格按读取、99% 停顿、倒退、核心裂纹、幽灵存档、完成执行
- T1.5 smoke：进度精确到 99% 后回退至 43%
- T1.5 smoke：幽灵存档不可删除，`conflict +2`，历史只记录一次
- T1.1、T1.2、T1.3、T1.4 回归均通过
- Godot GUI：隔离存档完整执行第一轮删除、第二轮强制覆盖
- Godot GUI：显示 `99% · SIGNAL HELD`
- Godot GUI：终态显示 43%、“她曾经来过”和两句固定台词
- Godot GUI：点击“继续调查”后再次行动，时间从 02:47 推进到 02:50
- 截图：
  - `docs/evidence/T1.5/99-percent-paused.jpg`
  - `docs/evidence/T1.5/ghost-save-created.jpg`
  - `docs/evidence/T1.5/continued-after-overwrite.jpg`
- GUI 隔离测试存档已清理，默认正式存档未触碰

### Advice

- 固定高光完全由本地 `AnomalyController` 决定，未交给 AI
- `RESIDUAL_ANOMALY_TIMING_SCALE` 仅用于延长验收采样窗口；默认正式时序不变
- 当前核心裂纹以文字异常占位，正式 Shader 和故障音分别留给 T4.2 与 T4.3
- RouterBase 和 Tripo3D 未接入 Milestone 1

## 2026-07-25 13:32 - T2.1

### Question

如何让行动内容由 JSON 驱动，使新增行动不再要求修改主 UI 逻辑，同时安全拒绝非法 action ID？

### To do

- 创建 `actions.json`
- 定义前置条件、effects 和 tags
- 创建行动加载、校验和执行 Manager
- 让主 UI 从行动数据读取名称和说明
- 为非法 action ID 提供不修改状态的结构化错误

### Next to do

- T2.2：用数据驱动行动实现第一轮完整内容与删除/保留取舍

### Changes

- 创建 `data/actions.json`
- 创建 `scripts/managers/action_manager.gd`
- 更新 `scripts/main.gd`，移除行动展示的硬编码依赖
- 更新 `scripts/managers/loop_manager.gd`，增加安全取消入口
- 更新 `scenes/main.tscn`，挂载 `ActionManager`
- 创建 `tests/t2_1_smoke.gd`

### Verification

- T2.1 smoke：加载三个 JSON 行动及其 effects、tags
- T2.1 smoke：有效行动通过 Manager 修改 `world_state`
- T2.1 smoke：非法 action ID 返回 `UNKNOWN_ACTION_ID`，不修改状态
- T2.1 smoke：运行时仅向 JSON 增加第四个行动即可加载，无需修改 UI 逻辑
- T1.1–T1.5 全回归和主场景加载通过
- Godot GUI：电话行动从 JSON 读取名称与说明，执行后推进到 02:50
- 截图：`docs/evidence/T2.1/json-action-executed.jpg`

### Advice

- T2.1 只迁移现有占位行动，没有提前增加 T2.2 剧情内容
- 当前 effects 只允许对四类本地状态执行 `SET`，未知 operation 或 target 会安全失败
- RouterBase 与 Tripo3D 仍未进入完整内容阶段

## 2026-07-25 14:18 - T2.2

### Question

如何让第一轮在三次推荐行动内建立危机和不可兼得的取舍，并让失败自然产生主动读档需求？

### To do

- 实现合照、阿栀录音、电脑空间冲突
- 让区域点击按 JSON 顺序选择下一项可用行动
- 实现删除语音 / 保留语音互斥选择
- 删除后得到证据但失去声纹
- 保留后留下声纹但证据不解压
- 第一轮失败后明确提供读档入口

### Next to do

- T2.3：实现第二轮幽灵录音、残缺证据头、第二次删除因果和谈判入口

### Changes

- 扩展 `data/actions.json` 为七个正式行动
- 创建 `scripts/managers/first_loop_content_manager.gd`
- 扩展 `scripts/managers/action_manager.gd`，按区域和前置条件选择行动
- 扩展 `scripts/managers/loop_manager.gd`，支持选择后提前结束循环
- 更新 `scripts/main.gd`，接入第一轮内容、互斥选择和失败结果
- 更新 `scenes/main.tscn`，增加开局危机和删除/保留覆盖层
- 创建 `tests/t2_2_smoke.gd`

### Verification

- T2.2 smoke：开局立即标记 03:00 清除危机
- T2.2 smoke：电话区域依次返回合照和录音
- T2.2 smoke：第三次推荐行动后出现删除/保留取舍
- T2.2 smoke：删除后证据已解压、声纹丢失，并记录跨循环删除因果
- T2.2 smoke：删除与保留无法同时执行
- T2.2 smoke：失败结果明确包含“读取 SAVE_01”
- T1.1–T2.1 全回归通过
- Godot GUI：完整执行合照、录音、电脑、删除、失败和读档路径
- 截图：
  - `docs/evidence/T2.2/crisis-at-start.jpg`
  - `docs/evidence/T2.2/delete-or-keep-choice.jpg`
  - `docs/evidence/T2.2/delete-failure-reload.jpg`

### Advice

- “1 分钟危机”通过开局立即显示实现；“3 分钟取舍”通过第三次推荐行动触发实现
- 实际理解率与主动读档比例仍需后续真人试玩统计，当前自动化只证明流程与提示成立
- 旧的即时删除按钮已退出正式第一轮路径，避免绕过互斥选择
- 本任务仍完全离线，未接入 RouterBase 或 Tripo3D

## 2026-07-25 14:52 - T2.3

### Question

如何让第一轮删除和保留都在第二轮留下可见、可解释的残留，并在第二次选择后稳定进入谈判？

### To do

- 删除路径生成幽灵录音
- 保留路径生成残缺证据头
- 第二次删除记录因果与人格变化
- 第二次保护记录信任变化
- 两条路径都开放谈判入口

### Next to do

- T2.4：实现坦白、交换、隐瞒、强制覆盖四种谈判选项和承诺记录

### Changes

- 扩展 `scripts/managers/residual_data_manager.gd`
- 创建 `scripts/managers/second_loop_content_manager.gd`
- 更新 `scripts/main.gd`，复用取舍界面并接入谈判入口
- 更新 `scenes/main.tscn`，增加残缺证据头和谈判入口覆盖层
- 创建 `tests/t2_3_smoke.gd`

### Verification

- T2.3 smoke：第一轮删除保证第二轮幽灵录音
- T2.3 smoke：第一轮保留保证第二轮残缺证据头
- T2.3 smoke：第二次删除计数为 2、`obsession +2`、生成完整幽灵录音
- T2.3 smoke：第二次保护 `trust +1`
- T2.3 smoke：删除与保留两条路径均可进入谈判
- T1.1–T2.2 全回归通过
- Godot GUI：删除路径显示幽灵波形、第二次删除固定台词和“进入谈判”
- Godot GUI：保留路径显示 `GHOST HEADER EVIDENCE_03.enc` 和“已记录”
- 截图：
  - `docs/evidence/T2.3/ghost-recording-loop2.jpg`
  - `docs/evidence/T2.3/second-delete-negotiation.jpg`
  - `docs/evidence/T2.3/ghost-evidence-header-loop2.jpg`

### Advice

- 第二轮固定因果仍完全由本地规则决定，不交给 AI
- T2.3 只实现谈判入口，四种谈判行为留给 T2.4
- 两个 GUI 隔离存档已删除，默认正式存档未触碰

## 2026-07-25 15:42 - T2.4

### Question

如何让坦白、交换、隐瞒和强制覆盖都产生明确、持久、无死路的规则变化？

### To do

- 实现四种本地谈判决策
- 坦白记录承诺与信任
- 交换记录残留项与执念
- 隐瞒修改人格并生成非核心日志变体
- 强制覆盖接入固定 99% 高光
- 四条路径均开放读档进入第三轮

### Next to do

- T2.5：组合声纹、芯片和证据包，实现最终揭示、两个结局和关系微变体

### Changes

- 创建 `scripts/managers/save_will_manager.gd`
- 更新 `scripts/managers/second_loop_content_manager.gd`，补充跨进程第二轮世界初始化
- 更新 `scripts/main.gd`，接入谈判四选项、结果和第三轮读档
- 更新 `scenes/main.tscn`，增加谈判四选项覆盖层
- 创建 `tests/t2_4_smoke.gd`
- 扩展 `tests/t2_3_smoke.gd`，验证第二轮重启初始化

### Verification

- T2.4 smoke：四种选项均可执行且第二次选择被拒绝
- T2.4 smoke：坦白 `trust +1` 并记录保留阿栀录音承诺
- T2.4 smoke：交换 `obsession +1` 并保留三个残留项
- T2.4 smoke：隐瞒 `trust -2 / conflict +1` 并生成“未发生的操作”
- T2.4 smoke：强制覆盖在幽灵存档生成前不可继续，生成后可继续
- T2.3 smoke：跨进程恢复第二轮时重新初始化录音等世界字段
- T1.1–T2.3 全回归通过
- Godot GUI：四选项同时可见
- Godot GUI：坦白后显示“承诺已记录”，可读档进入第三轮
- Godot GUI：正式强制覆盖完成后按钮变为“保存决定并读档”，可进入第三轮
- 截图：
  - `docs/evidence/T2.4/four-negotiation-options.jpg`
  - `docs/evidence/T2.4/confess-promise-recorded.jpg`
  - `docs/evidence/T2.4/force-overwrite-to-reload.jpg`

### Advice

- 四种谈判效果完全由本地 `SaveWillManager` 决定，RouterBase 不得改写
- 承诺保存在 `persona_state.promises`，谈判选择保存在 `player_knowledge`
- 实机验收暴露并修复了仅同进程读档无法发现的第二轮重启初始化缺口
- 两个 GUI 隔离种子存档已删除，默认正式存档未触碰

## 2026-07-25 16:20 - T2.5

### Question

如何让第三轮稳定组合声纹、物理芯片和证据包，并在完全不依赖 AI 的前提下到达两个结局和三种关系微变体？

### To do

- 实现第三轮快捷证据行动与三件套校验
- 实现固定最终揭示和阿栀留言
- 实现公开真相与保留记忆两个本地结局
- 实现合作型、交易型、对抗型关系微变体
- 验证正式文本预算与两条结局可达性

### Next to do

- T3.1：创建 Fastify + Zod 后端骨架、健康检查和本地决策接口

### Changes

- 扩展 `data/actions.json`，增加第三轮声纹、芯片、证据包和解密行动
- 扩展 `scripts/managers/action_manager.gd`，支持行动轮次范围
- 创建 `scripts/managers/third_loop_content_manager.gd`
- 创建 `scripts/managers/ending_manager.gd`
- 更新 `scripts/main.gd`，接入零成本行动、最终揭示和双结局
- 更新 `scenes/main.tscn`，增加最终揭示与结局覆盖层
- 创建 `tests/t2_5_smoke.gd`
- 更新 `tests/t2_1_smoke.gd`，同步十二个数据驱动行动

### Verification

- T2.5 smoke：声纹、芯片和证据包齐备后才能解密最终证据
- T2.5 smoke：固定揭示包含保留策略、授权、覆盖对象和 02:31 离开记录
- T2.5 smoke：合作型、交易型、对抗型关系均可稳定分类
- T2.5 smoke：公开真相清空 SAVE_03 人格与残留，存档槽为空
- T2.5 smoke：保留记忆仅保留证据摘要，SAVE_03 存续，存档名变为“我们都记得”
- T1.1–T2.5 共十个 smoke 全量回归通过
- Godot 主场景 headless 加载通过
- Godot GUI：完整点击幽灵声纹、物理芯片、证据包和解密
- Godot GUI：公开真相与保留记忆两个结局均实际到达
- 截图：
  - `docs/evidence/T2.5/final-reveal-cooperative.png`
  - `docs/evidence/T2.5/public-truth-ending.png`
  - `docs/evidence/T2.5/preserve-memory-ending.png`

### Advice

- 最终揭示、结局条件和代价全部由本地规则决定，RouterBase 无权修改
- 第三轮声纹同时支持完整幽灵录音和被保留的正式录音，两条前序路径均可继续
- 关系条件之外的中间状态回落为交易型，避免出现第四种关系或死路
- GUI 验收使用的隔离种子存档已删除，默认正式存档未触碰

## 2026-07-25 16:40 - T3.1

### Question

如何建立不泄漏 Token、无网络也能响应、并能拒绝非法 AI 请求的后端安全边界？

### To do

- 创建 Fastify + TypeScript + Zod 后端
- 实现 `GET /health`
- 实现 `POST /v1/save-decision`
- 用 Zod 校验请求白名单和文本预算
- 提供空凭据 `.env.example`
- 验证无 Token 启动和非法请求 400

### Next to do

- T3.2：实现 RouterBase 适配器、严格 JSON、5 秒超时、一次重试和 fallback

### Changes

- 创建 `backend/package.json` 与锁文件，锁定 Node 24 对应依赖
- 创建 `backend/tsconfig.json` 与生产构建配置
- 创建 `backend/src/contracts.ts`
- 创建 `backend/src/fallback.ts`
- 创建 `backend/src/app.ts`
- 创建 `backend/src/config.ts`
- 创建 `backend/src/server.ts`
- 创建 `backend/tests/app.test.ts`
- 创建 `backend/.env.example` 与 `backend/README.md`
- 更新 `.gitignore`，忽略构建产物

### Verification

- `npm run typecheck`：TypeScript 严格检查通过
- `npm run build`：生产代码构建通过
- `npm test`：1 个测试文件、4 个用例全部通过
- `/health` 真实 HTTP 返回 200，且无适配器时 `ai_available: false`
- `/v1/save-decision` 合法请求返回白名单内本地 fallback
- 缺失字段请求真实 HTTP 返回 400
- `netstat` 确认服务监听 `127.0.0.1:8787`
- 验收后服务进程已关闭，端口不再监听

### Advice

- T3.1 没有调用 RouterBase，避免把后端骨架伪装成 AI 已接入
- Fastify 请求体限制为 32 KiB，生产日志对认证头和 Cookie 做脱敏
- `.env.example` 只包含空的 `ROUTERBASE_API_KEY` 占位符，真实 `.env` 继续被忽略
- 本地 fallback 只从请求提供的决策和目标白名单中取值，核心流程仍可离线运行

## 2026-07-25 17:10 - T3.2

### Question

如何在不让 RouterBase 越权、不泄漏凭据、并保证 5 秒内回到本地 fallback 的前提下接入模型适配器？

### To do

- 核对 RouterBase 当前官方端点、认证和 JSON 模式
- 实现 OpenAI 兼容 Chat Completions 请求
- 实现总计 5 秒超时预算和最多一次重试
- 校验模型响应 Schema、本次决策白名单和文本预算
- 任何错误或越权结果进入本地 fallback
- 无 Token 时保持完整离线响应

### Next to do

- T3.3：实现 Godot AIClient、返回值二次校验和 UI 非阻断 fallback

### Changes

- 创建 `backend/src/routerbase_adapter.ts`
- 创建 `backend/src/response_validator.ts`
- 创建 `backend/src/decision_service.ts`
- 扩展 `backend/src/contracts.ts`，增加完整响应契约
- 扩展 `backend/src/app.ts`，支持可选决策服务
- 扩展 `backend/src/config.ts` 与 `.env.example`
- 更新 `backend/src/server.ts`，仅在存在 Token 时实例化适配器
- 创建 `backend/tests/routerbase_adapter.test.ts`
- 扩展 `backend/tests/app.test.ts`
- 更新 `backend/README.md`

### Verification

- RouterBase 官方文档确认端点为 `/v1/chat/completions`
- 官方文档确认 Bearer 认证与 `response_format: json_object`
- 官方错误分类确认 429、455 和 5xx 可重试
- `npm test`：2 个测试文件、13 个用例全部通过
- `npm run typecheck`：严格类型检查通过
- `npm run build`：生产构建通过
- 成功响应、455 后重试成功、401 不重试均通过 mock 验证
- 非法 JSON、越权 decision、越权 mutation、超长台词均进入 fallback
- 超时测试证明所有尝试共享单一总预算
- 无 Token 真实 HTTP 运行时 `ai_available: false` 且本地决策可用
- 验收后服务进程已关闭，端口不再监听

### Advice

- 默认模型采用官方示例中的 `google/gemini-2.5-flash`，但可通过环境变量替换
- 本节点没有真实 Token，因此只确认协议实现和 mock 行为；真实模型 JSON 稳定性仍待凭据实测
- 适配器从不把 API Key 写入响应、错误消息或业务日志
- 5 秒是整个调用的总预算，不是每次重试各 5 秒

## 2026-07-25 17:40 - T3.3

### Question

如何让 Godot 异步调用本地后端、再次拒绝越权 AI 输出，并保证断网和超时不阻断谈判或通关？

### To do

- 实现 Godot `HTTPRequest` 客户端
- 从本地状态组装最小请求上下文
- 在客户端二次校验 decision、target、mutation 和文本预算
- 所有失败异步进入本地 fallback
- 将 AI 结果限制为谈判短反应，不直接修改核心状态
- 验证 Godot 到 Fastify 的真实 HTTP 链路

### Next to do

- T4.1：使用 Tripo3D 制作并导入 SAVE_03 核心模型与五个可控视觉状态

### Changes

- 创建 `scripts/ai/ai_client.gd`
- 创建 `scripts/ai/ai_response_validator.gd`
- 更新 `scripts/autoload/config.gd`，支持安全的后端环境变量
- 更新 `scenes/main.tscn`，挂载 `AIClient`、`HTTPRequest` 和短反应 UI
- 更新 `scripts/main.gd`，按本地谈判结果计算每次 AI 白名单
- 创建 `tests/t3_3_smoke.gd`
- 创建 `tests/t3_3_http_integration.gd`
- 更新 `backend/README.md`

### Verification

- T3.3 smoke：合法结果通过客户端校验
- T3.3 smoke：未知 mutation 导致整份响应被拒绝
- T3.3 smoke：不在本次集合内的 decision 被拒绝
- T3.3 smoke：请求上下文不含 Token、Authorization 或 API Key
- T3.3 smoke：禁用 AI 时下一帧返回 fallback，不在调用栈同步阻塞
- T3.3 smoke：后端不可达时场景树持续运行并返回 fallback
- T1.1–T3.3 共十一个 smoke 全量回归通过
- 真实集成：Godot `HTTPRequest` → Fastify → 本地决策 → Godot 二次校验通过
- Godot GUI：第二轮谈判显示离线 `SAVE_03：录音留下。`
- Godot GUI：AI 反应出现后“保存决定并读档”仍可点击并进入 03:00
- 截图：`docs/evidence/T3.3/offline-ai-fallback-negotiation.png`
- GUI 隔离种子存档与本地服务进程均已清理

### Advice

- Godot 客户端只知道本地后端 URL，RouterBase Token 仍只属于后端环境
- AI 反应不写人格、证据、结局或固定高光；核心 mutation 仍由本地 Manager 决定
- `RESIDUAL_AI_ENABLED=1` 才启用后端调用，默认构建保持完全离线
- 真实 RouterBase 模型调用仍需要用户在本机后端提供 Token 后单独验收

## 2026-07-25 15:17 - 截止时间提交冻结

### Decision

- 16:00 前优先提交已经完成的核心逻辑闭环
- 正式 3D、全套美术、配音和真实 RouterBase 调用不得阻塞构建
- 不再增加新玩法、剧情分支或结局

### Changes

- 创建 T4.1 SAVE_03 五态控制器、道具场景和预览场景
- 创建 `tests/t4_1_smoke.gd`
- 创建 Windows 导出预设
- 生成 PCK 配对 Windows 候选包
- 创建 `docs/SUBMISSION_BUILD.md`

### Verification

- T1.1–T4.1 共 12 个 smoke 全量通过
- 五态切换前后模型实例 ID 不变
- Windows 候选包成功启动
- 打包后实机进入第一轮删除或保留录音关键选择
- ZIP SHA-256：`59BEB1BCFDEA49D21C298287DDCAE80D3D34CEE0709E92E6DBA434EA326903AF`

### Remaining

- Tripo3D GLB 正在生成，仅在不影响提交时接入
- 活动页面最终上传和提交由用户完成
