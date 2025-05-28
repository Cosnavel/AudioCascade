#!/bin/bash

# Build script for AudioCascade
# This script builds a properly packaged .app bundle with all frameworks

echo "Building AudioCascade Release..."

# Clean previous builds
rm -rf .build/arm64-apple-macosx/release/AudioCascade.app

# Build release version
swift build -c release --arch arm64

# Create the app bundle structure
mkdir -p .build/arm64-apple-macosx/release/AudioCascade.app/Contents/MacOS
mkdir -p .build/arm64-apple-macosx/release/AudioCascade.app/Contents/Frameworks
mkdir -p .build/arm64-apple-macosx/release/AudioCascade.app/Contents/Resources

# Copy the executable
cp .build/arm64-apple-macosx/release/AudioCascade .build/arm64-apple-macosx/release/AudioCascade.app/Contents/MacOS/

# Copy Info.plist
cp AudioCascade/Resources/Info.plist .build/arm64-apple-macosx/release/AudioCascade.app/Contents/

# Copy resources if they exist
if [ -d "AudioCascade/Resources/Assets.xcassets" ]; then
    cp -R AudioCascade/Resources/Assets.xcassets .build/arm64-apple-macosx/release/AudioCascade.app/Contents/Resources/
fi

# Copy localizations
if [ -d "AudioCascade/Resources/Localizations" ]; then
    cp -R AudioCascade/Resources/Localizations/* .build/arm64-apple-macosx/release/AudioCascade.app/Contents/Resources/
fi

# Copy Sparkle framework
cp -R .build/arm64-apple-macosx/release/Sparkle.framework .build/arm64-apple-macosx/release/AudioCascade.app/Contents/Frameworks/

# Fix rpath
install_name_tool -add_rpath @executable_path/../Frameworks .build/arm64-apple-macosx/release/AudioCascade.app/Contents/MacOS/AudioCascade

# Sign the app
codesign --force --deep --sign - .build/arm64-apple-macosx/release/AudioCascade.app

echo "Build complete! App is at: .build/arm64-apple-macosx/release/AudioCascade.app"
echo "To run: open .build/arm64-apple-macosx/release/AudioCascade.app"
