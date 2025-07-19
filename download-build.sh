#!/bin/bash

# Exit on any error
set -e

echo "Building CardKeep Flutter Web App"

# Install Flutter using snap (alternative method)
echo "Installing Flutter..."

# Method 1: Try direct download and extract
FLUTTER_VERSION="3.24.5"
FLUTTER_ARCHIVE="flutter_linux_${FLUTTER_VERSION}-stable.tar.xz"

# Download Flutter
curl -O "https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/${FLUTTER_ARCHIVE}"

# Extract Flutter
tar xf "$FLUTTER_ARCHIVE" -C "$HOME/"

# Add to PATH and make executable
export PATH="$HOME/flutter/bin:$PATH"
chmod +x "$HOME/flutter/bin/flutter"

# Verify installation
echo "Flutter version:"
$HOME/flutter/bin/flutter --version

# Enable web
$HOME/flutter/bin/flutter config --enable-web

# Build the project
echo "Cleaning project..."
$HOME/flutter/bin/flutter clean

echo "Getting dependencies..."
$HOME/flutter/bin/flutter pub get

echo "Building for web..."
$HOME/flutter/bin/flutter build web --release --dart-define=FLUTTER_APP_ENVIRONMENT=production

echo "Build complete!"
ls -la build/web/
