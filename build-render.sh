#!/bin/bash
set -e

echo "🏗️ Building CardKeep for Render..."

# Set up environment
FLUTTER_HOME="$HOME/flutter"
FLUTTER_BIN="$FLUTTER_HOME/bin/flutter"

# Install Flutter
echo "📥 Installing Flutter..."
rm -rf $FLUTTER_HOME
git clone https://github.com/flutter/flutter.git -b stable $FLUTTER_HOME

# Verify installation
echo "🔍 Verifying Flutter..."
$FLUTTER_BIN --version
$FLUTTER_BIN doctor --android-licenses || true
$FLUTTER_BIN config --enable-web

# Pre-cache
echo "📦 Pre-caching Flutter dependencies..."
$FLUTTER_BIN precache --web

# Build project
echo "🧹 Cleaning..."
$FLUTTER_BIN clean

echo "📦 Getting dependencies..."
$FLUTTER_BIN pub get

echo "🌐 Building web app..."
$FLUTTER_BIN build web \
    --release \
    --web-renderer canvaskit \
    --dart-define=FLUTTER_APP_ENVIRONMENT=production

echo "✅ Build completed!"
echo "📊 Build size: $(du -sh build/web | cut -f1)"

# Verify output
if [ ! -d "build/web" ] || [ ! -f "build/web/index.html" ]; then
    echo "❌ Build verification failed"
    exit 1
fi

echo "🎉 Ready for deployment!"
