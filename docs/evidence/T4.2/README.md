# T4.2 办公室和 UI 验收

## 范围

- 正式 2.5D 办公室背景
- 现有动态存档槽
- 行动驱动的信件、清除通知、芯片、存储设备和波形面板
- 1920×1080 与 1366×768 可读性

## 自动验证

```powershell
& 'D:\Env\Godot\Godot_v4.7.1-stable_win64_console.exe' `
  --headless `
  --path 'D:\Env\gameDev\Residual' `
  --script 'res://tests/t4_2_smoke.gd'
```

结果：

```text
T4.2 smoke: formal office, document viewer, icons, and waveform ready
```

全套 13 个 `*_smoke.gd` 测试均通过。

## 视觉验证

固定分辨率证据由 `tests/t4_2_capture.gd` 使用 Godot `SubViewport`
从实际 `scenes/main.tscn` 渲染，避免操作系统 DPI 和开发窗口覆盖改变像素尺寸。

- `formal-office-1920x1080.png`
- `document-panel-1920x1080.png`
- `formal-office-1366x768.png`
- `document-panel-1366x768.png`
- `document-panel-gui.jpg`：Computer Use 操作真实 Godot 窗口的补充证据

验收结果：

- 两种分辨率下三块调查区域、状态栏、反馈区和存档槽均完整。
- 文档正文与关闭按钮无裁切。
- 关键按钮具有边框、悬停和按下状态。

## 已知限制

当前背景已绘制 SAVE_03 设备，用于在 Tripo 模型仍处于生成中时保持完整画面。
正式 GLB 接入前需先遮罩或轻修背景中的设备，避免 2D 与 3D 重叠。
