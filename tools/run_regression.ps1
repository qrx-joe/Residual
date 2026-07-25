param(
    [ValidateRange(1, 100)]
    [int]$Cycles = 10,
    [string]$GodotPath = "D:\Env\Godot\Godot_v4.7.1-stable_win64_console.exe"
)

$ErrorActionPreference = "Stop"
if (Test-Path Variable:\PSNativeCommandUseErrorActionPreference) {
    $PSNativeCommandUseErrorActionPreference = $false
}
$projectRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path

if (-not (Test-Path -LiteralPath $GodotPath -PathType Leaf)) {
    throw "Godot executable not found: $GodotPath"
}

$tests = @(
    Get-ChildItem -LiteralPath (Join-Path $projectRoot "tests") -Filter "*_smoke.gd" -File |
        Sort-Object Name
)

if ($tests.Count -eq 0) {
    throw "No smoke tests found under $projectRoot\tests"
}

$failurePattern = "SCRIPT ERROR|Leaked instance|Resource still in use|ERROR:"
$totalRuns = 0
$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

for ($cycle = 1; $cycle -le $Cycles; $cycle++) {
    Write-Host ("T5.1 cycle {0}/{1}" -f $cycle, $Cycles)

    foreach ($test in $tests) {
        $previousErrorActionPreference = $ErrorActionPreference
        $ErrorActionPreference = "Continue"
        $output = & $GodotPath `
            --headless `
            --verbose `
            --path $projectRoot `
            --script ("res://tests/{0}" -f $test.Name) 2>&1
        $exitCode = $LASTEXITCODE
        $ErrorActionPreference = $previousErrorActionPreference
        $outputText = $output -join [Environment]::NewLine
        $totalRuns++

        if ($exitCode -ne 0 -or $outputText -match $failurePattern) {
            Write-Host $outputText
            throw ("Regression failed in cycle {0}, test {1}, exit code {2}" -f $cycle, $test.Name, $exitCode)
        }

        $smokeLine = $output |
            Where-Object { $_.ToString() -match "smoke:" } |
            Select-Object -Last 1
        if ($null -eq $smokeLine) {
            Write-Host $outputText
            throw ("Regression test produced no smoke result in cycle {0}: {1}" -f $cycle, $test.Name)
        }

        Write-Host ("  PASS {0}" -f $test.Name)
    }
}

$stopwatch.Stop()
Write-Host (
    "T5.1 regression: PASS {0} cycles, {1} tests/cycle, {2} total runs, zero leaks, {3:n1}s" -f `
        $Cycles,
        $tests.Count,
        $totalRuns,
        $stopwatch.Elapsed.TotalSeconds
)
