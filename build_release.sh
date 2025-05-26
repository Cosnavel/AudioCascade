#!/bin/bash

# AudioCascade Release Build Script
# This script builds AudioCascade for release and prepares it for App Store submission

set -e

echo "🎵 Building AudioCascade for Release..."

# Clean previous builds
echo "🧹 Cleaning previous builds..."
rm -rf .build
rm -rf DerivedData
rm -rf AudioCascade.xcarchive
rm -rf AudioCascade.app

# Build for release
echo "🔨 Building release version..."
swift build -c release --arch arm64 --arch x86_64

# Create app bundle structure
echo "📦 Creating app bundle..."
mkdir -p AudioCascade.app/Contents/MacOS
mkdir -p AudioCascade.app/Contents/Resources
mkdir -p AudioCascade.app/Contents/Frameworks

# Copy executable
cp .build/apple/Products/Release/AudioCascade AudioCascade.app/Contents/MacOS/

# Copy Info.plist
cp AudioCascade/Resources/Info.plist AudioCascade.app/Contents/

# Copy Assets
cp -r AudioCascade/Resources/Assets.xcassets AudioCascade.app/Contents/Resources/

# Copy Sparkle framework if it exists
if [ -d ".build/artifacts/sparkle/Sparkle/Sparkle.xcframework/macos-arm64_x86_64/Sparkle.framework" ]; then
    echo "📚 Copying Sparkle framework..."
    cp -R .build/artifacts/sparkle/Sparkle/Sparkle.xcframework/macos-arm64_x86_64/Sparkle.framework AudioCascade.app/Contents/Frameworks/
fi

# Create entitlements for hardened runtime
cat > AudioCascade.app.entitlements << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>com.apple.security.app-sandbox</key>
    <true/>
    <key>com.apple.security.device.audio-input</key>
    <true/>
    <key>com.apple.security.files.user-selected.read-write</key>
    <true/>
    <key>com.apple.security.network.client</key>
    <true/>
</dict>
</plist>
EOF

echo "✅ Build complete!"
echo ""
echo "📝 Next steps for App Store submission:"
echo "1. Open the project in Xcode (open Package.swift)"
echo "2. Select 'AudioCascade' scheme"
echo "3. Set your Development Team in Signing & Capabilities"
echo "4. Product > Archive"
echo "5. Distribute App > App Store Connect"
echo ""
echo "🎯 The app bundle is located at: ./AudioCascade.app"
