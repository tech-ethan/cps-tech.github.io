# ================================
# Shared Utility Functions
# ================================

function Assert-Administrator {
    $id = [Security.Principal.WindowsIdentity]::GetCurrent()
    $p = New-Object Security.Principal.WindowsPrincipal($id)
    if (-not $p.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Write-Error "This script must be run as Administrator"
        exit 1
    }
}

function Is-Installed($DisplayName) {
    Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*,
                     HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* `
        -ErrorAction SilentlyContinue |
        Where-Object { $_.DisplayName -like "*$DisplayName*" }
}

function Install-Exe {
    param(
        [string]$Name,
        [string]$Url,
        [string]$Args = ""
    )

    if (Is-Installed $Name) {
        Write-Host "$Name is already installed — skipping" -ForegroundColor Yellow
        return
    }

    $file = "$env:TEMP\$Name.exe"

    Write-Host "Downloading $Name..."
    Invoke-WebRequest $Url -OutFile $file -UseBasicParsing

    Write-Host "Installing $Name..."
    Start-Process $file -ArgumentList $Args -Wait
}

function Install-Winget {
    param([string]$Id)

    if (Get-Command winget -ErrorAction SilentlyContinue) {
        winget install --id $Id --silent --accept-package-agreements --accept-source-agreements
    }
}