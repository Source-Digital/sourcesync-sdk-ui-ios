# SourceSync SDK UI iOS

A lightweight iOS library for rendering interactive content overlays using DivKit's flexible JSON-based rendering system.

## Overview

SourceSync SDK UI iOS provides production-ready UI components for displaying interactive content in your iOS applications. The library offers:

- **Unified content display** with flexible rendering modes
- **DivKit-powered rendering** for flexible JSON-based layouts
- **Configurable positioning** with alignment options
- **Smart interaction handling** with outside-tap detection
- **Efficient resource management** and memory cleanup
- **Custom URL handling** for deep links and external actions

## Installation

### CocoaPods (Recommended)

Add the dependency to your `Podfile`:

```ruby
pod 'SourceSyncSDK', '~> 0.3.27'
```

Then run:
```bash
pod install
```

## Quick Start

### Basic Integration

```swift
import SourceSyncSDK

class ViewController: UIViewController {
    private var activationView: UnifiedActivationView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showContent()
    }
    
    private func showContent() {
        // Create JSON data for your content
        let contentData: [String: Any] = createContentJson()
        
        // Configure the view
        let config = ActivationConfig.Builder()
            .setActivationPosition(ActivationPosition(
                screenWidth: view.bounds.width,
                screenHeight: view.bounds.height,
                alignment: .center
            ))
            .build()
        
        // Create and display the view
        activationView = UnifiedActivationView.createFromJson(
            json: contentData,
            config: config
        )
        
        guard let activationView = activationView else { return }
        
        view.addSubview(activationView)
        activationView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            activationView.topAnchor.constraint(equalTo: view.topAnchor),
            activationView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            activationView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            activationView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func createContentJson() -> [String: Any] {
        // Create your DivKit card structure
        return [
            "card": [
                "log_id": "content_card",
                "states": [
                    [
                        "state_id": 0,
                        "div": [
                            "type": "text",
                            "text": "Hello World",
                            "font_size": 24,
                            "text_color": "#000000"
                        ]
                    ]
                ]
            ]
        ]
    }
    
    deinit {
        activationView?.cleanup()
    }
}
```

### Displaying Content with Click Handlers

```swift
private func showPreviewContent() {
    let previewData = loadJsonFromAssets("preview.json")
    let detailData = loadJsonFromAssets("details.json")
    
    // Configure with click handler
    let config = ActivationConfig.Builder()
        .setPreviewClickHandler { [weak self] in
            self?.showDetailContent(detailData)
        }
        .setActivationPosition(ActivationPosition(
            screenWidth: view.bounds.width,
            screenHeight: view.bounds.height,
            alignment: .bottomTrailing
        ))
        .build()
    
    // Create and display preview
    activationView = UnifiedActivationView.createFromJson(
        json: previewData,
        config: config
    )
    
    guard let activationView = activationView else { return }
    view.addSubview(activationView)
    setupConstraints(for: activationView)
}

private func showDetailContent(_ detailData: [String: Any]) {
    // Clean up preview
    activationView?.cleanup()
    activationView?.removeFromSuperview()
    
    // Configure details with close handlers
    let config = ActivationConfig.Builder()
        .setDetailsCloseHandler { [weak self] in
            self?.hideContent()
        }
        .setOutsideClickHandler { [weak self] in
            self?.hideContent()
        }
        .setUrlActionHandler {
            print("URL action triggered")
        }
        .setActivationPosition(ActivationPosition(
            screenWidth: view.bounds.width,
            screenHeight: view.bounds.height,
            alignment: .center
        ))
        .build()
    
    // Create and display details
    activationView = UnifiedActivationView.createFromJson(
        json: detailData,
        config: config
    )
    
    guard let activationView = activationView else { return }
    view.addSubview(activationView)
    setupConstraints(for: activationView)
}

private func hideContent() {
    activationView?.cleanup()
    activationView?.removeFromSuperview()
    activationView = nil
}

private func setupConstraints(for view: UIView) {
    view.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
        view.topAnchor.constraint(equalTo: self.view.topAnchor),
        view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
        view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
        view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
    ])
}
```

## Core Components

### UnifiedActivationView

The primary UI component for displaying content overlays.

```swift
// Create from JSON
let view = UnifiedActivationView.createFromJson(
    json: jsonData,
    config: config
)

// Create from Data
let view = UnifiedActivationView.createFromDivData(
    divData: data,
    config: config
)

// Clean up resources
view.cleanup()
```

### ActivationConfig

Configuration builder for activation behavior and appearance.

```swift
let config = ActivationConfig.Builder()
    // Set click handler for preview
    .setPreviewClickHandler {
        showDetails()
    }
    
    // Handle URL actions (links, deep links)
    .setUrlActionHandler {
        trackAction()
    }
    
    // Handle details close button
    .setDetailsCloseHandler {
        hideDetails()
    }
    
    // Handle outside taps (dismiss)
    .setOutsideClickHandler {
        hideDetails()
    }
    
    // Set positioning
    .setActivationPosition(ActivationPosition(
        screenWidth: screenWidth,
        screenHeight: screenHeight,
        alignment: .bottomTrailing
    ))
    
    // Enable/disable visual error indicators
    .setVisualErrorsEnabled(false)
    
    .build()
```

## Positioning & Alignment

### Alignment Options

```swift
public enum Alignment {
    case topLeading      // Top-left corner
    case topTrailing     // Top-right corner
    case bottomLeading   // Bottom-left corner
    case bottomTrailing  // Bottom-right corner
    case center          // Center of screen
}
```

### Example: Bottom-Right Positioning

```swift
let position = ActivationPosition(
    screenWidth: UIScreen.main.bounds.width,
    screenHeight: UIScreen.main.bounds.height,
    alignment: .bottomTrailing
)

let config = ActivationConfig.Builder()
    .setActivationPosition(position)
    .build()
```

## JSON Template Structure

### Preview Template

```json
{
  "card": {
    "log_id": "preview_card",
    "states": [
      {
        "state_id": 0,
        "div": {
          "type": "container",
          "items": [
            {
              "type": "text",
              "text": "Tap to learn more",
              "font_size": 16,
              "text_color": "#FFFFFF"
            }
          ]
        }
      }
    ]
  }
}
```

### Details Template

```json
{
  "card": {
    "log_id": "details_card",
    "states": [
      {
        "state_id": 0,
        "div": {
          "type": "container",
          "orientation": "vertical",
          "items": [
            {
              "type": "image",
              "image_url": "https://example.com/image.jpg",
              "width": {
                "type": "match_parent"
              }
            },
            {
              "type": "text",
              "text": "Detailed content here",
              "font_size": 18
            },
            {
              "type": "text",
              "text": "Close",
              "actions": [
                {
                  "log_id": "close_action",
                  "url": "div-action://close"
                }
              ]
            }
          ]
        }
      }
    ]
  }
}
```

## Advanced Features

### Custom URL Handling

The SDK automatically handles various URL schemes:

- `div-action://close` - Closes details view
- `http://` / `https://` - Opens in Safari
- `mailto:` - Opens Mail app
- `tel:` - Opens Phone app
- `sms:` - Opens Messages app
- Custom schemes - Triggers URL action handler

### Outside Tap Detection

Automatically detects taps outside the activation view while preserving video control functionality:

```swift
let config = ActivationConfig.Builder()
    .setOutsideClickHandler { [weak self] in
        // User tapped outside - dismiss details
        self?.hideActivationDetails()
    }
    .build()
```

The SDK intelligently ignores taps in the bottom 100pt area to preserve video controls.

### Resource Management

Always clean up resources to prevent memory leaks:

```swift
deinit {
    // Clean up activation view
    activationView?.cleanup()
}
```

## Complete Example

Here's a complete example showing preview-to-details flow:

```swift
import UIKit
import SourceSyncSDK

class ContentViewController: UIViewController {
    private var currentView: UnifiedActivationView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Show preview after 2 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            self?.showPreview()
        }
    }
    
    private func showPreview() {
        guard let previewJson = loadJsonFromAssets("preview_template.json") else { return }
        
        let config = ActivationConfig.Builder()
            .setPreviewClickHandler { [weak self] in
                print("Preview tapped")
                self?.showDetails()
            }
            .setActivationPosition(ActivationPosition(
                screenWidth: view.bounds.width,
                screenHeight: view.bounds.height,
                alignment: .bottomTrailing
            ))
            .build()
        
        currentView = UnifiedActivationView.createFromJson(
            json: previewJson,
            config: config
        )
        
        guard let currentView = currentView else { return }
        view.addSubview(currentView)
        setupFullScreenConstraints(for: currentView)
    }
    
    private func showDetails() {
        // Clean up preview
        currentView?.cleanup()
        currentView?.removeFromSuperview()
        
        guard let detailJson = loadJsonFromAssets("detail_template.json") else { return }
        
        let config = ActivationConfig.Builder()
            .setDetailsCloseHandler { [weak self] in
                self?.hideContent()
            }
            .setOutsideClickHandler { [weak self] in
                self?.hideContent()
            }
            .setUrlActionHandler {
                print("URL action triggered")
            }
            .setActivationPosition(ActivationPosition(
                screenWidth: view.bounds.width,
                screenHeight: view.bounds.height,
                alignment: .center
            ))
            .build()
        
        currentView = UnifiedActivationView.createFromJson(
            json: detailJson,
            config: config
        )
        
        guard let currentView = currentView else { return }
        view.addSubview(currentView)
        setupFullScreenConstraints(for: currentView)
    }
    
    private func hideContent() {
        currentView?.cleanup()
        currentView?.removeFromSuperview()
        currentView = nil
    }
    
    private func setupFullScreenConstraints(for activationView: UIView) {
        activationView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            activationView.topAnchor.constraint(equalTo: view.topAnchor),
            activationView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            activationView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            activationView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func loadJsonFromAssets(_ fileName: String) -> [String: Any]? {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: nil),
              let data = try? Data(contentsOf: url),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return nil
        }
        return json
    }
    
    deinit {
        hideContent()
    }
}
```

## Troubleshooting

### Content Not Showing

1. **Verify JSON structure**
   ```swift
   let config = ActivationConfig.Builder()
       .setVisualErrorsEnabled(true)  // Shows DivKit errors
       .build()
   ```

2. **Check container setup**
   ```swift
   guard let activationView = activationView else {
       print("ActivationView is nil")
       return
   }
   ```

3. **Validate JSON format**
   - Ensure `card` and `states` objects are present
   - Check for valid DivKit syntax

### Memory Leaks

Always call `cleanup()` on UnifiedActivationView instances:

```swift
deinit {
    activationView?.cleanup()
}
```

### Layout Issues

Ensure proper constraint setup:

```swift
activationView.translatesAutoresizingMaskIntoConstraints = false
NSLayoutConstraint.activate([
    // Your constraints
])
```

## Requirements

- **iOS**: 17.0+
- **Swift**: 5.9+
- **Xcode**: 16.0+

## Dependencies

The SDK automatically includes:

- DivKit (~> 31.13.0)
- DivKitExtensions (~> 31.13.0)

## Demo Applications

Explore the example app for complete integration examples:

```bash
cd MobileDemo
pod install
open MobileDemo.xcworkspace
```

## Best Practices

1. **Always clean up resources** - Call `cleanup()` in deinit
2. **Use weak references** - Prevent retain cycles in closures
3. **Handle optionals safely** - Use guard/if let patterns
4. **Test on real devices** - Simulators may behave differently
5. **Cache templates** - Load JSON once and reuse
6. **Enable debugging** - Use visual errors during development

## Support & Documentation

- **Issues**: [GitHub Issues](https://github.com/Source-Digital/sourcesync-sdk-ui-ios/issues)
- **Documentation**: [docs/](./docs/)
- **Setup Guide**: [docs/setup.md](./docs/setup.md)
- **Architecture**: [docs/architecture.md](./docs/architecture.md)
- **UI Guidelines**: [docs/ui-guidelines.md](./docs/ui-guidelines.md)
- **Dependencies**: [docs/dependencies.md](./docs/dependencies.md)
- **CI/CD**: [docs/cicd.md](./docs/cicd.md)

## License

Copyright © 2025 Source Digital, Inc.

Licensed under the MIT License. See [LICENSE.md](LICENSE.md) for details.