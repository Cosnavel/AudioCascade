#!/bin/bash

# Create DMG for AudioCascade distribution

# First build the release version
./build_release.sh

# Create a temporary directory for DMG
mkdir -p dmg_temp
cp -R .build/arm64-apple-macosx/release/AudioCascade.app dmg_temp/

# Create Applications symlink
ln -s /Applications dmg_temp/Applications

# Create DMG
hdiutil create -volname "AudioCascade" -srcfolder dmg_temp -ov -format UDZO AudioCascade.dmg

# Clean up
rm -rf dmg_temp

echo "DMG created: AudioCascade.dmg"
