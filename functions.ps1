# ================================
# Installer Hub – Shared Functions
# ================================

Write-Host "FUNCTIONS VERSION: 2026-04-15 CLEAN BUILD" -ForegroundColor Magenta

function Assert-Administrator {
    $identity  = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($identity)

    if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Write-Error "This script must be run as Administrator."
        exit 1
    }
}

function Is-Installed {
    param (
        [Parameter(Mandatory)]
        [string]$DisplayName
    )

    $paths = @(
        "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*",
        "HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
    )

    foreach ($path in $paths) {
        Get-ItemProperty $path -ErrorAction SilentlyContinue | ForEach-Object {
            if ($_.DisplayName -and $_.DisplayName -like "*$DisplayName*") {
                return $true
            }
        }
    }

    return $false
}

function Install-App {
    param (
        [Parameter(Mandatory)]
        [string]$Name,

        [Parameter(Mandatory)]
        [hashtable]$Installer
    )

    if (Is-Installed -DisplayName $Name) {
        Write-Host "$Name is already installed — skipping." -ForegroundColor Yellow
        return
    }

    $tempRoot = Join-Path $env:TEMP "InstallerHub"
    New-Item -ItemType Directory -Force -Path $tempRoot | Out-Null

    $fileName = Split-Path $Installer.url -Leaf
    $downloadPath = Join-Path $tempRoot $fileName

    Write-Host "Downloading $Name..." -ForegroundColor Cyan
    Invoke-WebRequest -Uri $Installer.url -OutFile $downloadPath -UseBasicParsing

    switch ($Installer.type.ToLower()) {

        "exe" {
            Write-Host "Installing $Name (EXE)..." -ForegroundColor Green
            Start-Process $downloadPath -ArgumentList $Installer.silentArgs -Wait -NoNewWindow
        }

        "msi" {
            Write-Host "Installing $Name (MSI)..." -ForegroundColor Green
            Start-Process "msiexec.exe" `
                -ArgumentList "/i `"$downloadPath`" $($Installer.silentArgs)" `
                -Wait -NoNewWindow
        }

        "zip" {
            Write-Host "Extracting ZIP for $Name..." -ForegroundColor Cyan

            $extractPath = Join-Path $tempRoot ($Name -replace '\s+', '_')
            Expand-Archive -Path $downloadPath -DestinationPath $extractPath -Force

            if ($Installer.innerInstaller -eq "msi") {
                $msi = Get-ChildItem $extractPath -Filter *.msi -Recurse | Select-Object -First 1
                if (-not $msi) { throw "No MSI found in ZIP for $Name" }

                Write-Host "Installing $Name (ZIP → MSI)..." -ForegroundColor Green
                Start-Process "msiexec.exe" `
                    -ArgumentList "/i `"$($msi.FullName)`" $($Installer.silentArgs)" `
                    -Wait -NoNewWindow
            }
            else {
                $exe = Get-ChildItem $extractPath -Filter *.exe -Recurse | Select-Object -First 1
                if (-not $exe) { throw "No EXE found in ZIP for $Name" }

                Write-Host "Installing $Name (ZIP → EXE)..." -ForegroundColor Green
                Start-Process $exe.FullName -ArgumentList $Installer.silentArgs -Wait -NoNewWindow
            }
        }

        default {
            throw "Unknown installer type '$($Installer.type)' for $Name"
        }
    }
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
        Write-Host "Winget not available.. skipping $Id" -ForegroundColor Yellow
    }
}
