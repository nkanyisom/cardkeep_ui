@echo off
REM Production Build Script for CardKeep (Windows)

echo 🏗️  CardKeep - Production Build
echo =================================

REM Check if Flutter is installed
where flutter >nul 2>nul
if %errorlevel% neq 0 (
    echo ❌ Flutter is not installed or not in PATH
    echo Please install Flutter and add it to your PATH
    exit /b 1
)

REM Check Flutter doctor
echo 🔍 Checking Flutter installation...
flutter doctor -v

REM Clean previous builds
echo 🧹 Cleaning previous builds...
flutter clean

REM Get dependencies
echo 📦 Installing dependencies...
flutter pub get

REM Run code generation (for Hive)
echo ⚙️  Running code generation...
flutter packages pub run build_runner build --delete-conflicting-outputs

REM Run tests
echo 🧪 Running tests...
flutter test

REM Build for web with production settings
echo 🌐 Building for web (production)...
flutter build web ^
    --release ^
    --web-renderer canvaskit ^
    --base-href "/" ^
    --dart-define=FLUTTER_APP_ENVIRONMENT=production ^
    --dart-define=FLUTTER_APP_API_BASE_URL_PROD=%PROD_API_URL% ^
    --dart-define=FIREBASE_API_KEY=%FIREBASE_API_KEY% ^
    --dart-define=FIREBASE_AUTH_DOMAIN=%FIREBASE_AUTH_DOMAIN% ^
    --dart-define=FIREBASE_PROJECT_ID=%FIREBASE_PROJECT_ID% ^
    --dart-define=FIREBASE_STORAGE_BUCKET=%FIREBASE_STORAGE_BUCKET% ^
    --dart-define=FIREBASE_MESSAGING_SENDER_ID=%FIREBASE_MESSAGING_SENDER_ID% ^
    --dart-define=FIREBASE_APP_ID=%FIREBASE_APP_ID% ^
    --dart-define=FIREBASE_MEASUREMENT_ID=%FIREBASE_MEASUREMENT_ID%

REM Verify build output
if not exist "build\web" (
    echo ❌ Build failed! build\web directory not found.
    exit /b 1
)

echo ✅ Build completed successfully!

REM List build contents
echo 📁 Build contents:
dir build\web\

echo 🎉 Production build ready for deployment!
echo Build location: build\web\
echo.
echo Next steps:
echo 1. Test the build locally: serve build\web\
echo 2. Deploy using: deploy.bat
echo 3. Monitor your deployed application

pause
