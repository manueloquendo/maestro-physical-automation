param(
    [string]$AppId = $env:APP_ID,
    [string]$FlowPath = ".maestro\flows"
)

$ErrorActionPreference = "Stop"

if ([string]::IsNullOrWhiteSpace($AppId)) {
    throw "APP_ID is required. Pass -AppId or set the APP_ID environment variable."
}

if (-not (Get-Command maestro -ErrorAction SilentlyContinue)) {
    throw "Maestro CLI was not found in PATH. Install Maestro before running tests."
}

. "$PSScriptRoot\check-android-device.ps1"

$env:APP_ID = $AppId
$reportDir = "reports\maestro"
New-Item -ItemType Directory -Force -Path $reportDir | Out-Null

Write-Host "Running Maestro flows at '$FlowPath' for APP_ID '$AppId'."
maestro test $FlowPath --format junit --output "$reportDir\junit.xml"
