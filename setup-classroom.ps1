# ==========================================
# AUTO-GENERATED - DO NOT EDIT
# Profile: Classroom Setup
# Generated: 2026-04-22 21:51:54
# ==========================================

Assert-Administrator

$logDir = "C:\SetupLogs"
if (-not (Test-Path $logDir)) {
    New-Item -ItemType Directory -Path $logDir -Force | Out-Null
}

Start-Transcript -Path "\InstallerHub-classroom.log" -Append

. "$PSScriptRoot\functions.ps1"
Assert-Administrator

Write-Host "Starting Classroom Setup..." -ForegroundColor Cyan

# --- Google Chrome
Install-App -Name "Google Chrome" -Installer @{
    type = "exe"
    url = "https://dl.google.com/update2/installers/ChromeSetup.exe"
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
$Script:InstallResults.Profile = "Classroom Setup"
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
