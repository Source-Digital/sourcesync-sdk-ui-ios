//
//  ImageSegmentProcessor.swift
//  sourcesync-sdk-ui-ios
//

import UIKit

class ImageSegmentProcessor: SegmentProcessor {
    private static let TAG = "ImageSegmentProcessor"
    private static let DEFAULT_CORNER_RADIUS_DP: Float = 12.0 // Same as Android
    private weak var parentContainer: UIView?
    
    init(parentContainer: UIView) {
        self.parentContainer = parentContainer
    }
    
    func processSegment(segment: [String: Any]) throws -> UIView {
        // Create a container view that will hold the image view
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = .clear // Changed from red to clear
        
        // Create the image view
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit // Default, equivalent to FIT_CENTER
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.clipsToBounds = true // Needed for corner radius
        
        // Add image view to container
        containerView.addSubview(imageView)
        
        // Make image view fill the container exactly with no padding
        NSLayoutConstraint.activate([
            imageView.leftAnchor.constraint(equalTo: containerView.leftAnchor),
            imageView.rightAnchor.constraint(equalTo: containerView.rightAnchor),
            imageView.topAnchor.constraint(equalTo: containerView.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
        
        // Set default corner radius
        let cornerRadiusPx = CGFloat(ImageSegmentProcessor.DEFAULT_CORNER_RADIUS_DP) * (UIScreen.main.bounds.width / 375.0)
        imageView.layer.cornerRadius = cornerRadiusPx
        
        // Process attributes if available
        if let attributesJson = segment["attributes"] as? [String: Any] {
            try processAttributes(attributesJson, containerView: containerView, imageView: imageView)
        }
        
        // Set content hugging and compression resistance to ensure proper sizing
        containerView.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        containerView.setContentHuggingPriority(.defaultHigh, for: .vertical)
        containerView.setContentCompressionResistancePriority(.required, for: .horizontal)
        containerView.setContentCompressionResistancePriority(.required, for: .vertical)
        
        // Load the image
        if let imageUrl = segment["content"] as? String, !imageUrl.isEmpty {
            print("\(ImageSegmentProcessor.TAG): Starting image load for URL: \(imageUrl)")
            
            if let url = URL(string: imageUrl) {
                // Use a placeholder while loading
                imageView.backgroundColor = .clear
                loadImage(url: url, imageView: imageView)
            }
        } else {
            // No image URL, provide a placeholder appearance
            imageView.backgroundColor = UIColor.lightGray
        }
        
        return containerView
    }
    
    // Separate function for processing attributes
    private func processAttributes(_ attributesJson: [String: Any], containerView: UIView, imageView: UIImageView) throws {
        let attributes = try SegmentAttributes.fromJson(json: attributesJson)
        
        // Handle content mode / scale type
        if let alignment = attributes.alignment {
            imageView.contentMode = LayoutUtils.alignmentToContentMode(alignment: alignment)
        } else if let contentMode = attributesJson["contentMode"] as? String {
            // Process content mode from JSON
            handleContentMode(contentMode, imageView: imageView)
        }
        
        // Handle corner radius if specified in attributes
        if let cornerRadiusValue = attributesJson["cornerRadius"] as? NSNumber {
            let radiusPx = CGFloat(cornerRadiusValue.floatValue) * (UIScreen.main.bounds.width / 375.0)
            imageView.layer.cornerRadius = radiusPx
        }
        
        // Handle size attributes
        processSizeAttributes(attributesJson: attributesJson, attributes: attributes, containerView: containerView)
    }
    
    // Helper to process content mode
    private func handleContentMode(_ contentModeStr: String, imageView: UIImageView) {
        switch contentModeStr.lowercased() {
        case "scaletofill":
            imageView.contentMode = .scaleToFill
        case "scaleaspectfit":
            imageView.contentMode = .scaleAspectFit
        case "scaleaspectfill":
            imageView.contentMode = .scaleAspectFill
        case "center":
            imageView.contentMode = .center
        default:
            imageView.contentMode = .scaleAspectFit // Default
        }
    }
    
    // Process size attributes with special handling for percentages
    private func processSizeAttributes(attributesJson: [String: Any], attributes: SegmentAttributes, containerView: UIView) {
        // Get screen width as reference for percentage calculations
        let screenWidth = UIScreen.main.bounds.width
        
        // Handle size attributes
        if let sizeObj = attributesJson["size"] as? [String: Any] {
            // Process width value
            if let widthStr = sizeObj["width"] as? String {
                if widthStr.hasSuffix("%") {
                    // Handle percentage width
                    if let percentStr = widthStr.components(separatedBy: "%").first,
                       let percent = Double(percentStr) {
                        // Calculate actual width based on screen width
                        let widthValue = screenWidth * CGFloat(percent / 100.0)
                        
                        // Create width constraint
                        let constraint = containerView.widthAnchor.constraint(equalToConstant: widthValue)
                        constraint.priority = .defaultHigh
                        constraint.isActive = true
                    }
                } else if let widthValue = Int(widthStr) {
                    // Handle numeric width
                    containerView.widthAnchor.constraint(equalToConstant: CGFloat(widthValue)).isActive = true
                }
            } else if let widthValue = sizeObj["width"] as? Int {
                containerView.widthAnchor.constraint(equalToConstant: CGFloat(widthValue)).isActive = true
            }
            
            // Process height value
            if let heightStr = sizeObj["height"] as? String {
                if heightStr.hasSuffix("%") {
                    // Handle percentage height
                    if let percentStr = heightStr.components(separatedBy: "%").first,
                       let percent = Double(percentStr) {
                        // Calculate actual height based on screen width (for aspect ratio consistency)
                        let heightValue = screenWidth * CGFloat(percent / 100.0)
                        
                        // Create height constraint
                        let constraint = containerView.heightAnchor.constraint(equalToConstant: heightValue)
                        constraint.priority = .defaultHigh
                        constraint.isActive = true
                    }
                } else if heightStr == "auto" {
                    // For auto height, set a minimum height
                    let minHeight = 50.0 * (screenWidth / 375.0)
                    containerView.heightAnchor.constraint(greaterThanOrEqualToConstant: minHeight).isActive = true
                } else if let heightValue = Int(heightStr) {
                    // Handle numeric height
                    containerView.heightAnchor.constraint(equalToConstant: CGFloat(heightValue)).isActive = true
                }
            } else if let heightValue = sizeObj["height"] as? Int {
                containerView.heightAnchor.constraint(equalToConstant: CGFloat(heightValue)).isActive = true
            }
        } else {
            // Handle width/height attributes directly if they exist
            if let width = attributes.width {
                if width.hasSuffix("%") {
                    if let percentStr = width.components(separatedBy: "%").first,
                       let percent = Double(percentStr) {
                        let widthValue = screenWidth * CGFloat(percent / 100.0)
                        containerView.widthAnchor.constraint(equalToConstant: widthValue).isActive = true
                    }
                } else if let widthValue = Int(width) {
                    containerView.widthAnchor.constraint(equalToConstant: CGFloat(widthValue)).isActive = true
                }
            }
            
            if let height = attributes.height {
                if height.hasSuffix("%") {
                    if let percentStr = height.components(separatedBy: "%").first,
                       let percent = Double(percentStr) {
                        let heightValue = screenWidth * CGFloat(percent / 100.0)
                        containerView.heightAnchor.constraint(equalToConstant: heightValue).isActive = true
                    }
                } else if height == "auto" {
                    let minHeight = 50.0 * (screenWidth / 375.0)
                    containerView.heightAnchor.constraint(greaterThanOrEqualToConstant: minHeight).isActive = true
                } else if let heightValue = Int(height) {
                    containerView.heightAnchor.constraint(equalToConstant: CGFloat(heightValue)).isActive = true
                }
            }
        }
    }
    
    private func loadImage(url: URL, imageView: UIImageView) {
        URLSession.shared.dataTask(with: url) { [weak imageView] data, response, error in
            guard let imageView = imageView else { return }
            
            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    imageView.image = image
                    imageView.backgroundColor = .clear
                    
                    // Force layout to ensure the container resizes properly
                    imageView.superview?.setNeedsLayout()
                    imageView.superview?.layoutIfNeeded()
                }
            } else {
                DispatchQueue.main.async {
                    imageView.backgroundColor = UIColor(white: 0.66, alpha: 1.0) // Error state
                }
            }
        }.resume()
    }
    
    func getSegmentType() -> String {
        return "image"
    }
}
