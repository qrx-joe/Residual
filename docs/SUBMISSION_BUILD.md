# 截止时间提交构建

## 当前候选包

- 文件：`build/RESIDUAL-Windows.zip`
- 生成时间：2026-07-25 15:16（Asia/Shanghai）
- 大小：84,413,100 bytes
- SHA-256：`59BEB1BCFDEA49D21C298287DDCAE80D3D34CEE0709E92E6DBA434EA326903AF`

解压后双击 `RESIDUAL.exe`。`RESIDUAL.exe` 与 `RESIDUAL.pck` 必须位于同一目录。

## 本次提交范围

核心闭环已经冻结：

1. 三个调查区域和四次行动预算
2. 03:00 数据清除
3. 删除或保留录音
4. 读档后知识、人格与残留不回滚
5. 第二轮幽灵内容
6. 第三轮四种谈判
7. 固定最终证据链
8. 三种关系表现
9. 两个本地确定性结局

RouterBase 反应默认关闭，断网时完整闭环仍然可通关。

## 验证

- T1.1–T4.1 共 12 个 Godot smoke 全部通过
- Windows PCK 配对包成功启动
- 打包后实机完成三项调查、播放录音，并进入第一轮删除/保留关键选择
- 既有 GUI 证据包含最终揭示、公开真相结局和保留记忆结局
- 打包实机截图：`docs/evidence/SUBMISSION/windows-build-main.jpg`
- 关键选择截图：`docs/evidence/SUBMISSION/windows-build-first-choice.jpg`

## 构建取舍

本机没有 Godot 4.7.1 导出模板。为避免截止时间前下载完整模板包，当前候选包使用：

- Godot 4.7.1 同版本 Windows 运行二进制
- 独立 `RESIDUAL.pck`

该方式可以直接运行，但包体大于标准 release-template 导出。正式模板构建可在提交后补做，不应阻塞当前截止时间。
