[CmdletBinding()]
param(
    [switch]$NoLaunch
)

$ErrorActionPreference = "Stop"

$AutoHotkeyVersion = "1.1.37.02"
$AutoHotkeySha256 = "6F3663F7CDD25063C8C8728F5D9B07813CED8780522FD1F124BA539E2854215F"
$DownloadUrl = "https://github.com/AutoHotkey/AutoHotkey/releases/download/v$AutoHotkeyVersion/AutoHotkey_$AutoHotkeyVersion.zip"
$ToolsDirectory = Join-Path $PSScriptRoot ".tools\autohotkey-$AutoHotkeyVersion"
$ArchivePath = Join-Path $env:TEMP "AutoHotkey_$AutoHotkeyVersion.zip"
$ScriptPath = Join-Path $PSScriptRoot "BeMousless.ahk"

if (-not (Test-Path -LiteralPath $ScriptPath)) {
    throw "BeMousless.ahk was not found next to setup.ps1."
}

$ExecutableName = if ([Environment]::Is64BitOperatingSystem) {
    "AutoHotkeyU64.exe"
} else {
    "AutoHotkeyU32.exe"
}
$ExecutablePath = Join-Path $ToolsDirectory $ExecutableName

if (-not (Test-Path -LiteralPath $ExecutablePath)) {
    Write-Host "Downloading AutoHotkey $AutoHotkeyVersion..."
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    New-Item -ItemType Directory -Force -Path $ToolsDirectory | Out-Null
    Invoke-WebRequest -Uri $DownloadUrl -OutFile $ArchivePath

    $ActualSha256 = (Get-FileHash -Algorithm SHA256 -LiteralPath $ArchivePath).Hash
    if ($ActualSha256 -ne $AutoHotkeySha256) {
        Remove-Item -LiteralPath $ArchivePath -Force -ErrorAction SilentlyContinue
        throw "AutoHotkey archive checksum verification failed. Expected $AutoHotkeySha256 but received $ActualSha256."
    }

    Write-Host "Installing AutoHotkey $AutoHotkeyVersion locally..."
    Expand-Archive -LiteralPath $ArchivePath -DestinationPath $ToolsDirectory -Force
}

if (-not (Test-Path -LiteralPath $ExecutablePath)) {
    throw "AutoHotkey $AutoHotkeyVersion was downloaded, but $ExecutableName was not found in the archive."
}

if ($NoLaunch) {
    Write-Host "AutoHotkey $AutoHotkeyVersion is ready at $ExecutablePath"
    exit 0
}

Write-Host "Starting BeMousless.ahk with AutoHotkey $AutoHotkeyVersion..."
Start-Process `
    -FilePath $ExecutablePath `
    -ArgumentList @("`"$ScriptPath`"") `
    -WorkingDirectory $PSScriptRoot