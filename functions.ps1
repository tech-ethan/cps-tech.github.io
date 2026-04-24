# ================================
# Installer Hub – Shared Functions
# ================================

Write-Host "FUNCTIONS VERSION: 04.22.0.1" -ForegroundColor Magenta

function Assert-Administrator {
    $identity  = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($identity)

    if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Write-Error "This script must be run as Administrator."
        exit 1
    }
}


# Global install results (per run)
$Script:InstallResults = @{
    Computer   = $env:COMPUTERNAME
    Profile    = ""
    StartTime  = Get-Date
    EndTime    = $null
    Status     = "Success"
    Apps       = @()
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

    try {
        # Skip if already installed
        if (Is-Installed -DisplayName $Name) {
            Write-Host "$Name already installed - skipping." -ForegroundColor Yellow
            $Script:InstallResults.Apps += @{
                Name   = $Name
                Result = "Skipped"
            }
            return
        }

        $tempRoot = Join-Path $env:TEMP "InstallerHub"
        New-Item -ItemType Directory -Force -Path $tempRoot | Out-Null

        switch ($Installer.type.ToLower()) {

            # ---------------- EXE ----------------
            "exe" {
                $fileName = Split-Path $Installer.url -Leaf
                $downloadPath = Join-Path $tempRoot $fileName

                Write-Host "Downloading $Name..." -ForegroundColor Cyan
                Invoke-WebRequest -Uri $Installer.url -OutFile $downloadPath -UseBasicParsing

                Write-Host "Installing $Name (EXE)..." -ForegroundColor Green
                Start-Process $downloadPath -ArgumentList $Installer.silentArgs -Wait -NoNewWindow
            }

            # ---------------- MSI ----------------
            "msi" {
                $fileName = Split-Path $Installer.url -Leaf
                $downloadPath = Join-Path $tempRoot $fileName

                Write-Host "Downloading $Name..." -ForegroundColor Cyan
                Invoke-WebRequest -Uri $Installer.url -OutFile $downloadPath -UseBasicParsing

                Write-Host "Installing $Name (MSI)..." -ForegroundColor Green
                Start-Process "msiexec.exe" `
                    -ArgumentList "/i `"$downloadPath`" $($Installer.silentArgs)" `
                    -Wait -NoNewWindow
            }

            # ---------------- ZIP ----------------
            "zip" {
                $fileName = Split-Path $Installer.url -Leaf
                $downloadPath = Join-Path $tempRoot $fileName
                $extractPath = Join-Path $tempRoot ($Name -replace '\s+', '_')

                Write-Host "Downloading $Name..." -ForegroundColor Cyan
                Invoke-WebRequest -Uri $Installer.url -OutFile $downloadPath -UseBasicParsing

                Write-Host "Extracting ZIP for $Name..." -ForegroundColor Cyan
                Expand-Archive -Path $downloadPath -DestinationPath $extractPath -Force

                if ($Installer.innerInstaller -eq "msi") {
                    $msi = Get-ChildItem $extractPath -Filter *.msi -Recurse | Select-Object -First 1
                    if (-not $msi) { throw "No MSI found in ZIP for $Name" }

                    Start-Process "msiexec.exe" `
                        -ArgumentList "/i `"$($msi.FullName)`" $($Installer.silentArgs)" `
                        -Wait -NoNewWindow
                }
                else {
                    $exe = Get-ChildItem $extractPath -Filter *.exe -Recurse | Select-Object -First 1
                    if (-not $exe) { throw "No EXE found in ZIP for $Name" }

                    Start-Process $exe.FullName -ArgumentList $Installer.silentArgs -Wait -NoNewWindow
                }
            }

            # ---------------- WINGET ----------------
            "winget" {
                Write-Host "Installing $Name (winget)..." -ForegroundColor Green

                $winget = Get-Command winget -ErrorAction SilentlyContinue
                if (-not $winget) {
                    throw "winget is not available on this system"
                }

                try {
                    Start-Process $winget.Source `
                        -ArgumentList @(
                            "install",
                            "--id", $Installer.id,
                            "--silent",
                            "--accept-package-agreements",
                            "--accept-source-agreements",
                            "--scope", "machine"
                        ) `
                        -Wait -NoNewWindow
                }
                catch {
                    if ($Installer.fallback) {
                        Write-Warning "winget failed for $Name - using fallback installer"
                        Install-App -Name $Name -Installer $Installer.fallback
                        return
                    }
                    throw
                }
            }

            default {
                throw "Unknown installer type '$($Installer.type)' for $Name"
            }
        }

        Write-Host "$Name installed successfully." -ForegroundColor Green
        $Script:InstallResults.Apps += @{
            Name   = $Name
            Result = "Installed"
        }
    }
    catch {
        Write-Host "$Name installation FAILED: $_" -ForegroundColor Red
        $Script:InstallResults.Apps += @{
            Name   = $Name
            Result = "Failed"
            Error  = $_.ToString()
        }
        $Script:InstallResults.Status = "Failed"
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
