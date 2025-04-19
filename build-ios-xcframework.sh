#!/bin/bash

# Script to build a universal XCFramework with arm64 and x86_64 architectures for iOS only
# This creates an XCFramework that can be used on both iOS simulators and devices

# Set the project name and other configuration
PROJECT_NAME="SourceSyncSDK"
SCHEME_NAME="SourceSyncSDK"
FRAMEWORK_NAME="SourceSyncSDK"
WORKSPACE_FILE="sourcesync-sdk-ui-ios.xcworkspace"
OUTPUT_DIR="./Build"

# Cleanup any existing builds
rm -rf "${OUTPUT_DIR}"
mkdir -p "${OUTPUT_DIR}"

echo "📱 Building for iOS devices (arm64)..."
xcodebuild archive \
  -workspace "${WORKSPACE_FILE}" \
  -scheme "${SCHEME_NAME}" \
  -sdk iphoneos \
  -archivePath "${OUTPUT_DIR}/ios-arm64.xcarchive" \
  SKIP_INSTALL=NO \
  BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
  ARCHS="arm64" \
  VALID_ARCHS="arm64" \
  SUPPORTS_MACCATALYST=NO \
  SWIFT_OPTIMIZATION_LEVEL="-Onone" \
  SWIFT_VERSION=5.7 \
  DEBUG_INFORMATION_FORMAT="dwarf-with-dsym"

echo "📱 Building for iOS simulator (arm64, x86_64)..."
xcodebuild archive \
  -workspace "${WORKSPACE_FILE}" \
  -scheme "${SCHEME_NAME}" \
  -sdk iphonesimulator \
  -archivePath "${OUTPUT_DIR}/ios-simulator.xcarchive" \
  SKIP_INSTALL=NO \
  BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
  ARCHS="arm64 x86_64" \
  VALID_ARCHS="arm64 x86_64" \
  SUPPORTS_MACCATALYST=NO \
  SWIFT_OPTIMIZATION_LEVEL="-Onone" \
  SWIFT_VERSION=5.7 \
  DEBUG_INFORMATION_FORMAT="dwarf-with-dsym"

echo "📂 Checking archive contents..."
find "${OUTPUT_DIR}" -name "*.framework" -type d

# Check if builds were successful
if [ ! -d "${OUTPUT_DIR}/ios-arm64.xcarchive" ] || [ ! -d "${OUTPUT_DIR}/ios-simulator.xcarchive" ]; then
    echo "❌ Error: One or more archives failed to build"
    exit 1
fi

# Check for existence of framework files before creating XCFramework
IOS_DEVICE_FRAMEWORK="${OUTPUT_DIR}/ios-arm64.xcarchive/Products/usr/local/lib/Frameworks/${FRAMEWORK_NAME}.framework"
IOS_SIMULATOR_FRAMEWORK="${OUTPUT_DIR}/ios-simulator.xcarchive/Products/Applications/SourceSyncSDK.framework"

if [ ! -d "$IOS_DEVICE_FRAMEWORK" ] || [ ! -d "$IOS_SIMULATOR_FRAMEWORK" ]; then
    echo "❌ Error: One or more framework files are missing"
    echo "Looked for frameworks at:"
    echo "- $IOS_DEVICE_FRAMEWORK"
    echo "- $IOS_SIMULATOR_FRAMEWORK"
    exit 1
fi

echo "🔨 Creating iOS-only XCFramework..."
xcodebuild -create-xcframework \
  -framework "${IOS_DEVICE_FRAMEWORK}" \
  -framework "${IOS_SIMULATOR_FRAMEWORK}" \
  -output "${OUTPUT_DIR}/${FRAMEWORK_NAME}.xcframework"

if [ -d "${OUTPUT_DIR}/${FRAMEWORK_NAME}.xcframework" ]; then
    echo "✅ XCFramework successfully created at ${OUTPUT_DIR}/${FRAMEWORK_NAME}.xcframework"
    echo "🎉 Build process completed successfully!"
else
    echo "❌ Failed to create XCFramework"
    exit 1
fi