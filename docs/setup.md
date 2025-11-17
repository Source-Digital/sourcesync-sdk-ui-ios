# Development Setup Guide

This guide will help you set up your development environment for the SourceSync SDK UI iOS project.

## Prerequisites

### Required Software

- **Xcode**: 16.2.0 or newer
- **macOS**: 14.0 (Sonoma) or newer
- **CocoaPods**: 1.12.0 or newer
- **Swift**: 5.9+
- **Git**: Latest stable version

### Minimum System Requirements

- **macOS**: Sonoma (14.0) or later
- **RAM**: 8GB minimum, 16GB recommended
- **Disk Space**: 20GB free space for Xcode and dependencies

## Environment Setup

### 1. Install Xcode

1. Download Xcode 16.2.0 from the Mac App Store
2. Or download from [Apple Developer Downloads](https://developer.apple.com/download/)
3. Install Xcode Command Line Tools:

```bash
xcode-select --install
```

#### Verify Installation
```bash
xcodebuild -version
# Should show: Xcode 16.2 or newer
```

### 2. Install CocoaPods

```bash
sudo gem install cocoapods
```

#### Verify Installation
```bash
pod --version
# Should show: 1.12.0 or newer
```

### 4. Clone the Repository

```bash
git clone https://github.com/Source-Digital/sourcesync-sdk-ui-ios.git
cd sourcesync-sdk-ui-ios
```

## Building the Project

### Using Xcode

#### 1. Open Project
```bash
open SourceSyncSDK.xcodeproj
# or if using workspace
open SourceSyncSDK.xcworkspace
```

#### 2. Select Scheme
1. Click scheme selector in toolbar
2. Select **SourceSyncSDK** scheme
3. Choose target device or simulator

#### 3. Build
- **Product → Build** (or `Cmd+B`)
- **Product → Clean Build Folder** (or `Cmd+Shift+K`) to clean

#### Build Output
- Framework: `Build/Products/Debug-iphoneos/SourceSyncSDK.framework`
- Archive: Via **Product → Archive**

### Command Line Build

#### Build Framework
```bash
# Debug build
xcodebuild -scheme SourceSyncSDK -configuration Debug build

# Release build
xcodebuild -scheme SourceSyncSDK -configuration Release build

# Build for device
xcodebuild -scheme SourceSyncSDK \
  -destination 'generic/platform=iOS' \
  -configuration Release build
```

#### Build for Simulator
```bash
xcodebuild -scheme SourceSyncSDK \
  -destination 'platform=iOS Simulator,name=iPhone 15 Pro' \
  build
```

#### Create XCFramework
```bash
xcodebuild archive \
  -scheme SourceSyncSDK \
  -destination 'generic/platform=iOS' \
  -archivePath './build/ios.xcarchive' \
  SKIP_INSTALL=NO \
  BUILD_LIBRARY_FOR_DISTRIBUTION=YES

xcodebuild archive \
  -scheme SourceSyncSDK \
  -destination 'generic/platform=iOS Simulator' \
  -archivePath './build/ios_sim.xcarchive' \
  SKIP_INSTALL=NO \
  BUILD_LIBRARY_FOR_DISTRIBUTION=YES

xcodebuild -create-xcframework \
  -framework './build/ios.xcarchive/Products/Library/Frameworks/SourceSyncSDK.framework' \
  -framework './build/ios_sim.xcarchive/Products/Library/Frameworks/SourceSyncSDK.framework' \
  -output './build/SourceSyncSDK.xcframework'
```

## Running Tests

### Unit Tests

Unit tests run on simulator or device.

#### Run All Tests (Xcode)
1. **Product → Test** (or `Cmd+U`)
2. View results in Test Navigator (`Cmd+6`)

#### Run All Tests (Command Line)
```bash
xcodebuild test \
  -scheme SourceSyncSDK \
  -destination 'platform=iOS Simulator,name=iPhone 15 Pro'
```

#### Run Specific Test
```bash
xcodebuild test \
  -scheme SourceSyncSDK \
  -destination 'platform=iOS Simulator,name=iPhone 15 Pro' \
  -only-testing:SourceSyncSDKTests/UnifiedActivationViewTests
```

#### Test Results Location
```
Build/Logs/Test/
```

### UI Tests

If UI tests are available:

```bash
xcodebuild test \
  -scheme SourceSyncSDKUITests \
  -destination 'platform=iOS Simulator,name=iPhone 15 Pro'
```

## Running MobileDemo

### From Xcode

1. Open workspace: `open MobileDemo/MobileDemo.xcworkspace`
2. Select **MobileDemo** scheme
3. Choose target simulator or device
4. Click **Run** (or `Cmd+R`)

### From Command Line

```bash
cd MobileDemo
pod install

xcodebuild -workspace MobileDemo.xcworkspace \
  -scheme MobileDemo \
  -destination 'platform=iOS Simulator,name=iPhone 15 Pro' \
  build
```

## Common Development Tasks

### Clean Build
```bash
# Xcode
Product → Clean Build Folder (Cmd+Shift+K)

# Command line
xcodebuild clean -scheme SourceSyncSDK
```

### Update Dependencies

#### CocoaPods
```bash
pod update
```

### Generate Documentation

```bash
# Using DocC
xcodebuild docbuild \
  -scheme SourceSyncSDK \
  -destination 'platform=iOS Simulator,name=iPhone 15 Pro'

# Output: Build/Products/Debug-iphonesimulator/SourceSyncSDK.doccarchive
```

### Analyze Code

```bash
xcodebuild analyze \
  -scheme SourceSyncSDK \
  -destination 'platform=iOS Simulator,name=iPhone 15 Pro'
```

### Local CocoaPods Testing

```bash
# Lint podspec locally
pod spec lint SourceSyncSDK.podspec --allow-warnings

# Test in example project
cd MobileDemo
pod install --project-directory=.
```

## Project Structure

```
sourcesync-sdk-ui-ios/
├── Sources/                      # SDK source code
│   ├── ActivationConfig.swift
│   ├── UnifiedActivationView.swift
│   ├── CustomUrlHandler.swift
│   └── Models/
├── Tests/                        # Unit tests
│   └── SourceSyncSDKTests/
├── MobileDemo/                      # Demo app
│   └── MobileDemo/
├── docs/                         # Documentation
├── SourceSyncSDK.podspec        # CocoaPods spec
├── LICENSE.md                    # License file
└── README.md                     # Project overview
```

## Troubleshooting

### Build Failures

**Problem**: Module not found

**Solution**:
```bash
# Clean derived data
rm -rf ~/Library/Developer/Xcode/DerivedData/*

# Clean build folder in Xcode
Product → Clean Build Folder
```

### CocoaPods Issues

**Problem**: Pod install fails

**Solution**:
```bash
# Update CocoaPods
sudo gem install cocoapods

# Clear cache
pod cache clean --all

# Reinstall
pod deintegrate
pod install
```

### Simulator Issues

**Problem**: Simulator not responding

**Solution**:
```bash
# Reset simulator
xcrun simctl erase all

# Boot simulator
xcrun simctl boot "iPhone 15 Pro"
```

### DivKit Integration Issues

**Problem**: DivKit rendering errors

**Solution**:
1. Enable visual errors:
   ```swift
   ActivationConfig.Builder()
       .setVisualErrorsEnabled(true)
       .build()
   ```
2. Check Console for DivKit logs
3. Verify JSON template structure

### Signing Issues

**Problem**: Code signing failures

**Solution**:
1. Open project settings
2. Select target → Signing & Capabilities
3. Enable "Automatically manage signing"
4. Select your team

## IDE Configuration

### Recommended Xcode Settings

1. **Preferences → Text Editing**
   - ☑️ Line numbers
   - ☑️ Code folding ribbon
   - ☑️ Page guide at column: 120

2. **Preferences → Behaviors**
   - Configure build success/failure behaviors

3. **Preferences → Key Bindings**
   - Customize shortcuts for common tasks

### Debug Console Filters

Add these filters for debugging:

```
# SDK logs
UnifiedActivationView OR ActivationConfig OR CustomUrlHandler

# DivKit logs
DivView OR DivKit
```

### Useful Xcode Shortcuts

| Action | Shortcut |
|--------|----------|
| Build | `Cmd+B` |
| Run | `Cmd+R` |
| Test | `Cmd+U` |
| Clean | `Cmd+Shift+K` |
| Quick Open | `Cmd+Shift+O` |
| Navigate Back | `Cmd+Ctrl+←` |
| Jump to Definition | `Cmd+Click` |

## Performance Profiling

### Instruments

1. **Product → Profile** (or `Cmd+I`)
2. Choose template:
   - **Leaks**: Memory leak detection
   - **Allocations**: Memory usage
   - **Time Profiler**: CPU usage

### Debug Memory Graph

1. Run app in Xcode
2. Click **Debug Memory Graph** button (💠)
3. Inspect object relationships

## Code Quality Tools

### SwiftLint (Optional)

```bash
# Install
brew install swiftlint

# Run
swiftlint

# Auto-fix
swiftlint --fix
```

### SwiftFormat (Optional)

```bash
# Install
brew install swiftformat

# Format
swiftformat .
```

## Next Steps

- Review [CI/CD Documentation](cicd.md) for release process
- Check [Dependencies Guide](dependencies.md) for library information
- Read [UI Guidelines](ui-guidelines.md) for component usage
- Explore [Architecture](architecture.md) for system design

## Getting Help

- **Issues**: [GitHub Issues](https://github.com/Source-Digital/sourcesync-sdk-ui-ios/issues)
- **Documentation**: [/docs](../docs/)
- **API Reference**: Build DocC documentation

## Contributing

When contributing:
1. Fork the repository
2. Create feature branch
3. Write tests for new features
4. Ensure all tests pass
5. Submit pull request

## Testing on Different Devices

### Simulator Testing
```bash
# List available simulators
xcrun simctl list devices

# Boot specific simulator
xcrun simctl boot "iPhone 15 Pro"

# Install app
xcrun simctl install booted path/to/app
```

### Device Testing

1. Connect device via USB
2. Trust computer on device
3. Select device in Xcode
4. Enable developer mode on device
5. Run/Debug on device