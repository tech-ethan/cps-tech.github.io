# ==========================================
# AUTO-GENERATED - DO NOT EDIT
# Profile: Testing Setup
# Generated: 2026-04-23 08:34:33
# ==========================================

Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
#Requires -RunAsAdministrator

$logDir = "C:\SetupLogs"
if (-not (Test-Path $logDir)) {
    New-Item -ItemType Directory -Path $logDir -Force | Out-Null
}

Start-Transcript -Path "\InstallerHub-test.log" -Append

. "$PSScriptRoot\functions.ps1"

Write-Host "Starting Testing Setup..." -ForegroundColor Cyan

# --- Mozilla FireFox
Install-App -Name "Mozilla FireFox" -Installer @{
    type = "exe"
    url = "https://cdn.stubdownloader.services.mozilla.com/builds/firefox-stub/en-US/win/080893360a11b78abcbe5c5f2169892aa9eb14347d6138815333e479ced07801/Firefox%20Installer.exe"
    silentArgs = "/silent /install"
    innerInstaller = "exe"
}

# ------------------------------------------------------------
# Finalize summary + write report JSON
# ------------------------------------------------------------
$Script:InstallResults.Profile = "Testing Setup"
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
            -Uri "https://script.google.com/a/macros/cps.k12.ar.us/s/AKfycbzmzgSuvE6eALABU700n5YNN1r4gCKmllCflkyH4GhkCJwPb0L89iuidQaUYVC9NMelpA/exec"
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
