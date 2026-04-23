# ==========================================
# AUTO-GENERATED - DO NOT EDIT
# Profile: Admin Setup
# Generated: 2026-04-22 21:51:54
# ==========================================

Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
#Requires -RunAsAdministrator

$logDir = "C:\SetupLogs"
if (-not (Test-Path $logDir)) {
    New-Item -ItemType Directory -Path $logDir -Force | Out-Null
}

Start-Transcript -Path "\InstallerHub-admin.log" -Append

. "$PSScriptRoot\functions.ps1"

Write-Host "Starting Admin Setup..." -ForegroundColor Cyan

# --- Google Chrome
Install-App -Name "Google Chrome" -Installer @{
    type = "exe"
    url = "https://dl.google.com/update2/installers/ChromeSetup.exe"
    silentArgs = "/silent /install"
    innerInstaller = "exe"
}

# --- Google Drive
Install-App -Name "Google Drive" -Installer @{
    type = "exe"
    url = "https://dl.google.com/drive-file-stream/GoogleDriveSetup.exe"
    silentArgs = "/silent /install"
    innerInstaller = "exe"
}

# --- Wisenet Wave
Install-App -Name "Wisenet Wave" -Installer @{
    type = "exe"
    url = "https://updates.wavevms.com/hanwha/41290/windows/wave-client-6.0.5.41290-windows_x64.exe"
    silentArgs = "/silent /install"
    innerInstaller = "exe"
}

# --- UniFLOW SmartClient
Install-App -Name "UniFLOW SmartClient" -Installer @{
    type = "msi"
    url = "https://antibodysoftware-17031.kxcdn.com/files/wiztree_4_31_portable.zip"
    silentArgs = "/silent /install"
    innerInstaller = "msi"
}

# ------------------------------------------------------------
# Finalize summary + write report JSON
# ------------------------------------------------------------
$Script:InstallResults.Profile = "Admin Setup"
$Script:InstallResults.EndTime = Get-Date

$reportDir = Join-Path $logDir "Reports"
New-Item -ItemType Directory -Path $reportDir -Force | Out-Null

$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$reportPath = Join-Path $reportDir "$($env:COMPUTERNAME)-$timestamp.json"

$Script:InstallResults |
  ConvertTo-Json -Depth 5 |
  Out-File -Encoding UTF8 $reportPath

Write-Host "Summary report written to $reportPath" -ForegroundColor Green

if ($env:INSTALLER_UPLOAD -eq "true") {
    try {
        Invoke-RestMethod
            -Uri "https://script.google.com/macros/s/AKfycbzmzgSuvE6eALABU700n5YNN1r4gCKmllCflkyH4GhkCJwPb0L89iuidQaUYVC9NMelpA/exec"
            -Method POST
            -Body ($Script:InstallResults | ConvertTo-Json -Depth 5)
            -ContentType "application/json"

        Write-Host "Summary report uploaded successfully."
    }
    catch {
        Write-Warning "Summary upload failed - continuing without blocking."
    }
}

Write-Host "Setup complete." -ForegroundColor Green
Stop-Transcript
