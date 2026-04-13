# ================================
# Installer Hub - Shared Functions
# ================================

Set-StrictMode -Version Latest

function Assert-Administrator {
    $identity  = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($identity)

    if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Write-Error "This script must be run as Administrator."
        exit 1
    }
}

function Is-Installed {
    param ([string]$DisplayName)

    foreach ($key in Get-ItemProperty `
        HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*, `
        HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* `
        -ErrorAction SilentlyContinue) {

        if ($key.PSObject.Properties['DisplayName'] -and
            $key.DisplayName -like "*$DisplayName*") {
            return $true
        }
    }

    return $false
}

function Install-Exe {
    param (
        [Parameter(Mandatory)]
        [string]$Name,

        [Parameter(Mandatory)]
        [string]$Url,

        [string]$Args = ""
    )

    if (Is-Installed $Name) {
    Write-Host "$Name is already installed — skipping." -ForegroundColor Yellow
    return
}

    $file = Join-Path $env:TEMP ($Name -replace '\s','_') + ".exe"

    Write-Host "Downloading $Name..." -ForegroundColor Cyan
    Invoke-WebRequest -Uri $Url -OutFile $file -UseBasicParsing

    Write-Host "Installing $Name..." -ForegroundColor Green
    Start-Process -FilePath $file -ArgumentList $Args -Wait -NoNewWindow
}

function Install-Winget {
    param (
        [Parameter(Mandatory)]
        [string]$Id
    )

    if (Get-Command winget -ErrorAction SilentlyContinue) {
        Write-Host "Installing $Id via winget..." -ForegroundColor Cyan
        Start-Process winget `
            -ArgumentList "install --id $Id --silent --accept-package-agreements --accept-source-agreements" `
            -Wait `
            -NoNewWindow
    }
    else {
        Write-Host "Winget not available — skipping $Id" -ForegroundColor Yellow
    }
}
