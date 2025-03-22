//
//  ImageSegmentProcessor.swift
//  sourcesync-sdk-ui-ios
//

import UIKit

class ImageSegmentProcessor: SegmentProcessor {
    private let tag = "ImageSegmentProcessor"
    private static var imageLoader = ImageLoader()
    private let parentContainer: UIView
    
    init(parentContainer: UIView) {
        self.parentContainer = parentContainer
    }
    
    func processSegment(segment: [String: Any]) throws -> UIView {
        // Create a container view that will hold the image view
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        // Add image view to container
        containerView.addSubview(imageView)
        
        // Make image view fill the container by default
        NSLayoutConstraint.activate([
            imageView.leftAnchor.constraint(equalTo: containerView.leftAnchor),
            imageView.rightAnchor.constraint(equalTo: containerView.rightAnchor),
            imageView.topAnchor.constraint(equalTo: containerView.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
        
        if let attributesJson = segment["attributes"] as? [String: Any] {
            do {
                // Parse both standard and nested attributes
                let attributes = try SegmentAttributes.fromJson(json: attributesJson)
                
                // Handle contentMode
                if let alignment = attributes.alignment {
                    imageView.contentMode = alignmentToContentMode(alignment: alignment)
                } else if let contentMode = attributesJson["contentMode"] as? String {
                    imageView.contentMode = contentModeFromString(contentMode)
                }
                
                // Handle size attributes
                var hasFixedWidth = false
                var hasFixedHeight = false
                var isAutoHeight = false
                
                if let sizeDict = attributesJson["size"] as? [String: Any] {
                    // Process width value
                    if let widthValue = sizeDict["width"] {
                        hasFixedWidth = processWidth(widthValue, for: containerView)
                    }
                    
                    // Process height value
                    if let heightValue = sizeDict["height"] {
                        if let heightString = heightValue as? String, heightString == "auto" {
                            isAutoHeight = true
                            // For auto height, we'll let the image's aspect ratio determine the height
                        } else {
                            hasFixedHeight = processHeight(heightValue, for: containerView)
                        }
                    }
                } else {
                    // Handle width attribute directly
                    if let width = attributes.width {
                        hasFixedWidth = processWidth(width, for: containerView)
                    }
                    
                    // Handle height attribute directly
                    if let height = attributes.height {
                        if height == "auto" {
                            isAutoHeight = true
                        } else {
                            hasFixedHeight = processHeight(height, for: containerView)
                        }
                    }
                }
                
                // Apply minimum height if needed
                if isAutoHeight && !hasFixedHeight {
                    // Set a minimum height to ensure visibility before image loads
                    let minHeightConstraint = containerView.heightAnchor.constraint(greaterThanOrEqualToConstant: 50)
                    minHeightConstraint.priority = .defaultHigh - 10
                    minHeightConstraint.isActive = true
                }
                
                // Load the image
                if let imageUrl = segment["content"] as? String, !imageUrl.isEmpty {
                    Self.imageLoader.loadImage(urlString: imageUrl, imageView: imageView,
                                              preserveAspectRatio: isAutoHeight && hasFixedWidth)
                } else {
                    // No image URL, provide a placeholder appearance
                    imageView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
                }
                
            } catch {
                // Provide more detailed error information
                print("\(tag) Error parsing SegmentAttributes: \(error)")
                imageView.backgroundColor = UIColor.red.withAlphaComponent(0.3) // Error indicator
            }
        }
        
        return containerView
    }
    
    // Process width value and return true if it's a fixed width
    private func processWidth(_ width: Any, for view: UIView) -> Bool {
        if let widthInt = width as? Int {
            let constraint = view.widthAnchor.constraint(equalToConstant: CGFloat(widthInt))
            constraint.priority = .defaultHigh
            constraint.isActive = true
            return true
        } else if let widthFloat = width as? CGFloat {
            let constraint = view.widthAnchor.constraint(equalToConstant: widthFloat)
            constraint.priority = .defaultHigh
            constraint.isActive = true
            return true
        } else if let widthString = width as? String {
            if widthString == "auto" {
                return false
            } else if LayoutUtils.isValidPercentage(widthString) {
                do {
                    let widthDecimal = try LayoutUtils.percentageToDecimal(widthString)
                    if widthDecimal > 0 {
                        // IMPORTANT: DO NOT create a constraint between view and parentContainer
                        // Instead, we'll set a width constraint on this view that its parent
                        // can use to determine appropriate layout
                        
                        // Return false to indicate this isn't a fixed width
                        // The parent layout will handle the percentage constraints
                        return false
                    }
                } catch {
                    print("\(tag) Error processing width percentage: \(error)")
                }
                return false
            } else {
                // Try to parse as numeric value
                if let widthValue = NumberFormatter().number(from: widthString)?.doubleValue {
                    let constraint = view.widthAnchor.constraint(equalToConstant: CGFloat(widthValue))
                    constraint.priority = .defaultHigh
                    constraint.isActive = true
                    return true
                }
            }
        }
        return false
    }
    
    // Process height value and return true if it's a fixed height
    private func processHeight(_ height: Any, for view: UIView) -> Bool {
        if let heightInt = height as? Int {
            let constraint = view.heightAnchor.constraint(equalToConstant: CGFloat(heightInt))
            constraint.priority = .defaultHigh
            constraint.isActive = true
            return true
        } else if let heightFloat = height as? CGFloat {
            let constraint = view.heightAnchor.constraint(equalToConstant: heightFloat)
            constraint.priority = .defaultHigh
            constraint.isActive = true
            return true
        } else if let heightString = height as? String {
            if heightString == "auto" {
                return false
            } else if LayoutUtils.isValidPercentage(heightString) {
                do {
                    let heightDecimal = try LayoutUtils.percentageToDecimal(heightString)
                    if heightDecimal > 0 {
                        // IMPORTANT: DO NOT create a constraint between view and parentContainer
                        // Instead, we'll set a height constraint on this view that its parent
                        // can use to determine appropriate layout
                        
                        // Return false to indicate this isn't a fixed height
                        // The parent layout will handle the percentage constraints
                        return false
                    }
                } catch {
                    print("\(tag) Error processing height percentage: \(error)")
                }
                return false
            } else {
                // Try to parse as numeric value
                if let heightValue = NumberFormatter().number(from: heightString)?.doubleValue {
                    let constraint = view.heightAnchor.constraint(equalToConstant: CGFloat(heightValue))
                    constraint.priority = .defaultHigh
                    constraint.isActive = true
                    return true
                }
            }
        }
        return false
    }
    
    func getSegmentType() -> String {
        return "image"
    }
    
    // Converts alignment string to appropriate content mode
    private func alignmentToContentMode(alignment: String) -> UIView.ContentMode {
        switch alignment.lowercased() {
        case "left": return .left
        case "right": return .right
        case "center": return .scaleAspectFit
        default: return .scaleAspectFit
        }
    }
    
    // Converts contentMode string to UIView.ContentMode
    private func contentModeFromString(_ contentMode: String) -> UIView.ContentMode {
        switch contentMode.lowercased() {
        case "scaleaspectfit": return .scaleAspectFit
        case "scaleaspectfill": return .scaleAspectFill
        case "scaletofill": return .scaleToFill
        case "center": return .center
        case "top": return .top
        case "bottom": return .bottom
        case "left": return .left
        case "right": return .right
        case "topleft": return .topLeft
        case "topright": return .topRight
        case "bottomleft": return .bottomLeft
        case "bottomright": return .bottomRight
        default: return .scaleAspectFit
        }
    }
}

// Weak reference wrapper to prevent retain cycles
class WeakRef<T: AnyObject> {
    weak var value: T?
    init(value: T?) {
        self.value = value
    }
}
