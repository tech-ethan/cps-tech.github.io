# ==========================================
# Installer Hub - Admin Setup
# Generated: 2026-04-21 22:02:24
# ==========================================

Assert-Administrator

$logDir = "C:\SetupLogs"

if (-not (Test-Path $logDir)) {
    New-Item -ItemType Directory -Path $logDir -Force | Out-Null
}

Start-Transcript -Path "C:\SetupLogs\InstallerHub-admin.log" -Append

. "https://tech-ethan.github.io/cps-tech.github.io/functions.ps1"

Write-Host "Starting Admin Setup..." -ForegroundColor Cyan

# --- Google Chrome
Install-App -Name "Google Chrome" -Installer @{
  type = "exe"
  url = "https://dl.google.com/update2/installers/ChromeSetup.exe"
  silentArgs = "/silent /install"
  innerInstaller = "exe"
}

Write-Host "Setup complete." -ForegroundColor Green
Stop-Transcript