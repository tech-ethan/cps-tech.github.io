# ================================
# Installer Hub – Standard Setup
# ================================

$LogDir = "C:\SetupLogs"
New-Item -ItemType Directory -Force -Path $LogDir | Out-Null
Start-Transcript -Path "$LogDir\InstallerHub-Standard.log" -Append

. "$PSScriptRoot\functions.ps1"

Assert-Administrator

Write-Host "Starting standard workstation setup..." -ForegroundColor Cyan

# ================================
# Application Installs
# ================================

Install-Exe `
  -Name "Google Chrome" `
  -Url  "https://dl.google.com/update2/installers/ChromeSetup.exe" `
  -Args "/silent /install"

Install-Exe `
  -Name "InstaShare" `
  -Url "https://esupportdownload.benq.com/esupport/PUBLIC%20DISPLAY%20PRODUCT/Software/InstaShare/InstaShare_for%20Windows%20(.MSI)_v2.0.0.26_Windows_230330163404.zip"

Install-Exe `
  -Name "InstaShare 2" `
  -Url "https://esupportdownload.benq.com/esupport/INTERACTIVE%20FLAT%20PLAT%20FOR%20EDUCATION/Software/InstaShare%202/InstaShare%202_for%20Windows%20(.MSI)_1.9.5.0_Windows_260205155943.zip"

Install-Exe `
  -Name "Wisenet WAVE" `
  -Url "https://updates.wavevms.com/hanwha/41290/windows/wave-client-6.0.5.41290-windows_x64.exe" `
  -Args "/quiet /norestart"

# ================================
# Winget Fallbacks (Optional)
# ================================

Install-Winget -Id "Microsoft.VisualStudioCode"
Install-Winget -Id "7zip.7zip"

Write-Host "Setup complete!" -ForegroundColor Green
Stop-Transcript