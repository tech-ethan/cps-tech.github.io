Start-Transcript -Path "C:\SetupLogs\InstallerHub-Admin.log" -Append

. "$PSScriptRoot\functions.ps1"
Assert-Administrator

Write-Host "Starting ADMIN workstation setup..." -ForegroundColor Cyan

# --- Browsers ---
Install-Exe `
  -Name "Google Chrome" `
  -Url "https://dl.google.com/update2/installers/ChromeSetup.exe" `
  -Args "/silent /install"

# --- Admin / IT Tools ---
Install-Winget -Id "Rufus.Rufus"
Install-Winget -Id "Sysinternals.SysinternalsSuite"
Install-Winget -Id "WiresharkFoundation.Wireshark"
Install-Winget -Id "PuTTY.PuTTY"
Install-Winget -Id "AntibodySoftware.WizTree"
Install-Winget -Id "PDQ.PDQDeploy"
Install-Winget -Id "PDQ.PDQInventory"


Write-Host "Admin setup complete." -ForegroundColor Green

Stop-Transcript
