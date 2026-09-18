[CmdletBinding()]
param()

$ErrorActionPreference = "Stop"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$RepositoryUrl = "https://github.com/KeshavKhippal/BeMousless/archive/refs/heads/main.zip"
$AutoHotkeyVersion = "1.1.37.02"
$AutoHotkeySha256 = "6F3663F7CDD25063C8C8728F5D9B07813CED8780522FD1F124BA539E2854215F"
$AutoHotkeyUrl = "https://github.com/AutoHotkey/AutoHotkey/releases/download/v$AutoHotkeyVersion/AutoHotkey_$AutoHotkeyVersion.zip"
$InstallDirectory = Join-Path $env:LOCALAPPDATA "BeMousless"
$RuntimeDirectory = Join-Path $InstallDirectory "autohotkey-$AutoHotkeyVersion"
$ArchiveDirectory = Join-Path $env:TEMP "BeMousless-$([guid]::NewGuid().ToString('N'))"
$AutoHotkeyArchive = Join-Path $env:TEMP "AutoHotkey_$AutoHotkeyVersion.zip"
$RepositoryArchive = Join-Path $env:TEMP "BeMousless-main.zip"
$ExecutableName = if ([Environment]::Is64BitOperatingSystem) { "AutoHotkeyU64.exe" } else { "AutoHotkeyU32.exe" }
$ExecutablePath = Join-Path $RuntimeDirectory $ExecutableName

try {
    Write-Host "Preparing AutoHotkey v$AutoHotkeyVersion..."
    if (-not (Test-Path -LiteralPath $ExecutablePath)) {
        New-Item -ItemType Directory -Force -Path $RuntimeDirectory | Out-Null
        Invoke-WebRequest -Uri $AutoHotkeyUrl -OutFile $AutoHotkeyArchive

        $ActualSha256 = (Get-FileHash -Algorithm SHA256 -LiteralPath $AutoHotkeyArchive).Hash
        if ($ActualSha256 -ne $AutoHotkeySha256) {
            throw "AutoHotkey archive checksum verification failed."
        }

        Expand-Archive -LiteralPath $AutoHotkeyArchive -DestinationPath $RuntimeDirectory -Force
    }

    Write-Host "Downloading BeMousless..."
    New-Item -ItemType Directory -Force -Path $ArchiveDirectory | Out-Null
    Invoke-WebRequest -Uri $RepositoryUrl -OutFile $RepositoryArchive
    Expand-Archive -LiteralPath $RepositoryArchive -DestinationPath $ArchiveDirectory -Force

    $ExtractedDirectory = Join-Path $ArchiveDirectory "BeMousless-main"
    $SourceDirectory = Join-Path $InstallDirectory "source"
    if (Test-Path -LiteralPath $SourceDirectory) {
        Remove-Item -LiteralPath $SourceDirectory -Recurse -Force
    }
    New-Item -ItemType Directory -Force -Path $InstallDirectory | Out-Null
    Move-Item -LiteralPath $ExtractedDirectory -Destination $SourceDirectory

    $ScriptPath = Join-Path $SourceDirectory "BeMousless.ahk"
    if (-not (Test-Path -LiteralPath $ScriptPath)) {
        throw "BeMousless.ahk was not found in the downloaded repository."
    }

    Write-Host "Starting BeMousless..."
    Start-Process -FilePath $ExecutablePath -ArgumentList @($ScriptPath) -WorkingDirectory $SourceDirectory
    Write-Host "BeMousless is running. Files are installed in $InstallDirectory"
}
finally {
    Remove-Item -LiteralPath $ArchiveDirectory -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item -LiteralPath $RepositoryArchive -Force -ErrorAction SilentlyContinue
    Remove-Item -LiteralPath $AutoHotkeyArchive -Force -ErrorAction SilentlyContinue
}
