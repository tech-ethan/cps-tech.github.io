# ==========================================
# Installer Hub - Classroom Setup
# Generated: 2026-04-21 22:02:24
# ==========================================

Start-Transcript -Path "C:\SetupLogs\InstallerHub-classroom.log" -Append

. "C:\Users\numnu\Desktop\cps-tech.github.io-main\functions.ps1"
Assert-Administrator

Write-Host "Starting Classroom Setup..." -ForegroundColor Cyan

# --- Google Chrome
Install-App -Name "Google Chrome" -Installer @{
  type = "exe"
  url = "https://dl.google.com/update2/installers/ChromeSetup.exe"
  silentArgs = "/silent /install"
  innerInstaller = "exe"
}

# --- InstaShare
Install-App -Name "InstaShare" -Installer @{
  type = "zip"
  url = "https://esupportdownload.benq.com/esupport/PUBLIC%20DISPLAY%20PRODUCT/Software/InstaShare/InstaShare_for%20Windows%20(.MSI)_v2.0.0.26_Windows_230330163404.zip"
  silentArgs = "/qn /norestart"
  innerInstaller = "msi"
}

Write-Host "Setup complete." -ForegroundColor Green
Stop-Transcript
