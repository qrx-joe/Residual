param(
    [string]$GodotGuiPath = "D:\Env\Godot\Godot_v4.7.1-stable_win64.exe",
    [string]$GodotConsolePath = "D:\Env\Godot\Godot_v4.7.1-stable_win64_console.exe",
    [string]$OutputDirectory = "build\t5.2-windows",
    [string]$ZipPath = "build\RESIDUAL-Windows-post-jam.zip"
)

$ErrorActionPreference = "Stop"
$projectRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$outputPath = [System.IO.Path]::GetFullPath(
    (Join-Path $projectRoot $OutputDirectory)
)
$archivePath = [System.IO.Path]::GetFullPath((Join-Path $projectRoot $ZipPath))
$buildRoot = [System.IO.Path]::GetFullPath((Join-Path $projectRoot "build"))

if (-not $outputPath.StartsWith($buildRoot, [System.StringComparison]::OrdinalIgnoreCase)) {
    throw "Output directory must stay under $buildRoot"
}
if (-not $archivePath.StartsWith($buildRoot, [System.StringComparison]::OrdinalIgnoreCase)) {
    throw "Archive path must stay under $buildRoot"
}
foreach ($requiredPath in @($GodotGuiPath, $GodotConsolePath)) {
    if (-not (Test-Path -LiteralPath $requiredPath -PathType Leaf)) {
        throw "Required Godot executable not found: $requiredPath"
    }
}

New-Item -ItemType Directory -Path $outputPath -Force | Out-Null
$pckPath = Join-Path $outputPath "RESIDUAL.pck"
$exePath = Join-Path $outputPath "RESIDUAL.exe"
$readmePath = Join-Path $outputPath "README.txt"
$runtimeLogPath = Join-Path $outputPath "runtime-validation.log"

& $GodotConsolePath `
    --headless `
    --path $projectRoot `
    --export-pack "Windows Desktop" $pckPath
if ($LASTEXITCODE -ne 0) {
    throw "Godot PCK export failed with exit code $LASTEXITCODE"
}

Copy-Item -LiteralPath $GodotGuiPath -Destination $exePath -Force
Copy-Item `
    -LiteralPath (Join-Path $projectRoot "packaging\windows\README.txt") `
    -Destination $readmePath `
    -Force

$previousErrorActionPreference = $ErrorActionPreference
$ErrorActionPreference = "Continue"
$runtimeOutput = & $GodotConsolePath `
    --main-pack $pckPath `
    --headless `
    --verbose `
    --quit-after 5 2>&1
$runtimeExitCode = $LASTEXITCODE
$ErrorActionPreference = $previousErrorActionPreference
$runtimeLog = $runtimeOutput -join [Environment]::NewLine
[System.IO.File]::WriteAllText(
    $runtimeLogPath,
    $runtimeLog,
    [System.Text.UTF8Encoding]::new($false)
)
if ($runtimeExitCode -ne 0) {
    throw "Packaged runtime failed with exit code $runtimeExitCode"
}

if ($runtimeLog -match "SCRIPT ERROR|Leaked instance|Resource still in use|ERROR:") {
    throw "Packaged runtime log contains an error: $runtimeLogPath"
}

if (Test-Path -LiteralPath $archivePath -PathType Leaf) {
    Remove-Item -LiteralPath $archivePath -Force
}
Compress-Archive `
    -LiteralPath @($exePath, $pckPath, $readmePath) `
    -DestinationPath $archivePath `
    -CompressionLevel Optimal

$archive = Get-Item -LiteralPath $archivePath
$hash = Get-FileHash -LiteralPath $archivePath -Algorithm SHA256
Write-Host ("T5.2 build: PASS {0} bytes SHA-256 {1}" -f $archive.Length, $hash.Hash)
Write-Host ("Archive: {0}" -f $archive.FullName)
Write-Host ("Runtime log: {0}" -f $runtimeLogPath)
