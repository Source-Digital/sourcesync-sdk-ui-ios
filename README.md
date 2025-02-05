# SourceSync SDK UI iOS

A flexible and modular iOS SDK for rendering dynamic UI components from JSON templates. This SDK provides a powerful way to create and manage UI elements programmatically, with support for various segment types and customizable layouts.

## Features

- Dynamic UI rendering from JSON templates
- Modular segment processor architecture
- Support for multiple UI components:
  - Text segments with rich text formatting
  - Image segments with remote image loading
  - Button segments with customizable styles
  - Row and Column layouts for complex arrangements
- Flexible attribute system for styling
- Percentage-based layout calculations
- Responsive design support
- Built-in hex color support
- Density-independent pixel (DP) calculations

## Architecture

The SDK follows a processor-based architecture pattern with the following key components:

### Core Components

- `Activation`: Main container view managing preview and detail states
- `ActivationPreview`: Preview view with customizable template
- `ActivationDetail`: Detailed view with scrollable content
- `ActivationHeader`: Header component with close button

### Segment System

- `SegmentProcessor`: Protocol defining the interface for segment processing
- `SegmentProcessorFactory`: Factory class managing different segment processors
- `SegmentAttributes`: Class handling UI attribute parsing and management

### Segment Processors

- `TextSegmentProcessor`: Handles text rendering with rich formatting
- `ImageSegmentProcessor`: Manages image loading and display
- `ButtonSegmentProcessor`: Creates interactive buttons
- `RowSegmentProcessor`: Handles horizontal layouts
- `ColumnSegmentProcessor`: Manages vertical layouts

### Utilities

- `LayoutUtils`: Helper functions for layout calculations
- `Extensions`: UIColor extensions for hex color support

## Usage

### Basic Implementation

```swift
let activation = Activation()

// Show preview
let previewData: [String: Any] = [
    "backgroundColor": "#000000",
    "backgroundOpacity": 0.66,
    "title": "Preview Title",
    "subtitle": "Preview Subtitle"
]

activation.showPreview(previewData: previewData) {
    // Handle preview tap
}

// Show detail
let detailTemplate: [[String: Any]] = [
    [
        "type": "text",
        "content": "Hello World",
        "attributes": [
            "size": "lg",
            "color": "#FFFFFF",
            "weight": "bold"
        ]
    ]
]

let detailData: [String: Any] = ["template": detailTemplate]

activation.showDetail(detailData: detailData) {
    // Handle close action
}
```

### Creating Custom Segments

1. Create a new class implementing the `SegmentProcessor` protocol:

```swift
class CustomSegmentProcessor: SegmentProcessor {
    func processSegment(segment: [String: Any]) throws -> UIView {
        // Process segment data and return UIView
    }
    
    func getSegmentType() -> String {
        return "custom"
    }
}
```

2. Register the processor with the factory:

```swift
let factory = SegmentProcessorFactory(parentContainer: view)
factory.registerProcessor(CustomSegmentProcessor())
```

## Styling

### Supported Attributes

- Font properties: `font`, `fontSize`, `weight`, `style`
- Colors: `color`, `backgroundColor`, `textColor`
- Layout: `width`, `height`, `spacing`, `alignment`
- Text decoration: `underline`
- Content display: `contentMode`

### Size Values

Font sizes can be specified using predefined values:
- `xxs`: 6dp
- `xs`: 10dp
- `sm`: 14dp
- `md`: 16dp
- `lg`: 20dp
- `xl`: 24dp
- `xxl`: 32dp

### Alignment Options

Supported alignment values:
- `left`
- `right`
- `center`
- `justified` (text only)

## Requirements

- iOS 16.0+
- Xcode 14.0+
- Swift 5.0+

## Installation

1. Add the SDK to your Xcode project
2. Import the required frameworks
3. Initialize the SDK components as needed

## License

Copyright 2025 Source Digital

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

## Contributing

We welcome contributions to improve the SourceSync SDK UI iOS! Please follow these guidelines:

### Getting Started

1. Fork the repository
2. Create a new branch for your feature or bugfix: `git checkout -b feature/your-feature-name`
3. Make your changes
4. Test your changes thoroughly
5. Create a pull request

### Code Style

- Follow Apple's [Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines/)
- Use clear, descriptive variable and function names
- Add comments for complex logic or non-obvious implementations
- Maintain consistent spacing and indentation
- Keep functions focused and concise

### Documentation

- Update the README.md if you're adding or modifying features
- Include inline documentation for public interfaces
- Add code examples for new functionality
- Update any affected documentation

### Testing

- Add unit tests for new functionality
- Ensure all existing tests pass
- Test on different iOS versions if making UI changes
- Include test cases for edge cases and error conditions

### Pull Request Process

1. Update the CHANGELOG.md with your changes
2. Ensure your code follows our style guidelines
3. Include relevant tests for your changes
4. Update documentation as needed
5. Ensure your branch is up to date with the main branch
6. Submit your pull request with a clear description of the changes

### Commit Messages

- Use clear, descriptive commit messages
- Start with a verb in the present tense
- Keep the first line under 72 characters
- Include more detailed explanation in the commit body if needed

Example:
```
Add image caching to ImageSegmentProcessor

- Implement LRU cache for downloaded images
- Add cache size limit configuration
- Include cache clearing mechanism
```

### Questions or Issues?

If you have questions or run into issues, please:
1. Check existing issues and pull requests
2. Create a new issue with a clear description
3. Use issue templates if available
4. Include relevant code samples and error messages