@echo off
echo Flutter Loyalty Card App Setup Script
echo =======================================
echo.

REM Check if Flutter is installed
flutter --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Flutter is not installed or not in PATH
    echo.
    echo Please install Flutter first:
    echo 1. Visit https://flutter.dev/docs/get-started/install/windows
    echo 2. Download Flutter SDK
    echo 3. Add Flutter to your PATH
    echo 4. Run this script again
    echo.
    pause
    exit /b 1
)

echo Flutter detected! Checking Flutter doctor...
flutter doctor

echo.
echo Installing dependencies...
flutter pub get

if %errorlevel% neq 0 (
    echo ERROR: Failed to install dependencies
    pause
    exit /b 1
)

echo.
echo =======================================
echo Setup completed successfully!
echo.
echo Next steps:
echo 1. Set up Firebase configuration files:
echo    - Add google-services.json to android/app/
echo    - Add GoogleService-Info.plist to ios/Runner/
echo 2. Ensure your Spring Boot backend is running
echo 3. Run: flutter run
echo.
pause
