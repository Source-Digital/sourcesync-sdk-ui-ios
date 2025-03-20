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
                
                // Handle size attributes - check for nested structure first
                var widthDecimal: CGFloat = 1.0
                var heightDecimal: CGFloat = 1.0
                
                if let sizeDict = attributesJson["size"] as? [String: Any] {
                    // Handle nested size structure: "size": {"width": "100%", "height": "100%"}
                    if let widthPercent = sizeDict["width"] as? String {
                        widthDecimal = try LayoutUtils.percentageToDecimal(widthPercent)
                    }
                    if let heightPercent = sizeDict["height"] as? String {
                        heightDecimal = try LayoutUtils.percentageToDecimal(heightPercent)
                    }
                } else {
                    // Handle flat structure: "width": "100%", "height": "100%"
                    if let widthPercent = attributes.width {
                        widthDecimal = try LayoutUtils.percentageToDecimal(widthPercent)
                    }
                    if let heightPercent = attributes.height {
                        heightDecimal = try LayoutUtils.percentageToDecimal(heightPercent)
                    }
                }
                
                // Load the image
                if let imageUrl = segment["content"] as? String, !imageUrl.isEmpty {
                    Self.imageLoader.loadImage(urlString: imageUrl, imageView: imageView)
                }
                
            } catch {
                // Handle the error, e.g., log it or show an alert
                print("\(tag) Error parsing SegmentAttributes: \(error)")
            }
        }
        
        return containerView
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

class ImageLoader {
    func loadImage(urlString: String, imageView: UIImageView) {
        guard let url = URL(string: urlString) else { return }
        let imageViewRef = WeakRef(value: imageView)
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil, let image = UIImage(data: data) else {
                DispatchQueue.main.async {
                    imageViewRef.value?.backgroundColor = .gray
                }
                return
            }
            
            DispatchQueue.main.async {
                imageViewRef.value?.image = image
                imageViewRef.value?.backgroundColor = .clear
            }
        }.resume()
    }
}

// Weak reference wrapper to prevent retain cycles
class WeakRef<T: AnyObject> {
    weak var value: T?
    init(value: T?) {
        self.value = value
    }
}
