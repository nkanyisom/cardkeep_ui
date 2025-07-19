#!/bin/bash
set -e  # Exit on any error

# Build script for Render deployment
echo "🏗️ Building CardKeep for Render..."

# Set Flutter paths
FLUTTER_HOME="$HOME/flutter"
FLUTTER_BIN="$FLUTTER_HOME/bin/flutter"

# Install Flutter if not available
if [ ! -f "$FLUTTER_BIN" ]; then
    echo "📥 Installing Flutter..."
    
    # Remove existing flutter directory if it exists
    rm -rf "$FLUTTER_HOME"
    
    # Clone Flutter
    git clone https://github.com/flutter/flutter.git -b stable "$FLUTTER_HOME"
    
    # Verify Flutter installation
    echo "🔍 Verifying Flutter installation..."
    "$FLUTTER_BIN" --version
    
    # Enable web support
    "$FLUTTER_BIN" config --enable-web
    
    # Pre-cache dependencies
    "$FLUTTER_BIN" precache --web
    
else
    echo "✅ Flutter is already available"
    "$FLUTTER_BIN" --version
fi

# Clean and build using absolute paths
echo "🧹 Cleaning previous build..."
"$FLUTTER_BIN" clean

echo "📦 Getting dependencies..."
"$FLUTTER_BIN" pub get

echo "🌐 Building web application..."
"$FLUTTER_BIN" build web \
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
