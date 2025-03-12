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
        
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        
        // Default dimensions
        var width: CGFloat = UIView.noIntrinsicMetric
        var height: CGFloat = UIView.noIntrinsicMetric
        
        
        if let attributesJson = segment["attributes"] as? [String: Any] {
            do {
                let attributes = try SegmentAttributes.fromJson(json: attributesJson)
                
                if let alignment = attributes.alignment{
                    imageView.contentMode = alignmentToContentMode(alignment: alignment)
                }
                
                // Set size adjustments after layout
                imageView.translatesAutoresizingMaskIntoConstraints = false
                parentContainer.addSubview(imageView)
                
                NSLayoutConstraint.activate([
                    imageView.centerXAnchor.constraint(equalTo: parentContainer.centerXAnchor),
                    imageView.centerYAnchor.constraint(equalTo: parentContainer.centerYAnchor)
                ])
                
                if let widthPercent = attributes.width{
                    let widthDecimal = try LayoutUtils.percentageToDecimal(widthPercent)
                    width = parentContainer.frame.width * widthDecimal
                    imageView.widthAnchor.constraint(equalToConstant: width).isActive = true
                }
                if let heightPercent = attributes.height {
                    let heightDecimal = try LayoutUtils.percentageToDecimal( heightPercent)
                    height = parentContainer.frame.height * heightDecimal
                    imageView.heightAnchor.constraint(equalToConstant: height).isActive = true
                }
                
                if let imageUrl = segment["content"] as? String, !imageUrl.isEmpty {
                    Self.imageLoader.loadImage(urlString: imageUrl, imageView: imageView)
                }
                
            }catch {
                // Handle the error, e.g., log it or show an alert
                print("Error parsing SegmentAttributes: \(error)")
            }
        }
        
        return imageView
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
