param(
    [switch]$Open
)

$ErrorActionPreference = "Stop"

if (-not (Get-Command allure -ErrorAction SilentlyContinue)) {
    Write-Host "Allure commandline not found. Installing via npm..."
    npm install -g allure-commandline
    $env:Path = [Environment]::GetEnvironmentVariable("Path", "User") + ";" + [Environment]::GetEnvironmentVariable("Path", "Machine")
}

if (-not (Get-Command allure -ErrorAction SilentlyContinue)) {
    throw "Allure commandline still not found in PATH after install. Open a new terminal and retry."
}

if (-not (Get-Command node -ErrorAction SilentlyContinue)) {
    throw "Node.js is required to convert Maestro results into Allure format."
}

node scripts/generate-allure-results.js "reports/maestro/junit.xml" "reports/maestro/debug/.maestro/tests" "allure-results"

allure generate allure-results --clean -o allure-report

if ($Open) {
    allure open allure-report
}
else {
    Write-Host "Allure report generated at allure-report. Run 'allure open allure-report' to view it."
}
