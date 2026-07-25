# T5.2 Windows 构建验收

## 构建命令

```powershell
.\tools\build_windows_pair.ps1
```

## 最终候选包

- 文件：`build/RESIDUAL-Windows-post-jam.zip`
- 大小：`93,685,173 bytes`
- SHA-256：`C5B92395FF7916E2CDCDF3658FE06A83645F210397A100DDE7A5A1533185394B`
- Godot：`4.7.1.stable.official`

ZIP 只包含：

```text
RESIDUAL.exe  178,997,256 bytes
RESIDUAL.pck    9,984,800 bytes
README.txt            258 bytes
```

## 自动验收

构建脚本使用同版本 Godot console binary 通过 `--main-pack` 加载刚导出的
`RESIDUAL.pck`，无后端、无 RouterBase Token 运行 5 帧。

- `runtime-validation.log`：11,197 bytes
- 已加载 `main.tscn`
- 进程退出码：0
- `SCRIPT ERROR`：0
- `ERROR:`：0
- `Leaked instance`：0
- `Resource still in use`：0

产品修复后重新执行完整回归：

```text
T5.1 regression: PASS 10 cycles, 15 tests/cycle,
150 total runs, zero leaks, 102.4s
```

## Computer Use 实机验收

最终 PCK 在 `RESIDUAL.exe` 配对包中完成以下离线路径：

```text
02:47
→ 检查照片
→ 播放录音并显示波形
→ 扫描电脑
→ 02:56 删除 / 保留选择
→ 删除录音
→ 03:00 DATA PURGE NOTICE
```

同时确认：

- 正式办公室背景可见
- AUDIO 音量与静音控件可见
- 三个调查区域可交互
- 存储设备、波形和清除通知面板可显示
- 最终 SHA-256 对应目录再次启动并成功渲染首屏

## 本轮发现并修复的问题

如果玩家到第 4 次行动结束才触发删除/保留弹窗，删除操作会因没有剩余行动
被拒绝。旧逻辑没有重新启用选择按钮，导致保留路径也被锁死。

修复后，删除被拒绝时会显示说明并重新启用两个按钮；新增
`tests/t5_2_smoke.gd` 覆盖“03:00 删除失败后仍可选择保留”的离线恢复路径。

## 已知限制

本机没有 Godot 4.7.1 官方 Windows export templates。本包继续使用同版本
Godot GUI binary 与独立 PCK 配对，因此可离线运行，但体积大于标准 release
template 导出。该限制不影响当前玩法和 fallback 验收。
