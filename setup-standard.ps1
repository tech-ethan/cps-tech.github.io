# ==========================================
# AUTO-GENERATED - DO NOT EDIT
# Profile: Standard Setup
# Generated: 2026-04-22 21:51:54
# ==========================================

Assert-Administrator

$logDir = "C:\SetupLogs"
if (-not (Test-Path $logDir)) {
    New-Item -ItemType Directory -Path $logDir -Force | Out-Null
}

Start-Transcript -Path "\InstallerHub-standard.log" -Append

. "$PSScriptRoot\functions.ps1"
Assert-Administrator

Write-Host "Starting Standard Setup..." -ForegroundColor Cyan

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

# --- InstaShare
Install-App -Name "InstaShare" -Installer @{
    type = "zip"
    url = "https://esupportdownload.benq.com/esupport/PUBLIC%20DISPLAY%20PRODUCT/Software/InstaShare/InstaShare_for%20Windows%20(.MSI)_v2.0.0.26_Windows_230330163404.zip"
    silentArgs = "/qn /norestart"
    innerInstaller = "msi"
}

# --- InstaShare 2
Install-App -Name "InstaShare 2" -Installer @{
    type = "zip"
    url = "https://esupportdownload.benq.com/esupport/INTERACTIVE%20FLAT%20PLAT%20FOR%20EDUCATION/Software/InstaShare%202/InstaShare%202_for%20Windows%20(.MSI)_1.9.5.0_Windows_260205155943.zip"
    silentArgs = "/qn /norestart"
    innerInstaller = "msi"
}

# --- UniFLOW SmartClient
Install-App -Name "UniFLOW SmartClient" -Installer @{
    type = "msi"
    url = "https://antibodysoftware-17031.kxcdn.com/files/wiztree_4_31_portable.zip"
    silentArgs = "/silent /install"
    innerInstaller = "msi"
}

# --- vCastSender
Install-App -Name "vCastSender" -Installer @{
    type = "zip"
    url = "https://www.viewsonicglobal.com/public/products_download/software/cd/vCastSender_for_Windows.zip?pass"
    silentArgs = "/qn /norestar"
    innerInstaller = "msi"
}

# ------------------------------------------------------------
# Finalize summary + write report JSON
# ------------------------------------------------------------
$Script:InstallResults.Profile = "Standard Setup"
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
