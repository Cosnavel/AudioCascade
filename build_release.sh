#!/bin/bash

# Build script for AudioCascade
# This script builds a properly packaged .app bundle with all frameworks

echo "Building AudioCascade Release..."

# Clean previous builds
rm -rf .build/arm64-apple-macosx/release/AudioCascade.app

# Build release version
swift build -c release --arch arm64

# Create Frameworks directory
mkdir -p .build/arm64-apple-macosx/release/AudioCascade.app/Contents/Frameworks

# Copy Sparkle framework
cp -R .build/arm64-apple-macosx/release/Sparkle.framework .build/arm64-apple-macosx/release/AudioCascade.app/Contents/Frameworks/

# Fix rpath
install_name_tool -add_rpath @executable_path/../Frameworks .build/arm64-apple-macosx/release/AudioCascade.app/Contents/MacOS/AudioCascade

# Sign the app
codesign --force --deep --sign - .build/arm64-apple-macosx/release/AudioCascade.app

echo "Build complete! App is at: .build/arm64-apple-macosx/release/AudioCascade.app"
echo "To run: open .build/arm64-apple-macosx/release/AudioCascade.app"
