# SourceSync SDK UI for iOS

A powerful, flexible UI rendering engine for iOS that transforms JSON templates into native UIKit components. Create dynamic, responsive interfaces with a declarative API.

## Overview

SourceSync SDK UI provides a modular and extensible architecture for rendering UI components from JSON definitions. The SDK manages activation flows with preview and detail views that can be easily integrated into any iOS application.

## Features

- **Activation Flow Management**: Complete activation lifecycle from preview to detailed views
- **JSON Template Rendering**: Transform JSON data into rich, interactive native UI components
- **Seamless Integration**: Simple API for embedding activation views in your app
- **Customizable Actions**: Handle user interactions with configurable action handlers
- **Responsive Layouts**: Adaptive interfaces that work across different screen sizes
- **Memory Efficient**: Automatic view lifecycle management and cleanup

## Core Architecture

The SDK is built around a clean, modular architecture with four main components:

### 1. ActivationView (Main Interface)
The primary container that manages the entire activation flow. It coordinates between preview and detail states and handles user interactions.

### 2. ActivationPreview
Displays the initial activation content using JSON template data. This view is typically shown during media playback or other content consumption.

### 3. ActivationDetails  
Renders detailed activation content when users interact with the preview. Supports rich interactive elements and custom actions.

### 4. Custom Action Handlers
Extensible action handling system for managing user interactions like close actions, navigation, or custom business logic.

## Component Relationships

```
ActivationView (Container)
├── ActivationPreview (Initial State)
│   └── JSON Template → Native UI
└── ActivationDetails (Expanded State)
    ├── JSON Template → Native UI
    └── Action Handlers → Custom Logic
```

## Installation

Add SourceSync SDK UI to your project using your preferred dependency manager:

### Swift Package Manager

```swift
dependencies: [
    .package(url: "https://github.com/Source-Digital/sourcesync-sdk-ui-ios.git", from: "0.3.14")
]
```

### CocoaPods

```ruby
pod 'SourceSyncSDK', '~> 0.3.13'
```

## JSON Template Structure

### Preview Template Example
```json
{
  "states": [
    {
      "state_id": 0,
      "div": {
        "type": "container",
        "items": [
          {
            "type": "text",
            "text": "Tap to explore activation",
            "text_color": "#FFFFFF",
            "font_size": 18
          }
        ]
      }
    }
  ]
}
```

### Details Template Example
```json
{
  "states": [
    {
      "state_id": 0,
      "div": {
        "type": "container",
        "orientation": "vertical",
        "items": [
          {
            "type": "text",
            "text": "Activation Details",
            "text_color": "#FFFFFF",
            "font_size": 24,
            "font_weight": "bold"
          },
          {
            "type": "container",
            "orientation": "horizontal",
            "items": [
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
        ]
      }
    }
  ]
}
```

## View Lifecycle

The SDK manages view lifecycle automatically:

1. **Preview State**: Initial view with JSON template rendering
2. **Detail State**: Expanded view with rich interactive content  
3. **Cleanup**: Automatic memory management and view removal

## Requirements

- iOS 13.0+
- Swift 5.7+
- Xcode 13.0+
