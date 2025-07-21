@echo off
echo 🔧 Creating Software-Only Android Emulator for Camera Testing...
echo.

REM Navigate to Android SDK
cd /d "C:\Users\%USERNAME%\AppData\Local\Android\Sdk"

REM Check if SDK exists
if not exist "cmdline-tools\latest\bin\avdmanager.bat" (
    echo ❌ Android SDK cmdline-tools not found!
    echo.
    echo Please install via Android Studio:
    echo 1. Open Android Studio
    echo 2. File ^> Settings ^> System Settings ^> Android SDK
    echo 3. SDK Tools tab ^> Check "Android SDK Command-line Tools"
    echo 4. Apply and wait for installation
    echo.
    pause
    exit /b 1
)

echo 📱 Creating emulator with software rendering...
cmdline-tools\latest\bin\avdmanager.bat create avd ^
    --force ^
    --name "CardKeep_Software_Cam" ^
    --package "system-images;android-30;google_apis;x86" ^
    --tag "google_apis" ^
    --abi "x86" ^
    --device "pixel_6"

echo.
echo 🚀 Starting emulator with camera support...
emulator\emulator.exe -avd CardKeep_Software_Cam ^
    -no-snapshot-save ^
    -no-snapshot-load ^
    -camera-back webcam0 ^
    -camera-front webcam0 ^
    -gpu swiftshader_indirect ^
    -memory 3072 ^
    -cores 2

echo.
echo ✅ Emulator should be starting...
pause
