# Architecture Overview

This document serves as a critical, living template designed to equip agents with a rapid and comprehensive understanding of the SourceSync SDK UI iOS codebase's architecture, enabling efficient navigation and effective contribution from day one.

## 1. Project Structure

This section provides a high-level overview of the project's directory and file structure, categorized by architectural layer and functional responsibilities for iOS SDK UI components.

```
[SourceSync SDK UI iOS Root]/
├── Sources/                          # Main SDK source code
│   ├── SourceSyncSDK/               # Framework module
│   │   ├── UnifiedActivationView.swift     # Main view component
│   │   ├── ActivationConfig.swift          # Configuration builder
│   │   ├── ActivationPosition.swift        # Position models
│   │   ├── CustomUrlHandler.swift          # URL routing handler
│   │   └── CustomDivReporter.swift         # DivKit error reporter
├── Tests/                            # Unit tests
│   └── SourceSyncSDKTests/          # Test cases
├── Example/                          # Example application (if exists)
│   └── ExampleApp/                  # Demo app showcase
├── docs/                             # Project documentation
├── .github/                          # GitHub workflows
│   └── workflows/
│       └── ios-ci-cd.yml            # CocoaPods publishing workflow
├── SourceSyncSDK.podspec            # CocoaPods specification
├── LICENSE.md                        # Project license
└── README.md                         # Project overview
```

## 2. High-Level System Diagram

The SourceSync SDK UI iOS provides UI components that integrate with the SourceSync Core SDK to display interactive activation overlays within media applications.

```
[Media Player App] <--> [SourceSync SDK UI] <--> [SourceSync Core SDK] <--> [SourceSync Backend]
                                |
                                +--> [DivKit Rendering] <--> [Image Loading]
                                |
                                +--> [Activation Templates (JSON)]
```

**Data Flow:**
1. Media app integrates SourceSync SDK UI components
2. SDK UI receives activation data from SourceSync Core SDK
3. JSON templates are processed through DivKit for rendering
4. Images are loaded via DivKit's image loading system
5. User interactions trigger callbacks to parent application

## 3. Core Components

### 3.1. UI Components Layer

#### 3.1.1. UnifiedActivationView
**Name:** Unified Activation Display Component

**Description:** Central UI component that renders both preview and detail modes for activations. Replaces separate preview/details components with a single configurable view. Handles DivKit integration, touch events, and lifecycle management.

**Technologies:** Swift, DivKit, UIKit, Auto Layout

**Key Features:**
- Unified preview/detail display modes
- Configurable positioning and alignment
- Outside tap detection with video control preservation
- Proper resource cleanup and memory management
- Asynchronous DivKit data loading

**Public API:**
```swift
public class UnifiedActivationView: UIView {
    public static func createFromDivData(divData: Data, config: ActivationConfig) -> UnifiedActivationView
    public static func createFromJson(json: [String: Any], config: ActivationConfig) -> UnifiedActivationView
    public func setConfig(_ config: ActivationConfig)
    public func setViewData(_ viewData: Data)
    public func setViewDataFromJson(_ jsonObject: [String: Any])
    public func hide()
    public func cleanup()
}
```

#### 3.1.2. ActivationConfig
**Name:** Configuration Builder for Activation Views

**Description:** Builder pattern implementation for configuring UnifiedActivationView behavior, positioning, handlers, and DivKit integration. Provides fluent interface for SDK consumers to customize activation display.

**Technologies:** Swift Builder Pattern, DivKit Configuration

**Key Features:**
- Fluent configuration API
- Screen metrics integration
- URL handler configuration
- Visual error toggle for debugging
- Closure-based callback system

**Public API:**
```swift
public class ActivationConfig {
    public class Builder {
        public func setPreviewClickHandler(_ handler: @escaping () -> Void) -> Builder
        public func setUrlActionHandler(_ handler: @escaping () -> Void) -> Builder
        public func setOutsideClickHandler(_ handler: @escaping () -> Void) -> Builder
        public func setDetailsCloseHandler(_ handler: @escaping () -> Void) -> Builder
        public func setVisualErrorsEnabled(_ enabled: Bool) -> Builder
        public func setActivationPosition(_ activationPosition: ActivationPosition) -> Builder
        public func build() -> ActivationConfig
    }
}
```

### 3.2. Helper Components

#### 3.2.1. CustomUrlHandler
**Name:** DivKit URL Action Handler

**Description:** Comprehensive URL handler for DivKit that processes close actions, external URLs, custom schemes, and deep links. Integrates with iOS system intents and provides callback mechanisms.

**Technologies:** DivKit DivUrlHandler, UIApplication, URL Processing

**Key Features:**
- Multi-protocol URL handling (http/https, mailto, tel, sms)
- Custom scheme processing (div-action://)
- System app integration with fallback handling
- Comprehensive error handling and logging
- Main thread safety for UI operations

**URL Schemes Supported:**
- `div-action://close` - Close action
- `div-action://refresh` - Refresh action
- `div-action://back` - Back navigation
- `http://`, `https://` - External URLs
- `mailto:` - Email composition
- `tel:`, `sms:` - Phone/SMS
- Custom schemes - App-specific deep links

#### 3.2.2. CustomDivReporter
**Name:** DivKit Error and Action Reporter

**Description:** Custom implementation of DivKit's DivReporter protocol for handling errors and actions. Provides delegation pattern for error handling and suppresses default DivKit error UI.

**Technologies:** DivKit DivReporter Protocol

**Key Features:**
- Custom error delegation
- Action reporting
- Suppression of default error UI
- Console logging for debugging

**Protocol:**
```swift
protocol DivKitErrorDelegate: AnyObject {
    func handleDivKitError(_ error: any DivError, cardId: DivCardID)
}
```

### 3.3. Model Layer

#### 3.3.1. ActivationPosition
**Name:** Positioning and Alignment Models

**Description:** Data structure defining activation positioning within screen boundaries. Includes screen dimensions and alignment preferences for precise positioning.

**Technologies:** Swift Structs, CGFloat

**Key Features:**
- Screen dimension integration
- Alignment enum support
- Immutable configuration
- Layout calculation foundation

**Public API:**
```swift
public struct ActivationPosition {
    let screenWidth: CGFloat
    let screenHeight: CGFloat
    let alignment: Alignment
    
    public init(screenWidth: CGFloat, screenHeight: CGFloat, alignment: Alignment)
}
```

#### 3.3.2. Alignment
**Name:** Alignment Enumeration

**Description:** Defines possible alignment positions for activation views within their container.

**Options:**
- `topLeading` - Top-left corner
- `topTrailing` - Top-right corner
- `bottomLeading` - Bottom-left corner
- `bottomTrailing` - Bottom-right corner
- `center` - Center of container

### 3.4. Integration Layer

#### 3.4.1. DivKitComponents
**Name:** DivKit Framework Integration

**Description:** Provides DivKit components configuration with custom URL handling and image loading.

**Key Integration Points:**
- Custom URL handler integration
- Image loading configuration
- Error reporting setup
- Component lifecycle management

## 4. Data Flow

### 4.1. View Creation Flow

```
JSON/Data → ActivationConfig.Builder → Build Config
                                            ↓
                                    UnifiedActivationView.createFromJson
                                            ↓
                                    Initialize DivView
                                            ↓
                                    Setup Constraints
                                            ↓
                                    Load DivKit Data
                                            ↓
                                    Render Content
```

### 4.2. User Interaction Flow

```
User Tap → UITapGestureRecognizer → viewTapped()
                                          ↓
                                    config.onPreviewClickHandler?()
                                          ↓
                                    Application Response
```

### 4.3. URL Action Flow

```
DivKit Action → CustomUrlHandler.handle()
                        ↓
                Analyze URL Scheme
                        ↓
        ┌───────────────┼───────────────┐
        ↓               ↓               ↓
    Close Action   External URL   Custom Scheme
        ↓               ↓               ↓
    onCloseAction  UIApplication    onCustomScheme
                    .open()
```

## 5. External Integrations / APIs

### 5.1. DivKit Framework
**Purpose:** UI rendering engine for JSON-based layouts
**Integration Method:** Direct framework integration with custom components
**Version:** ~> 31.13.0

### 5.2. DivKitExtensions
**Purpose:** Extended DivKit functionality
**Integration Method:** Framework dependency
**Version:** ~> 31.13.0

### 5.3. UIKit Framework
**Purpose:** iOS UI foundation and layout system
**Integration Method:** System framework

### 5.4. Foundation Framework
**Purpose:** Core iOS functionality
**Integration Method:** System framework

### 5.5. System URL Handlers (iOS)
**Purpose:** External URL handling (Safari, Mail, Phone, Messages)
**Integration Method:** UIApplication.shared.open() with URL scheme resolution

## 6. Deployment & Infrastructure

**Distribution Method:** CocoaPods Trunk

**Build System:** Xcode Build System with xcodebuild

**CI/CD Pipeline:** GitHub Actions

**Publishing:** CocoaPods Trunk with automated workflow

**Target Platforms:** 
- iOS 17.0+
- Swift 5.9+

## 7. Security Considerations

**URL Validation:** Comprehensive URL parsing with error handling to prevent malformed URL crashes

**Intent Resolution:** System app verification before launching external applications via `canOpenURL()`

**Thread Safety:** All UI operations dispatched to main thread

**Resource Cleanup:** Proper lifecycle management to prevent memory leaks and resource retention

**Weak References:** Usage of weak delegates to prevent retain cycles

## 8. Development & Testing Environment

**Local Setup:** Xcode-based development with CocoaPods/SPM

**Testing Frameworks:** XCTest (inferred from structure)

**Code Quality:** Swift compiler warnings and static analysis

**Demo Integration:** Standalone example applications for testing and showcase

**Language:** Swift 5.9 with UIKit

## 9. Memory Management

### 9.1. ARC (Automatic Reference Counting)

The SDK uses Swift's ARC for memory management with specific patterns:

**Weak References:**
```swift
weak var errorDelegate: DivKitErrorDelegate?
```

**Capture Lists:**
```swift
DispatchQueue.main.async { [weak self] in
    self?.onCloseAction?()
}
```

**Cleanup Pattern:**
```swift
public func cleanup() {
    NSLayoutConstraint.deactivate(layoutConstraints)
    layoutConstraints.removeAll()
    divView?.removeFromSuperview()
    divView = nil
    gestureRecognizers?.forEach { removeGestureRecognizer($0) }
}
```

### 9.2. Resource Lifecycle

```
Creation → Configuration → Display → Interaction → Cleanup → Deallocation
```

**Critical Cleanup Points:**
- View removal from superview
- Constraint deactivation
- Gesture recognizer removal
- DivView cleanup
- deinit implementation

## 10. Threading Model

### 10.1. Main Thread Operations

All UI operations must occur on main thread:
- View creation and modification
- Constraint updates
- UIApplication.shared.open() calls
- Callback execution for UI handlers

### 10.2. Background Operations

Potential background operations:
- JSON parsing
- Data loading
- Network requests (via DivKit)

### 10.3. Thread Safety Pattern

```swift
DispatchQueue.main.async {
    // UI operations here
}
```

## 11. Error Handling

### 11.1. DivKit Error Handling

```swift
class CustomDivReporter: DivReporter {
    func reportError(cardId: DivCardID, error: any DivError) {
        print("Custom Div Reporter Error: \(error)")
        errorDelegate?.handleDivKitError(error, cardId: cardId)
    }
    
    func shouldDisplayError() -> Bool {
        return false  // Suppress default UI
    }
}
```

### 11.2. URL Handling Errors

```swift
if UIApplication.shared.canOpenURL(url) {
    UIApplication.shared.open(url) { success in
        if !success {
            print("❌ Failed to open URL: \(url.absoluteString)")
        }
    }
} else {
    print("❌ Cannot open URL: \(url.absoluteString)")
}
```

### 11.3. JSON Parsing Errors

```swift
do {
    let jsonData = try JSONSerialization.data(withJSONObject: jsonObject)
    setViewData(jsonData)
} catch {
    print("Error parsing JSON data: \(error)")
}
```

## 12. Performance Considerations

### 12.1. View Reuse

UnifiedActivationView should be reused when possible:
```swift
activationView?.cleanup()
activationView?.setViewDataFromJson(newData)
```

### 12.2. Constraint Management

Constraints are managed efficiently:
- Deactivated before removal
- Cleared from array
- Reactivated with new configuration

### 12.3. Asynchronous Data Loading

DivKit data loaded asynchronously:
```swift
Task { @MainActor in
    await divView.setSource(.init(kind: .data(viewData)))
}
```

## 13. Future Considerations / Roadmap

### 13.1. Architectural Improvements
- **SwiftUI Support:** Consider SwiftUI wrapper for modern app development
- **Async/Await Enhancement:** Further adoption of Swift concurrency
- **Modularization:** Separate concerns into sub-modules

### 13.2. Performance Optimizations
- **View Recycling:** Implement view pooling for list-based activations
- **Image Caching:** Enhanced image caching strategies
- **Memory Optimization:** Further reduce memory footprint

### 13.3. API Surface Improvements
- **Result Types:** Replace optional callbacks with Result types
- **Combine Integration:** Support for Combine publishers
- **Documentation:** Enhanced DocC documentation

## 14. Cross-Platform Considerations

### 14.1. iOS/Android Parity

**Shared Concepts:**
- UnifiedActivationView approach (matches ActivationView on other platform)
- Configuration builder patterns
- URL handling and external integrations
- Template-based rendering (DivKit on both platforms)

**Platform Differences:**
- iOS uses UIKit, other platform uses Views
- iOS uses Auto Layout constraints, other platform uses layout parameters
- Different lifecycle management approaches
- Platform-specific URL scheme handling

### 14.2. Alignment Goals
- Consistent API surface across platforms
- Shared activation template formats
- Common configuration patterns and naming conventions

## 15. Project Identification

**Project Name:** SourceSync SDK UI iOS

**Primary Contact/Team:** Source Digital Development Team

**Repository:** https://github.com/Source-Digital/sourcesync-sdk-ui-ios

**Distribution:** CocoaPods 

## 16. Glossary / Acronyms

**DivKit:** Yandex's declarative UI framework for rendering JSON-based layouts

**ARC:** Automatic Reference Counting - Swift's memory management system

**Activation:** Interactive content overlay displayed during media playback

**Preview Mode:** Initial activation display encouraging user interaction

**Details Mode:** Expanded activation content shown after user engagement

**Template:** JSON structure defining activation appearance and behavior

**UIKit:** Apple's user interface framework for iOS

**Auto Layout:** Apple's constraint-based layout system

**Trunk:** CocoaPods' centralized specification repository

**XCFramework:** Apple's binary framework format supporting multiple platforms