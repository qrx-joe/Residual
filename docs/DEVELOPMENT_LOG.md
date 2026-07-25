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
