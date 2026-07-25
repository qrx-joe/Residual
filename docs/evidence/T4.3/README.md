# T4.3 音频验收

## 已实现

- 20 秒深夜办公室循环环境音
- UI 点击、删除确认、核心故障与 99% 倒退音
- 阿栀开场、正常录音与幽灵录音
- 行动、覆盖阶段和结局状态驱动播放
- 主音量滑块与静音按钮

所有音频均为静态 WAV，随构建打包，运行时不生成。

## Godot 验证

```powershell
& 'D:\Env\Godot\Godot_v4.7.1-stable_win64_console.exe' `
  --headless `
  --path 'D:\Env\gameDev\Residual' `
  --script 'res://tests/t4_3_smoke.gd'
```

结果：

```text
T4.3 smoke: ambience, voice, cues, volume, and mute passed
```

## 电平与时长

| 文件 | 时长 | 峰值 |
|---|---:|---:|
| `office_night.wav` | 20.00 s | -49.48 dBFS |
| `core_glitch.wav` | 0.55 s | -24.90 dBFS |
| `delete_confirm.wav` | 0.34 s | -28.52 dBFS |
| `overwrite_reverse.wav` | 1.15 s | -33.43 dBFS |
| `ui_click.wav` | 0.08 s | -36.49 dBFS |
| `voice_azhi_ghost.wav` | 2.32 s | -3.63 dBFS |
| `voice_azhi_intro.wav` | 5.05 s | -3.00 dBFS |
| `voice_azhi_recording.wav` | 6.32 s | -3.00 dBFS |

所有峰值均低于 0 dBFS，三段台词均短于 10 秒。

## 来源与发布风险

- 提示音和环境音由仓库脚本通过 FFmpeg 合成。
- 临时阿栀配音由本机 `Microsoft Huihui Desktop` 生成。
- Windows TTS 输出的对外分发授权尚未确认；公开发行前必须由用户确认许可，
  或替换为具有明确商用授权的真人/第三方 TTS 录音。
