# T5.1 自动回归验收

## 验收命令

```powershell
.\tools\run_regression.ps1 -Cycles 10
```

## 结果

- Godot：`4.7.1.stable.official`
- 连续回归：10 轮
- 每轮测试：14 项 `*_smoke.gd`
- 总运行数：140
- 结果：140/140 通过
- 资源泄漏：0
- 最终完整运行耗时：97.5 秒

最终输出：

```text
T5.1 regression: PASS 10 cycles, 14 tests/cycle, 140 total runs, zero leaks, 97.5s
```

## 回归门规则

`tools/run_regression.ps1` 遇到以下任一情况立即失败：

- Godot 进程返回非零退出码
- `SCRIPT ERROR`
- `ERROR:`
- `Leaked instance`
- `Resource still in use`
- 测试未输出明确的 `smoke:` 结果

## 本轮发现并修复的问题

主场景测试关闭时，Godot 音频混音线程偶发仍持有环境音播放对象，造成
`AudioStreamPlaybackWAV` 泄漏。三个会实例化主场景的测试现统一执行：

1. 停止并解绑音频流
2. 等待音频线程完成刷新
3. 释放场景
4. 再等待一次回收

修复后重新从第 1 轮计数，并完成连续 10 轮验收。
