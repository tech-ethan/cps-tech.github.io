# ==========================================
# Installer Hub Setup Script Generator
# ==========================================

$ErrorActionPreference = "Stop"

$Root = Split-Path -Parent $MyInvocation.MyCommand.Path

$AppsFile     = Join-Path $Root "apps.json"
$ProfilesFile = Join-Path $Root "profiles.json"

Write-Host "Loading configuration..." -ForegroundColor Cyan

$Apps     = Get-Content $AppsFile -Raw | ConvertFrom-Json
$Profiles = Get-Content $ProfilesFile -Raw | ConvertFrom-Json

foreach ($profile in $Profiles.PSObject.Properties) {

    $profileKey   = $profile.Name
    $profileValue = $profile.Value
    $outputFile   = Join-Path $Root "setup-$profileKey.ps1"

    Write-Host "Generating $outputFile" -ForegroundColor Green

    $lines = @()

    # Header
    $lines += "# =========================================="
    $lines += "# Installer Hub - $($profileValue.name)"
    $lines += "# Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
    $lines += "# =========================================="
    $lines += ""
    $lines += "Start-Transcript -Path `"C:\SetupLogs\InstallerHub-$profileKey.log`" -Append"
    $lines += ""
    $lines += ". `"$PSScriptRoot\functions.ps1`""
    $lines += "Assert-Administrator"
    $lines += ""
    $lines += "Write-Host `"Starting $($profileValue.name)...`" -ForegroundColor Cyan"
    $lines += ""

    foreach ($appId in $profileValue.apps) {

        if (-not $Apps.$appId) {
            Write-Warning "App '$appId' referenced in profile '$profileKey' does not exist in apps.json"
            continue
        }

        $app = $Apps.$appId

        $lines += "# --- $($app.name)"
        $lines += "Install-App `"
        $lines += "  -Name `"$($app.name)`" `"
        $lines += "  -Installer @{"
        
        foreach ($key in $app.installer.PSObject.Properties.Name) {
            $value = $app.installer.$key
            $lines += "    $key = `"$value`""
        }
        
        $lines += "  }"
        $lines += ""
    }

    $lines += "Write-Host `"Setup complete.`" -ForegroundColor Green"
    $lines += "Stop-Transcript"

    Set-Content -Path $outputFile -Value $lines -Encoding UTF8
}

Write-Host "All setup scripts generated successfully." -ForegroundColor Cyan
