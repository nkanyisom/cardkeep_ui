#!/bin/bash
set -e  # Exit on any error

# Build script for Render deployment
echo "🏗️ Building CardKeep for Render..."

# Install Flutter if not available
if ! command -v flutter &> /dev/null; then
    echo "📥 Installing Flutter..."
    
    # Remove existing flutter directory if it exists
    rm -rf ~/flutter
    
    # Clone Flutter
    git clone https://github.com/flutter/flutter.git -b stable ~/flutter
    
    # Add Flutter to PATH for this session
    export PATH="$HOME/flutter/bin:$PATH"
    
    # Verify Flutter installation
    echo "🔍 Verifying Flutter installation..."
    ~/flutter/bin/flutter --version
    
    # Enable web support
    ~/flutter/bin/flutter config --enable-web
    
    # Pre-cache dependencies
    ~/flutter/bin/flutter precache --web
    
else
    echo "✅ Flutter is already available"
    flutter --version
fi

# Ensure Flutter is in PATH
export PATH="$HOME/flutter/bin:$PATH"

# Clean and build
echo "🧹 Cleaning previous build..."
flutter clean

echo "📦 Getting dependencies..."
flutter pub get

echo "🌐 Building web application..."
flutter build web \
    --release \
    --web-renderer canvaskit \
    --dart-define=FLUTTER_APP_ENVIRONMENT=production \
    --dart-define=FLUTTER_APP_API_BASE_URL_PROD="$FLUTTER_APP_API_BASE_URL_PROD" \
    --dart-define=FIREBASE_API_KEY="$FIREBASE_API_KEY" \
    --dart-define=FIREBASE_AUTH_DOMAIN="$FIREBASE_AUTH_DOMAIN" \
    --dart-define=FIREBASE_PROJECT_ID="$FIREBASE_PROJECT_ID" \
    --dart-define=FIREBASE_STORAGE_BUCKET="$FIREBASE_STORAGE_BUCKET" \
    --dart-define=FIREBASE_MESSAGING_SENDER_ID="$FIREBASE_MESSAGING_SENDER_ID" \
    --dart-define=FIREBASE_APP_ID="$FIREBASE_APP_ID"

echo "✅ Build completed successfully!"
echo "📊 Build size: $(du -sh build/web | cut -f1)"

# Verify build
if [ ! -d "build/web" ]; then
    echo "❌ Build failed - no output directory found"
    exit 1
fi

echo "🎉 CardKeep is ready for deployment!"
