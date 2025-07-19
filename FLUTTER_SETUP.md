# Flutter Setup Instructions

Since Flutter is not currently installed on your system, please follow these steps:

## Install Flutter

### Option 1: Download Flutter SDK
1. Visit https://flutter.dev/docs/get-started/install/windows
2. Download the Flutter SDK
3. Extract to a location like `C:\flutter`
4. Add `C:\flutter\bin` to your PATH environment variable

### Option 2: Use Flutter Version Management (Recommended)
1. Install Git if not already installed
2. Clone Flutter repository:
   ```bash
   git clone https://github.com/flutter/flutter.git -b stable
   ```
3. Add the flutter/bin directory to your PATH

## Verify Installation
```bash
flutter doctor
```

## Project Setup After Flutter Installation

Once Flutter is installed, run these commands in the project directory:

```bash
# Navigate to project directory
cd "d:\Back Up(HP)\side prjz\sto_karata_ui"

# Get dependencies
flutter pub get

# Check for any issues
flutter doctor

# Run the app (after setting up Firebase)
flutter run
```

## Firebase Setup Required

Before running the app, you'll need to:

1. Create a Firebase project at https://console.firebase.google.com
2. Add Android app with package name: `com.example.sto_karata_ui`
3. Download `google-services.json` and place in `android/app/`
4. Add iOS app and download `GoogleService-Info.plist` for `ios/Runner/`

## Backend API

Make sure your Spring Boot backend is running on `http://https://cardkeep-backend.onrender.com` before testing the app.

## Next Steps

1. Install Flutter SDK
2. Run `flutter pub get` in this directory
3. Set up Firebase configuration files
4. Run `flutter run` to start the app
