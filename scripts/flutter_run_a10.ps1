# Inicia o app no Galaxy A10 e garante cleanup ao sair (Ctrl+C / Stop / exit).
$ErrorActionPreference = 'Stop'
$ProjectRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$DeviceId = 'RX8M70CLXKP'
$CleanupScript = Join-Path $PSScriptRoot 'flutter_cleanup.ps1'

Set-Location $ProjectRoot

function Resolve-JavaHome {
    if ($env:JAVA_HOME -and (Test-Path (Join-Path $env:JAVA_HOME 'bin\java.exe'))) {
        return $env:JAVA_HOME
    }
    $candidates = @(
        'C:\Program Files\Android\Android Studio\jbr',
        'C:\Program Files\Android\Android Studio\jre',
        (Join-Path $env:LOCALAPPDATA 'Programs\Android\Android Studio\jbr')
    )
    foreach ($candidate in $candidates) {
        if ($candidate -and (Test-Path (Join-Path $candidate 'bin\java.exe'))) {
            return $candidate
        }
    }
    return $null
}

$javaHome = Resolve-JavaHome
if ($javaHome) {
    $env:JAVA_HOME = $javaHome
    $env:PATH = "$(Join-Path $javaHome 'bin');$env:PATH"
}

# Usa o Gradle home real do usuario (evita sandbox/cache alternativo).
if (-not $env:GRADLE_USER_HOME) {
    $env:GRADLE_USER_HOME = Join-Path $env:USERPROFILE '.gradle'
}

Write-Host '[run] flutter devices'
& flutter devices
if ($LASTEXITCODE -ne 0) {
    throw 'flutter devices falhou.'
}

$devicesOutput = & flutter devices 2>&1 | Out-String
if ($devicesOutput -notmatch [regex]::Escape($DeviceId)) {
    Write-Host "[run] Dispositivo fisico $DeviceId nao encontrado. Emulador NAO sera iniciado."
    exit 1
}

$flutterArgs = @('run', '-d', $DeviceId) + $args
Write-Host "[run] flutter $($flutterArgs -join ' ')"

$exitCode = 0
$process = $null
try {
    $process = Start-Process `
        -FilePath 'flutter' `
        -ArgumentList $flutterArgs `
        -WorkingDirectory $ProjectRoot `
        -NoNewWindow `
        -PassThru

    Wait-Process -Id $process.Id
    if ($null -ne $process.ExitCode) {
        $exitCode = $process.ExitCode
    }
} finally {
    if ($null -ne $process -and -not $process.HasExited) {
        Write-Host "[run] Encerrando flutter PID $($process.Id)..."
        try {
            Stop-Process -Id $process.Id -Force -ErrorAction SilentlyContinue
            & taskkill.exe /PID $process.Id /T /F 2>$null | Out-Null
        } catch {}
    }

    if (Test-Path $CleanupScript) {
        Write-Host '[run] Executando cleanup pos-stop...'
        & powershell -NoProfile -ExecutionPolicy Bypass -File $CleanupScript
    }
}

exit $exitCode
