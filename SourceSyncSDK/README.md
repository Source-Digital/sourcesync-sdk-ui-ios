# SourceSync SDK UI for iOS

A powerful, flexible UI rendering engine for iOS that transforms JSON templates into native UIKit components. Create dynamic, responsive interfaces with a declarative API.

## Overview

SourceSync SDK UI provides a modular and extensible architecture for rendering UI components from JSON definitions. The SDK supports various segment types that can be combined to create complex layouts with minimal code.

## Features

- **Declarative UI**: Define your interface in JSON and let SourceSync render it into native components
- **Responsive Layouts**: Supports percentage-based sizing for adaptive interfaces
- **Modular Architecture**: Easily extend with custom segment processors
- **Stack-based Layouts**: Row and column containers with customizable alignment and spacing
- **Rich Text Support**: Text styling including font sizing, colors, and weights
- **Web Content Integration**: Embed web content seamlessly with WebViews

## Supported Segment Types

### Text Segment

Renders text with customizable styling options including font size, weight, color, and alignment.

```json
{
  "type": "text",
  "content": "Your text content here",
  "attributes": {
    "font": "system",
    "size": "xl",
    "color": "#FFFFFF",
    "weight": "bold",
    "alignment": "center"
  }
}
```

### Button Segment

Creates interactive buttons with customizable appearance.

```json
{
  "type": "button",
  "content": "Primary Button",
  "attributes": {
    "backgroundColor": "#007AFF",
    "textColor": "#FFFFFF",
    "fontSize": "md",
    "weight": "semibold"
  }
}
```

### Image Segment

Displays images with support for content modes and corner radius.

```json
{
  "type": "image",
  "content": "https://example.com/image.png",
  "attributes": {
    "size": {
      "width": "50%",
      "height": "auto"
    },
    "contentMode": "scaleAspectFit",
    "cornerRadius": 8
  }
}
```

### WebView Segment

Embeds web content with configurable sizing options.

```json
{
  "type": "webview",
  "content": "https://example.com",
  "attributes": {
    "width": "100%",
    "height": "70%"
  }
}
```

### Column Segment

Vertical container that can hold multiple child segments.

```json
{
  "type": "column",
  "attributes": {
    "width": "90%",
    "alignment": "center",
    "spacing": "md"
  },
  "children": [
    // Child segments go here
  ]
}
```

### Row Segment

Horizontal container that can hold multiple child segments.

```json
{
  "type": "row",
  "attributes": {
    "alignment": "center",
    "spacing": "md"
  },
  "children": [
    // Child segments go here
  ]
}
```

## Sample Templates

### Preview Template

```json
{
  "template": [
    {
      "type": "text",
      "content": "Preview: Native Block Demo",
      "attributes": {
        "font": "system",
        "size": 24,
        "color": "#EEEEEE",
        "weight": "bold"
      }
    }
  ]
}
```

### Details Template

```json
{
  "template": [
    {
      "type": "text",
      "content": "Text Styling Examples",
      "attributes": {
        "font": "system",
        "size": "xl",
        "color": "#FFFFFF",
        "weight": "bold",
        "alignment": "center"
      }
    },
    {
      "type": "image",
      "content": "https://example.com/image.png",
      "attributes": {
        "size": {
          "width": "20%",
          "height": "20%"
        },
        "contentMode": "scaletofill",
        "alignment": "center"
      }
    },
    {
      "type": "row",
      "attributes": {
        "alignment": "center",
        "spacing": "md"
      },
      "children": [
        {
          "type": "column",
          "attributes": {
            "width": "50%",
            "alignment": "center"
          },
          "children": [
            {
              "type": "text",
              "content": "Left Column",
              "attributes": {
                "font": "system",
                "size": "md",
                "color": "#FFFFFF",
                "weight": "bold"
              }
            },
            {
              "type": "button",
              "content": "Primary Button",
              "attributes": {
                "backgroundColor": "#007AFF",
                "textColor": "#FFFFFF",
                "fontSize": "md",
                "weight": "semibold"
              }
            }
          ]
        },
        {
          "type": "column",
          "attributes": {
            "width": "50%",
            "alignment": "center"
          },
          "children": [
            {
              "type": "text",
              "content": "Right Column",
              "attributes": {
                "font": "system",
                "size": "md",
                "color": "#FFFFFF",
                "weight": "bold"
              }
            },
            {
              "type": "button",
              "content": "Secondary Button",
              "attributes": {
                "backgroundColor": "#5856D6",
                "textColor": "#FFFFFF",
                "fontSize": "md",
                "weight": "semibold"
              }
            }
          ]
        }
      ]
    }
  ]
}
```

## Common Attributes

All segments support these common attributes:

| Attribute | Type | Description |
|-----------|------|-------------|
| `width` | String | Width in points or percentage (e.g., "100", "50%") |
| `height` | String | Height in points or percentage (e.g., "100", "50%") |
| `alignment` | String | Content alignment ("left", "center", "right") |

## Installation

Add SourceSync SDK UI to your project using your preferred dependency manager:

### Swift Package Manager

```swift
dependencies: [
    .package(url: "https://github.com/Source-Digital/sourcesync-sdk-ui-ios.git", from: "1.0.0")
]
```

### CocoaPods

```ruby
pod 'SourceSyncSDK-UI', '~> 1.0'
```

## Usage

### Basic Integration

```swift
import SourceSyncSDK

class YourViewController: UIViewController {
    private let TAG = "YourViewController"
    private var activation: ActivationView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupActivation()
    }
    
    private func setupActivation() {
        // Load the templates from files
        guard let previewTemplate = TemplateLoader.loadTemplate(fileName: "preview_template"),
              let detailsTemplate = TemplateLoader.loadTemplate(fileName: "details_template") else {
            print("\(TAG): Failed to load templates")
            return
        }
        
        // Create activation view using the context initializer
        activation = ActivationView(context: self)
        
        // Add to view controller's view
        if let activation = activation {
            activation.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(activation)
            
            // Pin to edges
            NSLayoutConstraint.activate([
                activation.topAnchor.constraint(equalTo: view.topAnchor),
                activation.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                activation.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                activation.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
            
            // Show the preview with progress indicator
            let progressImageView = UIImage.gif(name: "activation_img") // Optional progress animation
            activation.showPreview(
                previewData: previewTemplate,
                showProgress: true,
                progressDuration: 10,
                progressImage: progressImageView
            ) {
                // When preview is clicked, show activation detail
                activation.showDetail(detailData: detailsTemplate) {
                    // When detail is dismissed
                    activation.hideDetail()
                }
            }
        }
    }
}
```

### Loading Templates

Templates can be loaded from local files or remote sources:

```swift
// From local JSON file
let templateFromFile = TemplateLoader.loadTemplate(fileName: "your_template")

// From JSON string
let jsonString = """
{
  "template": [
    {
      "type": "text",
      "content": "Hello World",
      "attributes": {
        "color": "#FFFFFF",
        "size": "lg"
      }
    }
  ]
}
"""
let templateFromString = TemplateLoader.parseTemplate(jsonString: jsonString)
```

## Requirements

- iOS 13.0+
- Swift 5.0+
- Xcode 13.0+

## License

This project is licensed under the MIT License - see the LICENSE file for details.
