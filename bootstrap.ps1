# ================================
# Installer Hub Bootstrap Script
# ================================

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force

$BaseUrl = "https://tech-ethan.github.io/cps-tech.github.io"
$TempDir = "$env:TEMP\InstallerHub"
$MainScript = "$TempDir\setup-standard.ps1"

New-Item -ItemType Directory -Force -Path $TempDir | Out-Null

Write-Host "Downloading setup script..." -ForegroundColor Cyan
Invoke-WebRequest "$BaseUrl/setup-standard.ps1" -OutFile $MainScript -UseBasicParsing

Write-Host "Launching installer hub setup..." -ForegroundColor Green
& $MainScript
