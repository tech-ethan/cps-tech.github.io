# ================================
# Installer Hub Bootstrap Script
# Root-level repo layout
# ================================

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force

$BaseUrl  = "https://tech-ethan.github.io/cps-tech.github.io"
$TempDir = "$env:TEMP\InstallerHub"

New-Item -ItemType Directory -Force -Path $TempDir | Out-Null

Write-Host "Downloading Installer Hub scripts..." -ForegroundColor Cyan

Invoke-RestMethod "$BaseUrl/functions.ps1" `
  -OutFile "$TempDir\functions.ps1"

Invoke-RestMethod "$BaseUrl/setup-standard.ps1" `
  -OutFile "$TempDir\setup-standard.ps1"

Write-Host "Launching installer hub setup..." -ForegroundColor Green

powershell -ExecutionPolicy Bypass -File "$TempDir\setup-standard.ps1"
