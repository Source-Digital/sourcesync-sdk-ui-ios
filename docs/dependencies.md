# Dependencies Guide

This document provides a comprehensive overview of all dependencies used in the SourceSync SDK UI iOS project.

## Overview

The SDK follows a minimal dependency approach, relying primarily on:
- **DivKit** for declarative UI rendering
- **DivKitExtensions** for extended DivKit functionality
- **UIKit** for iOS UI foundation
- **Foundation** for core functionality

## Project Configuration

### Swift Version
- **Swift**: 5.9
- **iOS Deployment Target**: 17.0

### Package Management
- **CocoaPods**: 1.12.0+
- **Swift Package Manager**: Built-in with Xcode

### Configuration Files
```
├── SourceSyncSDK.podspec     # CocoaPods specification
└── SourceSyncSDK.xcodeproj   # Xcode project
```

## Core Dependencies

### 1. DivKit (Yandex Declarative UI)

**Purpose**: JSON-based UI rendering engine

**Version**:
```ruby
spec.dependency "DivKit", "~> 31.13.0"
```

**Why DivKit**:
- Declarative UI from JSON templates
- Cross-platform consistency (iOS/other platforms)
- Rich component library (containers, text, images, actions)
- Efficient rendering and memory management

**Key Classes Used**:
- `DivView` - Main rendering component
- `DivKitComponents` - Component configuration
- `DivUrlHandler` - URL action handling protocol
- `DivReporter` - Error reporting protocol
- `DivActionInfo` - Action context information

**Documentation**: [DivKit GitHub](https://github.com/yandex/divkit)

### 2. DivKitExtensions

**Purpose**: Extended DivKit functionality and utilities

**Version**:
```ruby
spec.dependency "DivKitExtensions", "~> 31.13.0"
```

**Features**:
- Additional UI components
- Extended layout capabilities
- Enhanced action handling
- Utility functions

**Integration**: Works seamlessly with core DivKit framework

### 3. UIKit Framework

**Purpose**: iOS user interface framework

**Version**: System framework (ships with iOS)

```ruby
spec.frameworks = "UIKit", "Foundation"
```

**Features Used**:
- `UIView` - Base view component
- `UITapGestureRecognizer` - Tap handling
- `NSLayoutConstraint` - Auto Layout
- `UIApplication` - URL opening and system integration
- Auto Layout system

**Why UIKit**:
- Native iOS UI framework
- Mature and stable
- Comprehensive layout system
- System integration

### 4. Foundation Framework

**Purpose**: Core iOS functionality

**Version**: System framework (ships with iOS)

**Features Used**:
- `URL` - URL handling and parsing
- `Data` - Binary data operations
- `JSONSerialization` - JSON parsing
- `DispatchQueue` - Threading and concurrency
- `Bundle` - Resource management

## Dependency Management

### Version Pinning Strategy

The project uses **pessimistic version constraints** to ensure:
- Compatible updates
- Controlled dependency versions
- Reproducible builds

**CocoaPods Versioning**:
```ruby
"~> 31.13.0"  # Allows 31.13.x but not 31.14.0
```

### No Core SDK Dependency

**Important**: This SDK UI library is **independent** and does NOT depend on:
- SourceSync Core SDK (can be used separately)
- Backend integration libraries
- Analytics or tracking SDKs

This allows the UI library to be used standalone for rendering DivKit-based content.

### Transitive Dependencies

The SDK minimizes transitive dependencies. Main transitive dependencies come from:

**DivKit** brings:
- Swift standard library
- Core Graphics
- Core Animation
- Foundation

**DivKitExtensions** brings:
- DivKit core dependencies

**Total transitive dependency count**: ~10-15 (minimal for functionality)

## Dependency Conflicts

### Known Conflicts and Resolutions

#### Swift Version Compatibility
```ruby
spec.swift_version = "5.9"
```

Ensures all dependencies use compatible Swift version.

#### DivKit Version Alignment
```ruby
spec.dependency "DivKit", "~> 31.13.0"
spec.dependency "DivKitExtensions", "~> 31.13.0"
```

Both dependencies use same major.minor version to ensure compatibility.

## Platform Requirements

### Minimum Deployment Target
```ruby
spec.ios.deployment_target = "17.0"
```

**Why iOS 17.0**:
- Modern iOS features
- Latest Swift language features
- Simplified API surface
- Better performance

### Supported Architectures
```ruby
'ARCHS' => '$(ARCHS_STANDARD)',
'VALID_ARCHS' => 'arm64 x86_64 arm64e'
```

**Architectures**:
- `arm64` - iPhone and iPad (64-bit)
- `x86_64` - Simulator on Intel Macs
- `arm64e` - Latest iOS devices with PAC

### Excluded Configurations
```ruby
'EXCLUDED_ARCHS' => ''  # No exclusions
'ENABLE_BITCODE' => 'NO'  # Bitcode disabled
```

## Swift Configuration

### Swift Version
```ruby
spec.swift_version = "5.9"
```

### Build Settings
```ruby
'SWIFT_VERSION' => '5.9'
'BUILD_LIBRARY_FOR_DISTRIBUTION' => 'NO'
'ARCHS' => '$(ARCHS_STANDARD)'
```

### Module Configuration
```ruby
spec.module_name = "SourceSyncSDK"
spec.requires_arc = true
```

**ARC**: Automatic Reference Counting enabled for memory management

## Repository Configuration

### Required Repositories

**CocoaPods**:
```ruby
source 'https://cdn.cocoapods.org/'
```

**Note**: All dependencies available from public repositories

## Dependency Update Strategy

### Version Compatibility Matrix

| Component | Current Version | Min Compatible | Max Tested |
|-----------|----------------|----------------|------------|
| Swift | 5.9 | 5.9 | 6.0 |
| iOS | 17.0 | 17.0 | 18.0 |
| Xcode | 16.2 | 16.0 | 16.2 |
| DivKit | 31.13.0 | 31.0.0 | 31.13.0 |
| DivKitExtensions | 31.13.0 | 31.0.0 | 31.13.0 |

### Update Process

1. **Check Compatibility**: Review DivKit release notes
2. **Update in Branch**: Never update dependencies directly in main
3. **Run Full Test Suite**: Unit tests and integration tests
4. **Test Demo Apps**: Verify visual rendering
5. **Update Documentation**: Note any API changes
6. **Create PR**: Document changes and testing results

### Automated Dependency Checks

Consider adding Dependabot for automated dependency updates:

```yaml
# .github/dependabot.yml (example)
version: 2
updates:
  - package-ecosystem: "swift"
    directory: "/"
    schedule:
      interval: "monthly"
```

## Size Impact

### Framework Size Breakdown

Approximate framework sizes:

- **SourceSyncSDK**: ~150KB
- **DivKit**: ~5MB
- **DivKitExtensions**: ~500KB
- **Total (with dependencies)**: ~6MB

### Method Count

- **SourceSyncSDK**: ~100 methods
- **Total (with dependencies)**: ~10,000 methods

**Note**: iOS doesn't have multidex limitations like other platforms

## Security Considerations

### Vulnerability Scanning

Monitor dependencies for security issues:

```bash
# Check CocoaPods for updates
pod outdated

# Update specific pod
pod update DivKit
```

### Dependency Sources

All dependencies from trusted sources:
- ✅ Yandex (DivKit, DivKitExtensions)
- ✅ Apple (UIKit, Foundation)

### Code Signing

Framework is code-signed during distribution:
- Developer ID for direct distribution
- App Store signing for CocoaPods

## Migration Guides

### Upgrading DivKit

When upgrading DivKit versions:

1. **Check Breaking Changes**: Review DivKit release notes
2. **Test Parsing**: Verify existing JSON templates still parse
3. **Test Rendering**: Check visual output hasn't changed
4. **Update Handlers**: Adjust `CustomUrlHandler` if protocols changed
5. **Update Reporter**: Check `CustomDivReporter` compatibility

**Example Migration**:
```ruby
# Before
spec.dependency "DivKit", "~> 30.0.0"

# After
spec.dependency "DivKit", "~> 31.13.0"
```

### Upgrading iOS Deployment Target

When increasing minimum iOS version:

1. **Review API Usage**: Check for deprecated APIs
2. **Test on Devices**: Verify on minimum supported version
3. **Update Documentation**: Note new minimum requirement
4. **Update Podspec**: Update deployment target

```ruby
# Update deployment target
spec.ios.deployment_target = "17.0"
```

## Troubleshooting

### Dependency Resolution Failures

**Problem**: CocoaPods can't resolve dependencies

**Solution**:
```bash
# Update CocoaPods repo
pod repo update

# Clear cache
pod cache clean --all

# Reinstall
rm -rf Pods
pod install
```

### Swift Version Conflicts

**Problem**: Multiple Swift version requirements

**Solution**: Ensure all dependencies support Swift 5.9+
```ruby
spec.swift_version = "5.9"
```

### Build Errors After Update

**Problem**: Build fails after dependency update

**Solution**:
```bash
# Clean derived data
rm -rf ~/Library/Developer/Xcode/DerivedData

# Clean build folder
xcodebuild clean -scheme SourceSyncSDK

# Rebuild
xcodebuild -scheme SourceSyncSDK build
```

### DivKit Integration Issues

**Problem**: DivKit rendering errors after update

**Solution**:
1. Check DivKit changelog for breaking changes
2. Verify JSON template compatibility
3. Update custom handlers if protocols changed
4. Enable visual errors for debugging

## CocoaPods Specification

### Full Podspec Structure

```ruby
Pod::Spec.new do |spec|
  spec.name         = "SourceSyncSDK"
  spec.version      = "0.3.27-2"
  spec.summary      = "A framework for handling activation details in iOS apps."
  spec.homepage     = "https://github.com/Source-Digital/sourcesync-sdk-ui-ios"
  spec.license      = { :type => "MIT", :file => "LICENSE.md" }
  spec.author       = { "Source Digital" => "dev@sourcedigital.net" }
  
  spec.ios.deployment_target = "17.0"
  spec.swift_version = "5.9"
  
  spec.source = { 
    :git => "https://github.com/Source-Digital/sourcesync-sdk-ui-ios.git", 
    :tag => "v#{spec.version}" 
  }
  
  spec.source_files = "Sources/**/*.{h,m,swift}"
  spec.exclude_files = "Package.swift", "Tests/**/*", "Example/**/*"
  
  spec.dependency "DivKit", "~> 31.13.0"
  spec.dependency "DivKitExtensions", "~> 31.13.0"
  spec.frameworks = "UIKit", "Foundation"
  
  spec.requires_arc = true
  spec.module_name = "SourceSyncSDK"
end
```

### Key Podspec Fields

| Field | Purpose | Value |
|-------|---------|-------|
| `name` | Pod identifier | SourceSyncSDK |
| `version` | Release version | 0.3.27-2 |
| `deployment_target` | Minimum iOS | 17.0 |
| `swift_version` | Swift language | 5.9 |
| `source_files` | Source code paths | Sources/**/*.swift |
| `frameworks` | System frameworks | UIKit, Foundation |

## Swift Package Manager

### Package.swift Structure

```swift
// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "SourceSyncSDK",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "SourceSyncSDK",
            targets: ["SourceSyncSDK"]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/yandex/divkit-ios.git",
            from: "31.13.0"
        )
    ],
    targets: [
        .target(
            name: "SourceSyncSDK",
            dependencies: [
                .product(name: "DivKit", package: "divkit-ios"),
                .product(name: "DivKitExtensions", package: "divkit-ios")
            ],
            path: "Sources"
        ),
        .testTarget(
            name: "SourceSyncSDKTests",
            dependencies: ["SourceSyncSDK"],
            path: "Tests"
        )
    ]
)
```

## Related Documentation

- [Setup Guide](setup.md) - Build environment setup
- [CI/CD Guide](cicd.md) - Publishing process
- [Architecture](architecture.md) - System design

## Dependency License Summary

| Dependency | License | Commercial Use |
|-----------|---------|----------------|
| DivKit | Apache 2.0 | ✅ Yes |
| DivKitExtensions | Apache 2.0 | ✅ Yes |
| UIKit | Apple EULA | ✅ Yes |
| Foundation | Apple EULA | ✅ Yes |

**SDK License**: MIT

All dependencies are compatible with commercial use.

## Dependency Graph

```
SourceSyncSDK
├── DivKit (~> 31.13.0)
│   ├── Foundation (system)
│   ├── UIKit (system)
│   ├── CoreGraphics (system)
│   └── CoreAnimation (system)
├── DivKitExtensions (~> 31.13.0)
│   └── DivKit
├── UIKit (system)
└── Foundation (system)
```

## Best Practices

1. **Pin Major Versions**: Use pessimistic versioning (`~>`) for stability
2. **Update Regularly**: Check for security updates monthly
3. **Test Thoroughly**: Run full test suite after updates
4. **Document Changes**: Note breaking changes in changelogs
5. **Monitor Size**: Track framework size impacts
6. **Review Licenses**: Ensure license compatibility
7. **Use Minimal Dependencies**: Only add necessary dependencies
8. **Version Alignment**: Keep DivKit and DivKitExtensions aligned