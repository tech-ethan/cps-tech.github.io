Start-Transcript -Path "C:\SetupLogs\InstallerHub-Classroom.log" -Append

. "$PSScriptRoot\functions.ps1"
Assert-Administrator

Write-Host "Starting CLASSROOM / PANEL setup..." -ForegroundColor Cyan

# --- Casting Software ---
Install-Exe `
  -Name "InstaShare" `
  -Url "https://esupportdownload.benq.com/esupport/PUBLIC%20DISPLAY%20PRODUCT/Software/InstaShare/InstaShare_for%20Windows%20(.MSI)_v2.0.0.26_Windows_230330163404.zip"

Install-Exe `
  -Name "InstaShare 2" `
  -Url "https://esupportdownload.benq.com/esupport/INTERACTIVE%20FLAT%20PLAT%20FOR%20EDUCATION/Software/InstaShare%202/InstaShare%202_for%20Windows%20(.MSI)_1.9.5.0_Windows_260205155943.zip"

# --- Browser ---
Install-Exe `
  -Name "Google Chrome" `
  -Url "https://dl.google.com/update2/installers/ChromeSetup.exe" `
  -Args "/silent /install"

Write-Host "Classroom setup complete." -ForegroundColor Green

Stop-Transcript
