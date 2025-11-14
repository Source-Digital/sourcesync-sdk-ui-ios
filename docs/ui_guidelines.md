# UI Guidelines

This guide provides comprehensive information on using, customizing, and styling UI components in the SourceSync SDK UI iOS library.

## Overview

The SourceSync SDK UI uses **DivKit** (Yandex's declarative UI framework) to render JSON-based layouts. This approach provides:

- **Flexibility**: Define UIs in JSON without code changes
- **Consistency**: Same templates work across platforms (iOS/other platforms)
- **Dynamic Updates**: Change layouts without app updates
- **Rich Components**: Text, images, buttons, containers, and more

## Core Components

### UnifiedActivationView

The primary UI component for displaying content overlays.

#### Component Features

- ✅ DivKit-powered rendering
- ✅ Configurable positioning and alignment
- ✅ Tap and touch handling
- ✅ Outside-tap detection
- ✅ Automatic resource cleanup
- ✅ Custom URL handling

#### Basic Usage

```swift
import SourceSyncSDK

// Create configuration
let config = ActivationConfig.Builder()
    .setActivationPosition(ActivationPosition(
        screenWidth: view.bounds.width,
        screenHeight: view.bounds.height,
        alignment: .center
    ))
    .build()

// Create view from JSON
let activationView = UnifiedActivationView.createFromJson(
    json: jsonData,
    config: config
)

// Add to container
view.addSubview(activationView)
activationView.translatesAutoresizingMaskIntoConstraints = false

NSLayoutConstraint.activate([
    activationView.topAnchor.constraint(equalTo: view.topAnchor),
    activationView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
    activationView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
    activationView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
])
```

#### Component Lifecycle

```
Create → Configure → Display → Interact → Cleanup
   ↓         ↓          ↓          ↓         ↓
 New     Config     addSubview   Tap      cleanup()
```

Always call `cleanup()` when removing the view to prevent memory leaks.

## Positioning & Layout

### Positioning System

UnifiedActivationView uses **Auto Layout constraints** with configurable alignment.

#### Alignment Options

```swift
public enum Alignment {
    case topLeading      // Top-left corner
    case topTrailing     // Top-right corner
    case bottomLeading   // Bottom-left corner
    case bottomTrailing  // Bottom-right corner
    case center          // Center of container
}
```

#### Common Positioning Patterns

**Top-Left Corner**
```swift
ActivationPosition(
    screenWidth: view.bounds.width,
    screenHeight: view.bounds.height,
    alignment: .topLeading
)
```

**Bottom-Right Corner** (Common for previews)
```swift
ActivationPosition(
    screenWidth: view.bounds.width,
    screenHeight: view.bounds.height,
    alignment: .bottomTrailing
)
```

**Full Center** (Common for details)
```swift
ActivationPosition(
    screenWidth: view.bounds.width,
    screenHeight: view.bounds.height,
    alignment: .center
)
```

**Top-Right**
```swift
ActivationPosition(
    screenWidth: view.bounds.width,
    screenHeight: view.bounds.height,
    alignment: .topTrailing
)
```

### Container Requirements

UnifiedActivationView can be added to any **UIView** container:

```swift
let containerView = view  // Any UIView subclass

containerView.addSubview(activationView)
activationView.translatesAutoresizingMaskIntoConstraints = false

// Setup constraints
NSLayoutConstraint.activate([
    activationView.topAnchor.constraint(equalTo: containerView.topAnchor),
    activationView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
    activationView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
    activationView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
])
```

**Why Auto Layout?**
- Supports constraint-based positioning
- Allows overlaying content
- Adapts to different screen sizes
- Native iOS layout system

### Layout Constraints

The SDK automatically calculates appropriate constraints based on alignment:

```swift
// Example: Bottom-trailing alignment results in:
// - bottomAnchor constraint
// - trailingAnchor constraint
// - topAnchor constraint
// - width multiplier (e.g., 0.5 for 50% width)
```

## DivKit Template Structure

### Basic Template Anatomy

```json
{
  "card": {
    "log_id": "unique_card_identifier",
    "states": [
      {
        "state_id": 0,
        "div": {
          "type": "container",
          "orientation": "vertical",
          "items": [
            // Child components
          ]
        }
      }
    ]
  }
}
```

### Required Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `card` | Object | ✅ Yes | Root card container |
| `card.log_id` | String | ✅ Yes | Unique identifier |
| `card.states` | Array | ✅ Yes | State definitions |
| `div` | Object | ✅ Yes | Root component |

## Component Library

### Container

Arranges child components vertically or horizontally.

```json
{
  "type": "container",
  "orientation": "vertical",
  "width": {"type": "match_parent"},
  "height": {"type": "wrap_content"},
  "background": [
    {
      "type": "solid",
      "color": "#000000"
    }
  ],
  "paddings": {
    "left": 16,
    "top": 16,
    "right": 16,
    "bottom": 16
  },
  "margins": {
    "left": 8,
    "top": 8,
    "right": 8,
    "bottom": 8
  },
  "items": [
    // Child components
  ]
}
```

**Common Uses**:
- Layout structure
- Content grouping
- Background containers

### Text

Displays formatted text content.

```json
{
  "type": "text",
  "text": "Hello World",
  "font_size": 18,
  "line_height": 24,
  "font_weight": "bold",
  "text_color": "#FFFFFF",
  "text_alignment_horizontal": "center",
  "text_alignment_vertical": "center",
  "max_lines": 2,
  "ellipsis": {
    "text": "...",
    "actions": []
  }
}
```

**Font Sizes**:
- Small: 12-14
- Medium: 16-18
- Large: 20-24
- Extra Large: 28+

### Image

Displays images from URLs.

```json
{
  "type": "image",
  "image_url": "https://example.com/image.jpg",
  "width": {
    "type": "fixed",
    "value": 200
  },
  "height": {
    "type": "fixed",
    "value": 200
  },
  "scale": "fit",
  "content_alignment_horizontal": "center",
  "content_alignment_vertical": "center",
  "placeholder_color": "#CCCCCC",
  "preview": "data:image/png;base64,..."
}
```

**Image Loading**: Powered by DivKit
- Automatic caching
- Memory efficient
- Placeholder support

### State

Allows switching between different UI states.

```json
{
  "type": "state",
  "id": "content_state",
  "states": [
    {
      "state_id": "loading",
      "div": {
        "type": "text",
        "text": "Loading..."
      }
    },
    {
      "state_id": "content",
      "div": {
        // Main content
      }
    }
  ]
}
```

## Actions & Interactions

### Click Actions

```json
{
  "type": "text",
  "text": "Click me",
  "actions": [
    {
      "log_id": "click_action",
      "url": "div-action://close"
    }
  ]
}
```

### Supported URL Schemes

| Scheme | Description | Example |
|--------|-------------|---------|
| `div-action://close` | Close details view | `div-action://close` |
| `http://`, `https://` | Open in Safari | `https://example.com` |
| `mailto:` | Open Mail app | `mailto:support@example.com` |
| `tel:` | Open Phone app | `tel:+1234567890` |
| `sms:` | Open Messages app | `sms:+1234567890` |
| Custom schemes | App deep links | `myapp://screen/detail` |

### Action Handlers

Configure handlers in ActivationConfig:

```swift
let config = ActivationConfig.Builder()
    .setPreviewClickHandler {
        // Handle preview tap
        print("Preview tapped")
    }
    .setUrlActionHandler {
        // Handle URL actions (links, deep links)
        print("URL action triggered")
    }
    .setDetailsCloseHandler {
        // Handle close button
        hideDetails()
    }
    .setOutsideClickHandler {
        // Handle taps outside view
        hideDetails()
    }
    .build()
```

## Styling Guidelines

### Color System

Use hex color codes for consistency:

```json
{
  "type": "container",
  "background": [
    {
      "type": "solid",
      "color": "#000000"
    }
  ]
}
```

**Alpha Channel Support**:
```json
"color": "#80000000"  // 50% transparent black
```

### Typography

**Font Weights**:
- `light` - 300
- `regular` - 400
- `medium` - 500
- `bold` - 700

**Best Practices**:
- Use 16pt minimum for body text
- Line height = font size × 1.5
- Limit to 2-3 font sizes per template

### Spacing System

Use consistent spacing scale:

```json
{
  "paddings": {
    "left": 16,
    "top": 16,
    "right": 16,
    "bottom": 16
  }
}
```

**Recommended Scale**:
- Extra Small: 4pt
- Small: 8pt
- Medium: 16pt
- Large: 24pt
- Extra Large: 32pt

### Background Styles

**Solid Color**
```json
"background": [
  {
    "type": "solid",
    "color": "#FFFFFF"
  }
]
```

**Gradient**
```json
"background": [
  {
    "type": "gradient",
    "angle": 45,
    "colors": ["#FF0000", "#0000FF"]
  }
]
```

**Image Background**
```json
"background": [
  {
    "type": "image",
    "image_url": "https://example.com/bg.jpg",
    "alpha": 0.5
  }
]
```

### Border & Corners

```json
{
  "type": "container",
  "border": {
    "stroke": {
      "color": "#CCCCCC",
      "width": 1
    },
    "corner_radius": 8
  }
}
```

## Responsive Design

### Size Types

**Fixed Size**
```json
"width": {
  "type": "fixed",
  "value": 200
}
```

**Match Parent**
```json
"width": {
  "type": "match_parent"
}
```

**Wrap Content**
```json
"width": {
  "type": "wrap_content"
}
```

### Aspect Ratio

Maintain aspect ratio for images and containers:

```json
{
  "type": "container",
  "width": {"type": "match_parent"},
  "aspect": {
    "ratio": 1.77
  }
}
```

## Accessibility

### Text Accessibility

```json
{
  "type": "text",
  "text": "Important message",
  "accessibility": {
    "description": "This is an important notification",
    "type": "button"
  }
}
```

### Image Accessibility

```json
{
  "type": "image",
  "image_url": "https://example.com/logo.png",
  "accessibility": {
    "description": "Company logo"
  }
}
```

### Best Practices

1. **Provide descriptions** for all images
2. **Use semantic types** (button, header, etc.)
3. **Ensure contrast ratios** meet WCAG standards (4.5:1 minimum)
4. **Support Dynamic Type** by using point sizes appropriately
5. **Test with VoiceOver** enabled

## Performance Optimization

### Image Optimization

1. **Use appropriate sizes** - Don't load 4K images for thumbnails
2. **Enable caching** - DivKit handles this automatically
3. **Use placeholders** - Provide base64 previews for faster loading
4. **Lazy load** - Only load images when needed

### Template Optimization

1. **Minimize nesting** - Keep hierarchy shallow (< 5 levels)
2. **Reuse templates** - Define common patterns once
3. **Avoid overdraw** - Don't layer unnecessary backgrounds
4. **Limit items** - Keep lists under 50 items per view

### Memory Management

```swift
deinit {
    // Always cleanup
    activationView?.cleanup()
}
```

## Debugging

### Visual Error Indicators

Enable visual errors to see rendering issues:

```swift
let config = ActivationConfig.Builder()
    .setVisualErrorsEnabled(true)  // Show red boxes on errors
    .build()
```

### DivKit Logs

Filter Console for DivKit messages:

```
# In Xcode console, filter by:
DivView OR DivKit OR CustomUrlHandler
```

### Common Issues

**Text Not Showing**
- Check `text_color` contrasts with background
- Verify `font_size` is appropriate
- Ensure container has proper size

**Image Not Loading**
- Verify URL is accessible
- Check network permissions in Info.plist
- Look for DivKit errors in console

**Layout Overflow**
- Use `wrap_content` instead of `match_parent`
- Check padding/margin values
- Verify container orientation

## Design Patterns

### Preview-Details Pattern

**Preview**: Compact, bottom-right positioned
```swift
ActivationPosition(
    screenWidth: view.bounds.width,
    screenHeight: view.bounds.height,
    alignment: .bottomTrailing
)
```

**Details**: Full-screen or centered overlay
```swift
ActivationPosition(
    screenWidth: view.bounds.width,
    screenHeight: view.bounds.height,
    alignment: .center
)
```

### Card Pattern

```json
{
  "type": "container",
  "orientation": "vertical",
  "width": {"type": "match_parent"},
  "background": [{"type": "solid", "color": "#FFFFFF"}],
  "border": {
    "corner_radius": 12,
    "stroke": {"color": "#E0E0E0", "width": 1}
  },
  "paddings": {"left": 16, "top": 16, "right": 16, "bottom": 16},
  "items": [
    // Content
  ]
}
```

### List Pattern

```json
{
  "type": "container",
  "orientation": "vertical",
  "items": [
    {
      "type": "separator",
      "delimiter_style": {
        "color": "#E0E0E0"
      }
    }
  ]
}
```

## Testing UI Components

### Visual Testing Checklist

- [ ] Test on different screen sizes (iPhone SE, Pro, Pro Max, iPad)
- [ ] Test both orientations (portrait, landscape)
- [ ] Test with Dynamic Type (larger text sizes)
- [ ] Test light and dark modes
- [ ] Test with slow network (image loading)
- [ ] Test accessibility with VoiceOver

### Example Test Template

```swift
func testActivationViewDisplay() {
    // Arrange
    let template = loadTestTemplate()
    let config = ActivationConfig.Builder()
        .setActivationPosition(ActivationPosition(
            screenWidth: 375,
            screenHeight: 812,
            alignment: .center
        ))
        .build()
    
    // Act
    let view = UnifiedActivationView.createFromJson(
        json: template,
        config: config
    )
    
    // Assert
    XCTAssertNotNil(view)
}
```

## Resources

### DivKit Documentation
- [DivKit GitHub](https://github.com/yandex/divkit)
- [DivKit Playground](https://divkit.tech/playground)
- [Component Reference](https://divkit.tech/doc)

### Related Documentation
- [README](../README.md) - Quick start guide
- [Setup Guide](setup.md) - Development environment
- [Architecture](architecture.md) - System design

## Best Practices Summary

1. ✅ **Always call cleanup()** when removing views
2. ✅ **Use Auto Layout** with proper constraints
3. ✅ **Test templates** in DivKit playground first
4. ✅ **Optimize images** for mobile displays
5. ✅ **Provide accessibility** descriptions
6. ✅ **Use consistent spacing** system
7. ✅ **Handle errors gracefully** with visual indicators
8. ✅ **Keep templates simple** - avoid deep nesting
9. ✅ **Cache templates** - load JSON once
10. ✅ **Test on real devices** - simulators can differ

## Swift-Specific Considerations

### Memory Management

```swift
// Use weak references in closures
config.setPreviewClickHandler { [weak self] in
    self?.showDetails()
}
```

### Thread Safety

```swift
// Ensure UI updates on main thread
DispatchQueue.main.async {
    self.activationView?.setViewDataFromJson(json)
}
```

### Optional Handling

```swift
// Safely unwrap optionals
guard let activationView = activationView else {
    return
}
```

### Async Data Loading

```swift
// DivKit uses async/await
Task { @MainActor in
    await divView.setSource(.init(kind: .data(viewData)))
}
```