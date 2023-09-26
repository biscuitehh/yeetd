#!/bin/bash

# Configuration bits
DEVELOPER_ID_INSTALLER=$1
APPLE_ID=$2
TEAM_ID=$3
PASSWORD=$4

# Prepare the work directory
mkdir -p tmp/output/usr/local/bin
mkdir -p tmp/output/Library/LaunchAgents
mkdir -p tmp/scripts

# Build the binary
xcodebuild clean build -project yeetd.xcodeproj -configuration Release

# Prepare for packaging
cp ./build/Release/yeetd ./tmp/output/usr/local/bin/
cp ./Resources/prewarm_simulators.sh ./tmp/output/usr/local/bin/
cp ./Resources/dev.biscuit.yeetd.plist ./tmp/output/Library/LaunchAgents/
cp ./Resources/postinstall ./tmp/scripts/

# Package
xcrun pkgbuild --identifier "dev.biscuit.yeetd" --version "1.0" --root "tmp/output" --scripts "tmp/scripts" --install-location "/" "tmp/yeetd-unsigned.pkg"

# Sign package
xcrun productsign --sign "$DEVELOPER_ID_INSTALLER" ./tmp/yeetd-unsigned.pkg yeetd-signed.pkg

# Notarize and Staple
xcrun notarytool store-credentials 'notarize-app' --apple-id "$APPLE_ID" --team-id "$TEAM_ID" --password "$PASSWORD"
xcrun notarytool submit --wait --keychain-profile 'notarize-app' yeetd-signed.pkg
xcrun stapler staple yeetd-signed.pkg

# Clean up
rm -rf build
rm -rf tmp