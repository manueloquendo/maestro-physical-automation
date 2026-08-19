param(
    [string]$InstallDir = "C:\maestro"
)

$ErrorActionPreference = "Stop"

if (-not (Get-Command java -ErrorAction SilentlyContinue)) {
    throw "Java 17+ is required before installing Maestro. Install Java and retry."
}

$release = Invoke-RestMethod -Uri "https://api.github.com/repos/mobile-dev-inc/Maestro/releases/latest"
$asset = $release.assets | Where-Object { $_.name -eq "maestro.zip" } | Select-Object -First 1

if (-not $asset) {
    throw "Could not find maestro.zip in the latest Maestro release."
}

$tempZip = Join-Path $env:TEMP "maestro.zip"
Invoke-WebRequest -Uri $asset.browser_download_url -OutFile $tempZip

if (Test-Path $InstallDir) {
    Remove-Item $InstallDir -Recurse -Force
}

New-Item -ItemType Directory -Force -Path $InstallDir | Out-Null
Expand-Archive -Path $tempZip -DestinationPath $InstallDir -Force

$binPath = Join-Path $InstallDir "bin"
$currentPath = [Environment]::GetEnvironmentVariable("Path", "User")
if ($currentPath -notlike "*$binPath*") {
    [Environment]::SetEnvironmentVariable("Path", "$currentPath;$binPath", "User")
    Write-Host "Added $binPath to the user PATH. Open a new terminal before running maestro."
}

Write-Host "Maestro installed at $InstallDir."
Write-Host "Open a new terminal and run: maestro --help"
