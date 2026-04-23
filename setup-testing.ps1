# ==========================================
# Installer Hub - Testing Setup
# Generated: 2026-04-22 22:02:24
# ==========================================

Assert-Administrator

$logDir = "C:\SetupLogs"

if (-not (Test-Path $logDir)) {
    New-Item -ItemType Directory -Path $logDir -Force | Out-Null
}

Start-Transcript -Path "C:\SetupLogs\InstallerHub-admin.log" -Append

. "https://tech-ethan.github.io/cps-tech.github.io/functions.ps1"

Write-Host "Starting Testing Setup..." -ForegroundColor Cyan

# --- Firefox
Install-App -Name "Mozilla Firefox" -Installer @{
  type = "exe"
  url = "https://cdn.stubdownloader.services.mozilla.com/builds/firefox-stub/en-US/win/080893360a11b78abcbe5c5f2169892aa9eb14347d6138815333e479ced07801/Firefox%20Installer.exe"
  silentArgs = "/silent /install"
  innerInstaller = "exe"
}

Write-Host "Setup complete." -ForegroundColor Green
Stop-Transcript