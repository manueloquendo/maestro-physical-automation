$ErrorActionPreference = "Stop"

if (-not (Get-Command adb -ErrorAction SilentlyContinue)) {
    throw "adb was not found in PATH. Install Android SDK Platform Tools and add platform-tools to PATH."
}

$devices = adb devices | Select-Object -Skip 1 | Where-Object { $_ -match "\S+\s+device$" }
if (-not $devices) {
    adb devices
    throw "No authorized Android USB device was found. Enable USB Debugging and accept the RSA prompt on the device."
}

Write-Host "Authorized Android device(s):"
$devices | ForEach-Object { Write-Host " - $_" }
