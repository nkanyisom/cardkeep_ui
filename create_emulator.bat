@echo off
echo Creating minimal Android emulator...
echo.

REM Set Android SDK path (adjust if needed)
set ANDROID_SDK_ROOT=C:\Users\%USERNAME%\AppData\Local\Android\Sdk
set PATH=%ANDROID_SDK_ROOT%\cmdline-tools\latest\bin;%ANDROID_SDK_ROOT%\emulator;%PATH%

echo Checking SDK setup...
if not exist "%ANDROID_SDK_ROOT%\cmdline-tools\latest\bin\avdmanager.bat" (
    echo ERROR: Android SDK cmdline-tools not found!
    echo Please install cmdline-tools via Android Studio SDK Manager
    echo Tools ^> SDK Manager ^> SDK Tools ^> Android SDK Command-line Tools
    pause
    exit /b 1
)

echo Creating emulator with minimal settings...
avdmanager create avd ^
    --force ^
    --name "CardKeep_Minimal" ^
    --package "system-images;android-30;google_apis;x86_64" ^
    --tag "google_apis" ^
    --abi "x86_64"

echo.
echo Emulator created! Starting...
emulator -avd CardKeep_Minimal -no-audio -no-boot-anim -memory 2048 -cores 2

pause
