# Flutter Installation Checker Script
Write-Host "=== Flutter Installation Checker ===" -ForegroundColor Cyan
Write-Host ""

# Check common Flutter locations
$possiblePaths = @(
    "D:\flutter\bin",
    "D:\flutter_windows_3.24.0-stable\bin",
    "D:\flutter_windows_3.22.0-stable\bin",
    "D:\flutter_windows_3.20.0-stable\bin",
    "C:\src\flutter\bin",
    "C:\flutter\bin"
)

Write-Host "Checking common Flutter locations..." -ForegroundColor Yellow
$found = $false

foreach ($path in $possiblePaths) {
    $flutterBat = Join-Path $path "flutter.bat"
    if (Test-Path $flutterBat) {
        Write-Host "Found Flutter at: $path" -ForegroundColor Green
        Write-Host "  Full path: $flutterBat" -ForegroundColor Gray
        $found = $true
        
        # Try to run it
        Write-Host ""
        Write-Host "Testing Flutter..." -ForegroundColor Yellow
        try {
            $version = & $flutterBat --version 2>&1
            Write-Host "Flutter works! Version:" -ForegroundColor Green
            $version | Select-Object -First 3
        } catch {
            Write-Host "Error running Flutter: $_" -ForegroundColor Red
        }
        break
    }
}

if (-not $found) {
    Write-Host "Flutter not found in common locations" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please check:" -ForegroundColor Yellow
    Write-Host "1. Where did you extract the Flutter ZIP file?"
    Write-Host "2. What is the exact path to the bin folder?"
    Write-Host ""
    Write-Host "You can manually check by running:" -ForegroundColor Cyan
    Write-Host "  Test-Path 'D:\YOUR_FLUTTER_FOLDER\bin\flutter.bat'"
}

Write-Host ""
Write-Host "=== Checking PATH ===" -ForegroundColor Cyan
$pathEntries = $env:PATH -split ';' | Where-Object { $_ -like '*flutter*' }
if ($pathEntries) {
    Write-Host "Found Flutter in PATH:" -ForegroundColor Green
    $pathEntries | ForEach-Object { Write-Host "  $_" -ForegroundColor Gray }
} else {
    Write-Host "Flutter not found in PATH" -ForegroundColor Red
    Write-Host ""
    Write-Host "To add Flutter to PATH:" -ForegroundColor Yellow
    Write-Host "1. Press Win+R, type: sysdm.cpl"
    Write-Host "2. Go to Advanced -> Environment Variables"
    Write-Host "3. Edit PATH, add: D:\flutter\bin (or your Flutter bin path)"
    Write-Host "4. Close ALL terminal windows and open a new one"
}

Write-Host ""
Write-Host "=== Quick Fix (Temporary) ===" -ForegroundColor Cyan
Write-Host "If Flutter is found but not in PATH, you can use it directly with full path"
Write-Host "Or add to PATH for this session only:"
Write-Host "  `$env:PATH += ';D:\flutter\bin'"
Write-Host "  flutter --version"
