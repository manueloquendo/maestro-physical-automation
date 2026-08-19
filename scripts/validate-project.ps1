$ErrorActionPreference = "Stop"

$requiredFiles = @(
    "README.md",
    ".env.example",
    ".github/workflows/maestro-android-usb.yml",
    ".maestro/scripts/test-data.js",
    "docs/INSTALLATION.md",
    "docs/GITHUB_ACTIONS_SELF_HOSTED_RUNNER.md",
    "docs/TEST_CASES.md",
    "scripts/check-android-device.ps1",
    "scripts/init-github-repo.ps1",
    "scripts/install-maestro-windows.ps1",
    "scripts/run-maestro.ps1"
)

$missingFiles = @()
foreach ($file in $requiredFiles) {
    if (-not (Test-Path $file)) {
        $missingFiles += $file
    }
}

if ($missingFiles.Count -gt 0) {
    throw "Missing required files: $($missingFiles -join ', ')"
}

$flowFiles = Get-ChildItem -Path ".maestro/flows" -Filter "*.yaml" -Recurse
if ($flowFiles.Count -ne 10) {
    throw "Expected 10 Maestro flow files from the shared documentation, found $($flowFiles.Count)."
}

foreach ($flow in $flowFiles) {
    $content = Get-Content $flow.FullName -Raw
    foreach ($requiredToken in @("appId:", "---", "launchApp", "runScript")) {
        if ($content -notmatch [regex]::Escape($requiredToken)) {
            throw "Flow $($flow.FullName) is missing required token '$requiredToken'."
        }
    }
}

Write-Host "Project scaffold validation passed. Flow count: $($flowFiles.Count)."
