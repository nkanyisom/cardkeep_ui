#!/bin/bash
set -e

echo "Installing Flutter..."
git clone https://github.com/flutter/flutter.git -b stable /tmp/flutter
export PATH="/tmp/flutter/bin:$PATH"

echo "Flutter version:"
/tmp/flutter/bin/flutter --version

echo "Enabling web..."
/tmp/flutter/bin/flutter config --enable-web

echo "Building project..."
/tmp/flutter/bin/flutter pub get
/tmp/flutter/bin/flutter build web --release

echo "Done!"
