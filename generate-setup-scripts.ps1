# ==========================================
# Installer Hub – Setup Script Generator
# ==========================================

$ErrorActionPreference = "Stop"

$Root = Split-Path -Parent $MyInvocation.MyCommand.Path

$AppsPath     = Join-Path $Root "apps.json"
$ProfilesPath = Join-Path $Root "profiles.json"

$Apps     = Get-Content $AppsPath -Raw | ConvertFrom-Json
$Profiles = Get-Content $ProfilesPath -Raw | ConvertFrom-Json

$UploadUrl = "https://script.google.com/a/macros/cps.k12.ar.us/s/AKfycbzmzgSuvE6eALABU700n5YNN1r4gCKmllCflkyH4GhkCJwPb0L89iuidQaUYVC9NMelpA/exec"

foreach ($profileProp in $Profiles.PSObject.Properties) {

    $ProfileKey   = $profileProp.Name
    $ProfileValue = $profileProp.Value
    $OutFile      = Join-Path $Root "setup-$ProfileKey.ps1"

    Write-Host "Generating $OutFile" -ForegroundColor Cyan

    $lines = @()

    # ------------------------------------------------------------
    # Header
    # ------------------------------------------------------------
    $lines += "# =========================================="
    $lines += "# AUTO-GENERATED - DO NOT EDIT"
    $lines += "# Profile: $($ProfileValue.name)"
    $lines += "# Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
    $lines += "# =========================================="
    $lines += ""

    # ------------------------------------------------------------
    # Logging directory + transcript
    # ------------------------------------------------------------
    $lines += '$logDir = "C:\SetupLogs"'
    $lines += 'if (-not (Test-Path $logDir)) {'
    $lines += '    New-Item -ItemType Directory -Path $logDir -Force | Out-Null'
    $lines += '}'
    $lines += ""
    $lines += "Start-Transcript -Path `"$logDir\InstallerHub-$ProfileKey.log`" -Append"
    $lines += ""

    # ------------------------------------------------------------
    # Load shared functions & elevation check
    # ------------------------------------------------------------
    $lines += '. "$PSScriptRoot\functions.ps1"'
    $lines += "Assert-Administrator"
    $lines += ""

    # ------------------------------------------------------------
    # Run start banner
    # ------------------------------------------------------------
    $lines += "Write-Host `"Starting $($ProfileValue.name)...`" -ForegroundColor Cyan"
    $lines += ""

    # ------------------------------------------------------------
    # App installs
    # ------------------------------------------------------------
    foreach ($AppId in $ProfileValue.apps) {

        if (-not $Apps.$AppId) {
            Write-Warning "App '$AppId' referenced in profile '$ProfileKey' but not found in apps.json"
            continue
        }

        $App = $Apps.$AppId

        $lines += "# --- $($App.name)"
        $lines += "Install-App -Name `"$($App.name)`" -Installer @{"

        foreach ($prop in $App.installer.PSObject.Properties) {
            $key = $prop.Name
            $val = $prop.Value
            $lines += "    $key = `"$val`""
        }

        $lines += "}"
        $lines += ""
    }

    # ------------------------------------------------------------
    # Finalize summary metadata
    # ------------------------------------------------------------
    $lines += "# ------------------------------------------------------------"
    $lines += "# Finalize summary + write report JSON"
    $lines += "# ------------------------------------------------------------"
    $lines += '$Script:InstallResults.Profile = "' + $ProfileValue.name + '"'
    $lines += '$Script:InstallResults.EndTime = Get-Date'
    $lines += ""

    $lines += '$reportDir = Join-Path $logDir "Reports"'
    $lines += 'New-Item -ItemType Directory -Path $reportDir -Force | Out-Null'
    $lines += ""

    $lines += '$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"'
    $lines += '$reportPath = Join-Path $reportDir "$($env:COMPUTERNAME)-$timestamp.json"'
    $lines += ""

    $lines += '$Script:InstallResults |'
    $lines += '  ConvertTo-Json -Depth 5 |'
    $lines += '  Out-File -Encoding UTF8 $reportPath'
    $lines += ""

    $lines += 'Write-Host "Summary report written to $reportPath" -ForegroundColor Green'
    $lines += ""

    # ------------------------------------------------------------
    # Optional upload (non-blocking)
    # ------------------------------------------------------------
    $lines += 'if ($env:INSTALLER_UPLOAD -eq "true") {'
    $lines += '    try {'
    $lines += '        Invoke-RestMethod'
    $lines += '            -Uri "' + $UploadUrl + '"'
    $lines += '            -Method POST'
    $lines += '            -Body ($Script:InstallResults | ConvertTo-Json -Depth 5)'
    $lines += '            -ContentType "application/json"'
    $lines += ''
    $lines += '        Write-Host "Summary report uploaded successfully."'
    $lines += '    }'
    $lines += '    catch {'
    $lines += '        Write-Warning "Summary upload failed - continuing without blocking."'
    $lines += '    }'
    $lines += '}'
    $lines += ''

    # ------------------------------------------------------------
    # End run
    # ------------------------------------------------------------
    $lines += "Write-Host `"Setup complete.`" -ForegroundColor Green"
    $lines += "Stop-Transcript"

    Set-Content -Path $OutFile -Value $lines -Encoding UTF8
}

Write-Host "All setup scripts generated successfully." -ForegroundColor Cyan