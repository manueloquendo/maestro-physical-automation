param(
    [string]$AppId = $env:APP_ID,
    [string]$FlowPath = ".maestro\flows"
)

$ErrorActionPreference = "Stop"

if ([string]::IsNullOrWhiteSpace($AppId)) {
    throw "APP_ID is required. Pass -AppId or set the APP_ID environment variable."
}

if (-not (Get-Command maestro -ErrorAction SilentlyContinue)) {
    # New terminal sessions may not have picked up the PATH change from the installer yet.
    $env:Path = [Environment]::GetEnvironmentVariable("Path", "User") + ";" + [Environment]::GetEnvironmentVariable("Path", "Machine")
}

if (-not (Get-Command maestro -ErrorAction SilentlyContinue)) {
    throw "Maestro CLI was not found in PATH. Install Maestro before running tests."
}

. "$PSScriptRoot\check-android-device.ps1"

if (Test-Path ".env") {
    Get-Content ".env" | ForEach-Object {
        if ($_ -match '^\s*([^#=]+)=(.*)$') {
            [Environment]::SetEnvironmentVariable($Matches[1].Trim(), $Matches[2].Trim(), "Process")
        }
    }
}

if ([string]::IsNullOrWhiteSpace($env:TEST_USER_PASSWORD)) {
    throw "TEST_USER_PASSWORD is required. Set it in .env (see .env.example)."
}

$env:APP_ID = $AppId
$reportDir = "reports\maestro"
$debugDir = "reports\maestro\debug"
if (Test-Path $debugDir) {
    Remove-Item $debugDir -Recurse -Force
}
New-Item -ItemType Directory -Force -Path $reportDir | Out-Null

Write-Host "Running Maestro flows at '$FlowPath' for APP_ID '$AppId'."
$configArgs = @()
if ((Test-Path ".maestro\config.yaml") -and ((Get-Item $FlowPath).PSIsContainer)) {
    $configArgs = @("--config", ".maestro\config.yaml")
}
maestro test $FlowPath @configArgs -e APP_ID=$AppId -e TEST_USER_PASSWORD=$env:TEST_USER_PASSWORD --format junit --output "$reportDir\junit.xml" --debug-output $debugDir
