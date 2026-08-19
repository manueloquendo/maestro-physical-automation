param(
    [string]$InstallDir = "C:\maestro"
)

$ErrorActionPreference = "Stop"
# Rendering the download progress bar in the integrated terminal makes Invoke-WebRequest extremely slow.
$ProgressPreference = "SilentlyContinue"

if (-not (Get-Command java -ErrorAction SilentlyContinue)) {
    throw "Java 17+ is required before installing Maestro. Install Java and retry."
}

Write-Host "Fetching latest Maestro release metadata..."
$release = Invoke-RestMethod -Uri "https://api.github.com/repos/mobile-dev-inc/Maestro/releases/latest" -TimeoutSec 30
$asset = $release.assets | Where-Object { $_.name -eq "maestro.zip" } | Select-Object -First 1

if (-not $asset) {
    throw "Could not find maestro.zip in the latest Maestro release."
}

$tempZip = Join-Path $env:TEMP "maestro-$([guid]::NewGuid().ToString('N')).zip"
Write-Host "Downloading $($asset.browser_download_url) ($([math]::Round($asset.size / 1MB, 1)) MB)..."
Invoke-WebRequest -Uri $asset.browser_download_url -OutFile $tempZip -TimeoutSec 300
Write-Host "Download complete."

if (Test-Path $InstallDir) {
    Remove-Item $InstallDir -Recurse -Force
}

New-Item -ItemType Directory -Force -Path $InstallDir | Out-Null
Expand-Archive -Path $tempZip -DestinationPath $InstallDir -Force
Remove-Item $tempZip -Force -ErrorAction SilentlyContinue

# The release zip contains a top-level "maestro" folder, so bin lives one level deeper.
$binPath = Join-Path $InstallDir "maestro\bin"
if (-not (Test-Path $binPath)) {
    $binPath = Join-Path $InstallDir "bin"
}
$currentPath = [Environment]::GetEnvironmentVariable("Path", "User")
if ($currentPath -notlike "*$binPath*") {
    [Environment]::SetEnvironmentVariable("Path", "$currentPath;$binPath", "User")
    Write-Host "Added $binPath to the user PATH. Open a new terminal before running maestro."
}

Write-Host "Maestro installed at $InstallDir."
Write-Host "Open a new terminal and run: maestro --help"
