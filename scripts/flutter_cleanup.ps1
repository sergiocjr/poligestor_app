# Encerra processos residuals deste projeto apos flutter run / debug stop.
# Seguro: nao mata analysis server, nem Java/Gradle de outros projetos.

$ErrorActionPreference = 'Continue'
$ProjectRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$ProjectMarker = 'poligestor_app'
$AndroidDir = Join-Path $ProjectRoot 'android'

Write-Host "[cleanup] Projeto: $ProjectRoot"

function Resolve-JavaHome {
    if ($env:JAVA_HOME -and (Test-Path (Join-Path $env:JAVA_HOME 'bin\java.exe'))) {
        return $env:JAVA_HOME
    }

    $candidates = @(
        'C:\Program Files\Android\Android Studio\jbr',
        'C:\Program Files\Android\Android Studio\jre',
        (Join-Path $env:LOCALAPPDATA 'Programs\Android\Android Studio\jbr'),
        (Join-Path $env:LOCALAPPDATA 'Programs\Android\Android Studio\jre')
    )

    foreach ($candidate in $candidates) {
        if ($candidate -and (Test-Path (Join-Path $candidate 'bin\java.exe'))) {
            return $candidate
        }
    }

    # Fallback: Java do daemon Gradle ja em execucao.
    $daemonJava = Get-CimInstance Win32_Process -ErrorAction SilentlyContinue |
        Where-Object { $_.Name -eq 'java.exe' -and $_.CommandLine -match 'GradleDaemon' } |
        Select-Object -First 1

    if ($daemonJava -and $daemonJava.CommandLine -match '"([^"]+\\java\.exe)"') {
        $javaExe = $Matches[1]
        $jbrRoot = Split-Path (Split-Path $javaExe -Parent) -Parent
        if (Test-Path (Join-Path $jbrRoot 'bin\java.exe')) {
            return $jbrRoot
        }
    }

    return $null
}

$resolvedJavaHome = Resolve-JavaHome
if ($resolvedJavaHome) {
    $env:JAVA_HOME = $resolvedJavaHome
    $env:PATH = "$(Join-Path $resolvedJavaHome 'bin');$env:PATH"
    Write-Host "[cleanup] JAVA_HOME=$resolvedJavaHome"
} else {
    Write-Host '[cleanup] JAVA_HOME nao encontrado; gradlew --stop pode falhar.'
}

# Garante o Gradle home real do usuario (evita cache/sandbox alternativo).
$env:GRADLE_USER_HOME = Join-Path $env:USERPROFILE '.gradle'
Write-Host "[cleanup] GRADLE_USER_HOME=$($env:GRADLE_USER_HOME)"

function Stop-GradleDaemons {
    $gradleDaemons = Get-CimInstance Win32_Process -ErrorAction SilentlyContinue |
        Where-Object { $_.Name -eq 'java.exe' -and $_.CommandLine -match 'GradleDaemon|gradle-daemon-main' }

    foreach ($daemon in $gradleDaemons) {
        Write-Host "[cleanup] Encerrando GradleDaemon PID $($daemon.ProcessId)"
        try {
            Stop-Process -Id $daemon.ProcessId -Force -ErrorAction Stop
        } catch {
            & taskkill.exe /PID $daemon.ProcessId /T /F 2>$null | Out-Null
        }
    }
}

# 1) Para daemons Gradle: gradlew --stop + kill residual (daemon e processo separado).
if (Test-Path (Join-Path $AndroidDir 'gradlew.bat')) {
    Push-Location $AndroidDir
    try {
        Write-Host '[cleanup] gradlew --stop'
        & .\gradlew.bat --stop 2>&1 | ForEach-Object { Write-Host $_ }
    } catch {
        Write-Host "[cleanup] gradlew --stop falhou: $_"
    } finally {
        Pop-Location
    }
}

# Sempre limpa daemons que sobraram (ex.: GRADLE_USER_HOME diferente ou --stop ineficaz).
Stop-GradleDaemons

function Test-ProjectProcess {
    param([string]$CommandLine)
    if ([string]::IsNullOrWhiteSpace($CommandLine)) { return $false }

    # Nunca encerrar o language/analysis server do IDE.
    if ($CommandLine -match 'analysis_server|language-server|dart_language_server') {
        return $false
    }

    $normalizedRoot = $ProjectRoot.Replace('\', '/')
    $normalizedCmd = $CommandLine.Replace('\', '/')

    if ($normalizedCmd -like "*$ProjectMarker*") { return $true }
    if ($normalizedCmd -like "*$normalizedRoot*") { return $true }

    # DDS / frontend_server / flutter run tipicamente citam o package ou o device session.
    if ($CommandLine -match 'development-service' -and $CommandLine -match $ProjectMarker) {
        return $true
    }

    return $false
}

function Stop-MatchingProcesses {
    param(
        [string[]]$Names,
        [string]$Label
    )

    $procs = Get-CimInstance Win32_Process -ErrorAction SilentlyContinue |
        Where-Object { $Names -contains $_.Name }

    foreach ($proc in $procs) {
        if (-not (Test-ProjectProcess -CommandLine $proc.CommandLine)) { continue }

        Write-Host "[cleanup] Encerrando $Label PID $($proc.ProcessId): $($proc.Name)"
        try {
            Stop-Process -Id $proc.ProcessId -Force -ErrorAction Stop
        } catch {
            # fallback via taskkill (arvore)
            & taskkill.exe /PID $proc.ProcessId /T /F 2>$null | Out-Null
        }
    }
}

# 2) Dart/Flutter helpers orfaos deste app (nao o analyzer do Cursor).
Stop-MatchingProcesses -Names @('dart.exe', 'dartaotruntime.exe') -Label 'Dart/Flutter'

# 3) Workers Java residuais deste build (Kotlin daemon / workers com path do projeto).
$javaProcs = Get-CimInstance Win32_Process -ErrorAction SilentlyContinue |
    Where-Object { $_.Name -eq 'java.exe' }

foreach ($proc in $javaProcs) {
    $cmd = $proc.CommandLine
    if ([string]::IsNullOrWhiteSpace($cmd)) { continue }

    $normalizedRoot = $ProjectRoot.Replace('\', '/')
    $normalizedCmd = $cmd.Replace('\', '/')

    $isProjectJava =
        ($cmd -match 'GradleDaemon|gradle-daemon-main') -or
        ($cmd -match 'kotlin[.-]daemon|KotlinCompileDaemon') -or
        ($normalizedCmd -like "*$normalizedRoot*") -or
        ($normalizedCmd -like "*$ProjectMarker*")

    if (-not $isProjectJava) { continue }

    Write-Host "[cleanup] Encerrando Java residual PID $($proc.ProcessId)"
    try {
        Stop-Process -Id $proc.ProcessId -Force -ErrorAction Stop
    } catch {
        & taskkill.exe /PID $proc.ProcessId /T /F 2>$null | Out-Null
    }
}

# Aguarda saida efetiva dos processos alvo (evita falso positivo imediato).
for ($i = 0; $i -lt 10; $i++) {
    $left = Get-CimInstance Win32_Process -ErrorAction SilentlyContinue | Where-Object {
        ($_.Name -match 'dart\.exe|dartaotruntime\.exe' -and (Test-ProjectProcess -CommandLine $_.CommandLine)) -or
        ($_.Name -eq 'java.exe' -and $_.CommandLine -match 'GradleDaemon|gradle-daemon-main|kotlin[.-]daemon|KotlinCompileDaemon')
    }
    if (-not $left) { break }
    Start-Sleep -Milliseconds 200
}

# Relatorio final de Java residual (somente informativo).
$remainingJava = Get-Process java, javaw -ErrorAction SilentlyContinue
$projectJavaLeft = @(
    Get-CimInstance Win32_Process -ErrorAction SilentlyContinue | Where-Object {
        $_.Name -match 'java\.exe|javaw\.exe' -and (
            $_.CommandLine -match 'GradleDaemon|gradle-daemon-main|kotlin[.-]daemon|KotlinCompileDaemon' -or
            ($_.CommandLine -and ($_.CommandLine.Replace('\', '/') -like "*$($ProjectRoot.Replace('\', '/'))*")) -or
            ($_.CommandLine -and $_.CommandLine -like "*$ProjectMarker*")
        )
    }
)

$totalMb = 0
foreach ($p in @($remainingJava)) {
    $totalMb += [math]::Round($p.WorkingSet64 / 1MB, 0)
}

Write-Host "[cleanup] Java no sistema: $(@($remainingJava).Count) processo(s), ~${totalMb} MB RAM total."
Write-Host "[cleanup] Java ligado ao projeto apos cleanup: $($projectJavaLeft.Count)"
Write-Host '[cleanup] Concluido.'
