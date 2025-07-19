#!/bin/bash
set -e

echo "🏗️ Starting CardKeep build process..."

# Define Flutter installation path
FLUTTER_DIR="$HOME/flutter"

# Clean up any existing Flutter installation
echo "🧹 Cleaning up previous installations..."
rm -rf "$FLUTTER_DIR"

# Install Flutter
echo "📥 Downloading Flutter..."
git clone https://github.com/flutter/flutter.git -b stable "$FLUTTER_DIR"

# Make Flutter executable
chmod +x "$FLUTTER_DIR/bin/flutter"

# Test Flutter installation
echo "🔍 Testing Flutter installation..."
"$FLUTTER_DIR/bin/flutter" --version

# Configure Flutter for web
echo "🌐 Configuring Flutter for web..."
"$FLUTTER_DIR/bin/flutter" config --enable-web

# Navigate to project directory (if needed)
cd "$PWD"

# Clean project
echo "🧹 Cleaning Flutter project..."
"$FLUTTER_DIR/bin/flutter" clean

# Get dependencies
echo "📦 Getting Flutter dependencies..."
"$FLUTTER_DIR/bin/flutter" pub get

# Build web application
echo "🚀 Building web application..."
"$FLUTTER_DIR/bin/flutter" build web \
    --release \
    --web-renderer canvaskit \
    --dart-define=FLUTTER_APP_ENVIRONMENT=production

# Verify build output
echo "✅ Verifying build output..."
if [ -d "build/web" ] && [ -f "build/web/index.html" ]; then
    echo "🎉 Build completed successfully!"
    echo "📊 Build directory size: $(du -sh build/web | cut -f1)"
    ls -la build/web/
else
    echo "❌ Build failed - missing output files"
    exit 1
fi

echo "🎯 CardKeep is ready for deployment!"
