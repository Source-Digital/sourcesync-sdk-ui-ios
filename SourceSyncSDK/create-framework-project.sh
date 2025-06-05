#!/bin/bash
# create-framework-project.sh
# Run this in your SourceSyncSDK directory

set -e

PROJECT_NAME="SourceSyncSDK"
BUNDLE_ID="com.sourcedigital.sourcesync"

echo "🏗️ Creating Xcode Framework project for ${PROJECT_NAME}..."

# Check if we have xcodegen installed
if command -v xcodegen &> /dev/null; then
    echo "📝 Using xcodegen to create project..."
    
    # Create project.yml for xcodegen
    cat > project.yml << EOF
name: ${PROJECT_NAME}
options:
  bundleIdPrefix: com.sourcedigital
  deploymentTarget:
    iOS: "13.0"

targets:
  ${PROJECT_NAME}:
    type: framework
    platform: iOS
    sources:
      - path: Sources
        excludes: 
          - "**/*.md"
          - "**/Package.swift"
    settings:
      base:
        PRODUCT_BUNDLE_IDENTIFIER: ${BUNDLE_ID}
        SWIFT_VERSION: "5.7"
        DEFINES_MODULE: YES
        INFOPLIST_FILE: Sources/${PROJECT_NAME}/Info.plist
        FRAMEWORK_SEARCH_PATHS: \$(inherited)
        LD_RUNPATH_SEARCH_PATHS: "\$(inherited) @executable_path/Frameworks @loader_path/Frameworks"
        VALID_ARCHS: "arm64 x86_64"
        EXCLUDED_ARCHS[sdk=iphonesimulator*]: ""
        
  ${PROJECT_NAME}Tests:
    type: bundle.unit-test
    platform: iOS
    sources:
      - Tests
    dependencies:
      - target: ${PROJECT_NAME}
    settings:
      BUNDLE_LOADER: \$(TEST_HOST)
      TEST_HOST: \$(BUILT_PRODUCTS_DIR)/${PROJECT_NAME}.framework/${PROJECT_NAME}
EOF

    # Generate project
    xcodegen generate
    
    echo "✅ Project generated with xcodegen!"
    
else
    echo "❌ xcodegen not found. Please install it or create project manually:"
    echo ""
    echo "Manual steps:"
    echo "1. Open Xcode"
    echo "2. File → New → Project"
    echo "3. Choose Framework (iOS)"
    echo "4. Product Name: ${PROJECT_NAME}"
    echo "5. Save in current directory"
    echo ""
    echo "Or install xcodegen:"
    echo "brew install xcodegen"
    echo ""
    exit 1
fi

# Create Info.plist if it doesn't exist
if [ ! -f "Sources/${PROJECT_NAME}/Info.plist" ]; then
    mkdir -p "Sources/${PROJECT_NAME}"
    cat > "Sources/${PROJECT_NAME}/Info.plist" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>$(DEVELOPMENT_LANGUAGE)</string>
    <key>CFBundleExecutable</key>
    <string>$(EXECUTABLE_NAME)</string>
    <key>CFBundleIdentifier</key>
    <string>$(PRODUCT_BUNDLE_IDENTIFIER)</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>$(PRODUCT_NAME)</string>
    <key>CFBundlePackageType</key>
    <string>FMWK</string>
    <key>CFBundleShortVersionString</key>
    <string>0.4.0</string>
    <key>CFBundleVersion</key>
    <string>$(CURRENT_PROJECT_VERSION)</string>
</dict>
</plist>
EOF
fi

# Create umbrella header if it doesn't exist
if [ ! -f "Sources/${PROJECT_NAME}/${PROJECT_NAME}.h" ]; then
    cat > "Sources/${PROJECT_NAME}/${PROJECT_NAME}.h" << EOF
//
//  ${PROJECT_NAME}.h
//  ${PROJECT_NAME}
//

#import <Foundation/Foundation.h>

//! Project version number for ${PROJECT_NAME}.
FOUNDATION_EXPORT double ${PROJECT_NAME}VersionNumber;

//! Project version string for ${PROJECT_NAME}.
FOUNDATION_EXPORT const unsigned char ${PROJECT_NAME}VersionString[];
EOF
fi

echo "📁 Project structure created!"
echo "📋 Next steps:"
echo "1. pod install"
echo "2. open ${PROJECT_NAME}.xcworkspace"