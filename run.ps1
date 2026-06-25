# Flutter Flashlight App - Auto Run Script
# Simple and direct - launch emulator and run app

Write-Host "Flashlight App - Auto Run" -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan

# Step 1: Get dependencies
Write-Host "`nStep 1: Getting dependencies..." -ForegroundColor Yellow
flutter pub get

if ($LASTEXITCODE -ne 0) {
    Write-Host "Dependency installation failed!" -ForegroundColor Red
    exit 1
}

# Step 2: Check for a supported Android device/emulator
Write-Host "`nStep 2: Checking for supported Android device/emulator..." -ForegroundColor Yellow

function Get-SupportedAndroidDevice {
    $devicesJson = flutter devices --machine 2>$null
    if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($devicesJson)) {
        return $null
    }

    $devices = $devicesJson | ConvertFrom-Json
    return @($devices | Where-Object {
        $_.isSupported -eq $true -and $_.targetPlatform -like "android-*"
    } | Select-Object -First 1)[0]
}

$androidDevice = Get-SupportedAndroidDevice

if ($null -eq $androidDevice) {
    $preferredEmulatorId = "Nexus_6_x86_64"
    Write-Host "No supported Android device found. Launching $preferredEmulatorId..." -ForegroundColor Cyan

    $emulators = flutter emulators 2>&1 | Out-String

    if ($emulators -notmatch [regex]::Escape($preferredEmulatorId)) {
        Write-Host "Supported emulator '$preferredEmulatorId' was not found." -ForegroundColor Red
        Write-Host "Available emulators:" -ForegroundColor Yellow
        Write-Host $emulators
        exit 1
    }

    flutter emulators --launch $preferredEmulatorId

    Write-Host "Waiting for supported emulator to boot..." -ForegroundColor Yellow
    for ($i = 0; $i -lt 18; $i++) {
        Start-Sleep -Seconds 5
        $androidDevice = Get-SupportedAndroidDevice
        if ($null -ne $androidDevice) {
            break
        }
    }
}

if ($null -eq $androidDevice) {
    Write-Host "No supported Android device became available." -ForegroundColor Red
    flutter devices
    exit 1
}

Write-Host "Using device: $($androidDevice.name) ($($androidDevice.id), $($androidDevice.targetPlatform))" -ForegroundColor Green

# Step 3: Run the app
Write-Host "`nStep 3: Running Flashlight app..." -ForegroundColor Green
Write-Host "================================`n" -ForegroundColor Cyan

flutter run -d $androidDevice.id

if ($LASTEXITCODE -eq 0) {
    Write-Host "`nApp running successfully!" -ForegroundColor Green
} else {
    Write-Host "`nApp failed!" -ForegroundColor Red
}
