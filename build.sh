#!/bin/bash

# Build script for Render deployment
echo "🏗️ Building CardKeep for Render..."

# Install Flutter if not available
if ! command -v flutter &> /dev/null; then
    echo "📥 Installing Flutter..."
    git clone https://github.com/flutter/flutter.git -b stable ~/flutter
    export PATH="$PATH:~/flutter/bin"
    flutter config --enable-web
fi

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
