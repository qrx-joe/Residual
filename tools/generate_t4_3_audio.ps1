param(
    [string]$OutputRoot = (Join-Path $PSScriptRoot '..\assets\audio')
)

$ErrorActionPreference = 'Stop'
$resolvedOutput = [System.IO.Path]::GetFullPath($OutputRoot)
$projectRoot = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
if (-not $resolvedOutput.StartsWith($projectRoot, [System.StringComparison]::OrdinalIgnoreCase)) {
    throw "Audio output must stay inside the project: $resolvedOutput"
}

$ffmpeg = (Get-Command ffmpeg -ErrorAction Stop).Source
$voiceDirectory = Join-Path $resolvedOutput 'voice'
$sfxDirectory = Join-Path $resolvedOutput 'sfx'
$ambienceDirectory = Join-Path $resolvedOutput 'ambience'
New-Item -ItemType Directory -Force -Path $voiceDirectory, $sfxDirectory, $ambienceDirectory | Out-Null

function Invoke-Ffmpeg {
    param([string[]]$Arguments)
    & $ffmpeg @Arguments
    if ($LASTEXITCODE -ne 0) {
        throw "ffmpeg failed with exit code $LASTEXITCODE"
    }
}

function New-VoiceLine {
    param(
        [string]$FileName,
        [string]$Text,
        [int]$Rate = -1
    )

    Add-Type -AssemblyName System.Speech
    $rawPath = Join-Path ([System.IO.Path]::GetTempPath()) (
        "residual-voice-{0}.wav" -f [System.Guid]::NewGuid().ToString('N')
    )
    $synth = New-Object System.Speech.Synthesis.SpeechSynthesizer
    try {
        $synth.SelectVoice('Microsoft Huihui Desktop')
        $synth.Rate = $Rate
        $synth.Volume = 88
        $synth.SetOutputToWaveFile($rawPath)
        $synth.Speak($Text)
    }
    finally {
        $synth.Dispose()
    }

    try {
        Invoke-Ffmpeg @(
            '-y', '-i', $rawPath,
            '-af', 'highpass=f=180,lowpass=f=3600,acompressor=threshold=-20dB:ratio=2.5:attack=8:release=120,loudnorm=I=-20:TP=-3:LRA=7',
            '-ar', '48000', '-ac', '1', '-c:a', 'pcm_s16le',
            (Join-Path $voiceDirectory $FileName)
        )
    }
    finally {
        Remove-Item -LiteralPath $rawPath -ErrorAction SilentlyContinue
    }
}

Invoke-Ffmpeg @(
    '-y',
    '-f', 'lavfi', '-i', 'anoisesrc=color=brown:amplitude=0.045:duration=20:sample_rate=48000',
    '-f', 'lavfi', '-i', 'sine=frequency=72:duration=20:sample_rate=48000',
    '-filter_complex', '[0:a]lowpass=f=900,volume=0.22[n];[1:a]volume=0.018[h];[n][h]amix=inputs=2:duration=longest,afade=t=in:d=1,afade=t=out:st=19:d=1[a]',
    '-map', '[a]', '-ar', '48000', '-ac', '2', '-c:a', 'pcm_s16le',
    (Join-Path $ambienceDirectory 'office_night.wav')
)

Invoke-Ffmpeg @(
    '-y', '-f', 'lavfi', '-i', 'sine=frequency=880:duration=0.08:sample_rate=48000',
    '-af', 'volume=0.12,afade=t=out:st=0.04:d=0.04',
    '-ar', '48000', '-ac', '1', '-c:a', 'pcm_s16le',
    (Join-Path $sfxDirectory 'ui_click.wav')
)

Invoke-Ffmpeg @(
    '-y', '-f', 'lavfi', '-i', 'sine=frequency=260:duration=0.34:sample_rate=48000',
    '-af', 'tremolo=f=18:d=0.75,volume=0.3,afade=t=out:st=0.16:d=0.18',
    '-ar', '48000', '-ac', '1', '-c:a', 'pcm_s16le',
    (Join-Path $sfxDirectory 'delete_confirm.wav')
)

Invoke-Ffmpeg @(
    '-y', '-f', 'lavfi', '-i', 'anoisesrc=color=white:amplitude=0.2:duration=0.55:sample_rate=48000',
    '-af', 'highpass=f=700,lowpass=f=5200,tremolo=f=31:d=0.9,volume=0.34,afade=t=out:st=0.35:d=0.2',
    '-ar', '48000', '-ac', '1', '-c:a', 'pcm_s16le',
    (Join-Path $sfxDirectory 'core_glitch.wav')
)

Invoke-Ffmpeg @(
    '-y',
    '-f', 'lavfi', '-i', 'sine=frequency=920:duration=1.15:sample_rate=48000',
    '-f', 'lavfi', '-i', 'anoisesrc=color=pink:amplitude=0.08:duration=1.15:sample_rate=48000',
    '-filter_complex', '[0:a]asetrate=48000*0.58,aresample=48000,atempo=1.724,volume=0.28[t];[1:a]lowpass=f=1800,volume=0.18[n];[t][n]amix=inputs=2:duration=shortest,afade=t=out:st=0.8:d=0.35[a]',
    '-map', '[a]', '-ar', '48000', '-ac', '1', '-c:a', 'pcm_s16le',
    (Join-Path $sfxDirectory 'overwrite_reverse.wav')
)

$introText = [System.Text.RegularExpressions.Regex]::Unescape(
    '\u5982\u679C\u4F60\u542C\u5230\u4E86\u2026\u2026\u522B\u8BA9\u96F6\u4E09\u53F7\u66FF\u4F60\u51B3\u5B9A\u3002'
)
$recordingText = [System.Text.RegularExpressions.Regex]::Unescape(
    '\u4ED6\u4EEC\u6CA1\u6709\u5220\u9664\u4EFB\u4F55\u4E1C\u897F\u3002\u53EA\u662F\u8BA9\u6211\u4EEC\u770B\u4E0D\u89C1\u3002'
)
$ghostText = [System.Text.RegularExpressions.Regex]::Unescape(
    '\u4F60\u53C8\u5220\u6389\u4E86\u2026\u2026'
)

New-VoiceLine -FileName 'voice_azhi_intro.wav' -Text $introText
New-VoiceLine -FileName 'voice_azhi_recording.wav' -Text $recordingText
New-VoiceLine -FileName 'voice_azhi_ghost.wav' -Text $ghostText -Rate -2

Write-Output "Generated T4.3 audio assets in $resolvedOutput"
