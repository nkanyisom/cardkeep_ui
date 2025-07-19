#!/bin/bash

# Production Build Script for CardKeep

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🏗️  CardKeep - Production Build${NC}"
echo "================================="

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo -e "${RED}❌ Flutter is not installed or not in PATH${NC}"
    echo "Please install Flutter and add it to your PATH"
    exit 1
fi

# Check Flutter doctor
echo -e "${YELLOW}🔍 Checking Flutter installation...${NC}"
flutter doctor -v

# Clean previous builds
echo -e "${YELLOW}🧹 Cleaning previous builds...${NC}"
flutter clean

# Get dependencies
echo -e "${YELLOW}📦 Installing dependencies...${NC}"
flutter pub get

# Run code generation (for Hive)
echo -e "${YELLOW}⚙️  Running code generation...${NC}"
flutter packages pub run build_runner build --delete-conflicting-outputs

# Run tests
echo -e "${YELLOW}🧪 Running tests...${NC}"
flutter test

# Build for web with production settings
echo -e "${YELLOW}🌐 Building for web (production)...${NC}"
flutter build web \
    --release \
    --web-renderer canvaskit \
    --base-href "/" \
    --dart-define=FLUTTER_APP_ENVIRONMENT=production \
    --dart-define=FLUTTER_APP_API_BASE_URL_PROD="$PROD_API_URL" \
    --dart-define=FIREBASE_API_KEY="$FIREBASE_API_KEY" \
    --dart-define=FIREBASE_AUTH_DOMAIN="$FIREBASE_AUTH_DOMAIN" \
    --dart-define=FIREBASE_PROJECT_ID="$FIREBASE_PROJECT_ID" \
    --dart-define=FIREBASE_STORAGE_BUCKET="$FIREBASE_STORAGE_BUCKET" \
    --dart-define=FIREBASE_MESSAGING_SENDER_ID="$FIREBASE_MESSAGING_SENDER_ID" \
    --dart-define=FIREBASE_APP_ID="$FIREBASE_APP_ID" \
    --dart-define=FIREBASE_MEASUREMENT_ID="$FIREBASE_MEASUREMENT_ID"

# Verify build output
if [ ! -d "build/web" ]; then
    echo -e "${RED}❌ Build failed! build/web directory not found.${NC}"
    exit 1
fi

# Check build size
BUILD_SIZE=$(du -sh build/web | cut -f1)
echo -e "${GREEN}✅ Build completed successfully!${NC}"
echo -e "${BLUE}📊 Build size: $BUILD_SIZE${NC}"

# List build contents
echo -e "${BLUE}📁 Build contents:${NC}"
ls -la build/web/

# Optional: Analyze bundle size
if command -v flutter &> /dev/null; then
    echo -e "${YELLOW}📈 Analyzing bundle size...${NC}"
    flutter build web --analyze-size --target-platform web-javascript
fi

echo -e "${GREEN}🎉 Production build ready for deployment!${NC}"
echo "Build location: build/web/"
echo ""
echo "Next steps:"
echo "1. Test the build locally: serve build/web/"
echo "2. Deploy using: ./deploy.sh or ./deploy.bat"
echo "3. Monitor your deployed application"
