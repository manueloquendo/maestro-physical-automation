param(
    [string]$RemoteUrl
)

$ErrorActionPreference = "Stop"

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    throw "git was not found in PATH. Install Git for Windows before continuing."
}

if (-not (Test-Path ".git")) {
    git init
}

git add .
git status --short

Write-Host "Review the files above before committing."
Write-Host "When ready, run: git commit -m 'Initial Maestro Android USB automation project'"

if (-not [string]::IsNullOrWhiteSpace($RemoteUrl)) {
    Write-Host "Then run these commands to push:"
    Write-Host "git branch -M main"
    Write-Host "git remote add origin $RemoteUrl"
    Write-Host "git push -u origin main"
}
