# ==========================================
# Installer Hub - Admin Setup
# Generated: 2026-04-21 22:02:24
# ==========================================

Start-Transcript -Path "C:\SetupLogs\InstallerHub-admin.log" -Append

. "C:\Users\numnu\Desktop\cps-tech.github.io-main\functions.ps1"
Assert-Administrator

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
