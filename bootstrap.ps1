# =========================================
# Installer Hub Bootstrap Script
# =========================================


# ================================
# --- Security / compatibility ---
# ================================
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force


# ================================
# Prepare logging directory
# ================================
$LogDir = "C:\SetupLogs"

if (-not (Test-Path $LogDir)) {
    try {
        New-Item -ItemType Directory -Path $LogDir -Force | Out-Null
        Write-Host "Created log directory: $LogDir" -ForegroundColor Green
    }
    catch {
        Write-Warning "Failed to create log directory: $LogDir"
        Write-Warning $_
    }
}
else {
    Write-Host "Log directory already exists: $LogDir"
}


# --- Repo base URL (GitHub Pages root) ---
$BaseUrl  = "https://tech-ethan.github.io/cps-tech.github.io"
$TempDir = "$env:TEMP\InstallerHub"

# --- Determine profile ---
$Profile = $env:INSTALLER_PROFILE
if (-not $Profile) {
    $Profile = "standard"
}

$env:INSTALLER_UPLOAD = "true"

Write-Host "Installer Hub bootstrap starting..." -ForegroundColor Cyan
Write-Host "Selected profile: $Profile" -ForegroundColor Green

# --- Prepare temp workspace ---
if (Test-Path $TempDir) {
    Remove-Item $TempDir -Recurse -Force -ErrorAction SilentlyContinue
}
New-Item -ItemType Directory -Path $TempDir | Out-Null

# --- Download shared + profile scripts ---
Write-Host "Downloading scripts..." -ForegroundColor Cyan

Invoke-RestMethod "$BaseUrl/functions.ps1" `
    -OutFile "$TempDir\functions.ps1"

Invoke-RestMethod "$BaseUrl/setup-standard.ps1" `
    -OutFile "$TempDir\setup-standard.ps1"

Invoke-RestMethod "$BaseUrl/setup-admin.ps1" `
    -OutFile "$TempDir\setup-admin.ps1"

Invoke-RestMethod "$BaseUrl/setup-classroom.ps1" `
    -OutFile "$TempDir\setup-classroom.ps1"

Invoke-RestMethod "$BaseUrl/setup-testing.ps1" `
    -OutFile "$TempDir\setup-testing.ps1"

# --- Execute selected profile ---
switch ($Profile.ToLower()) {
    "standard" {
        powershell -ExecutionPolicy Bypass -File "$TempDir\setup-standard.ps1"
    }
    "admin" {
        powershell -ExecutionPolicy Bypass -File "$TempDir\setup-admin.ps1"
    }
    "classroom" {
        powershell -ExecutionPolicy Bypass -File "$TempDir\setup-classroom.ps1"
    }
    "testing" {
        powershell -ExecutionPolicy Bypass -File "$TempDir\setup-testing.ps1"
    }
    default {
        Write-Error "Unknown profile: $Profile"
        exit 1
    }
}

Write-Host "Bootstrap complete." -ForegroundColor Green
