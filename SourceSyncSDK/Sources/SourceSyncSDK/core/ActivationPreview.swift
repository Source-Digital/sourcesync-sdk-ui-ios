//
//  ActivationPreview.swift
//  sourcesync-sdk-ui-ios
//

import UIKit

// A view representing an activation preview with customizable content.
class ActivationPreview: UIView {
    private let contentContainer = UIStackView()
    private let processorFactory: SegmentProcessorFactory
    
    // Initializes the activation preview with provided data.
    // - Parameter data: JSON data for the preview.
    init(data: [String: Any]) {
        self.processorFactory = SegmentProcessorFactory(parentContainer: contentContainer)
        super.init(frame: .zero)
        initializeView(data: data)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Sets up the view with provided preview data.
    // - Parameter data: JSON dictionary containing preview configuration.
    private func initializeView(data: [String: Any]) {
        translatesAutoresizingMaskIntoConstraints = false
        
        contentContainer.backgroundColor = UIColor.black.withAlphaComponent(0.4)
//        contentContainer.layer.cornerRadius = 8
        contentContainer.axis = .vertical
        contentContainer.translatesAutoresizingMaskIntoConstraints = false
        addSubview(contentContainer)
        
        // Content container wraps content with padding and minimum size
        NSLayoutConstraint.activate([
            // Position at top left with padding
            contentContainer.topAnchor.constraint(equalTo: self.topAnchor, constant: 0),
            contentContainer.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0),
            
            // Add padding from end and bottom
            contentContainer.trailingAnchor.constraint(lessThanOrEqualTo: self.trailingAnchor, constant: -10),
            contentContainer.bottomAnchor.constraint(lessThanOrEqualTo: self.bottomAnchor, constant: -10),
            
            // Minimum dimensions
            contentContainer.widthAnchor.constraint(greaterThanOrEqualTo: widthAnchor, multiplier: 0.9),
            contentContainer.heightAnchor.constraint(greaterThanOrEqualTo: heightAnchor, multiplier: 0.8)
        ])
        // Apply background color and opacity
//        let opacity = (data["backgroundOpacity"] as? Double) ?? 0.66
//        let backgroundColor = UIColor(hex: data["backgroundColor"] as? String ?? "#000000")!.withAlphaComponent(CGFloat(opacity))
        
        // Process template if provided, otherwise create default template
        if let template = data["template"] as? [[String: Any]] {
            processTemplate(template)
        } else {
            processTemplate(createDefaultTemplate(from: data))
        }
    }
    
    // Processes the template to generate UI components.
    // - Parameter template: The array of segment data.
    private func processTemplate(_ template: [[String: Any]]) {
        for segment in template {
            if let segmentType = segment["type"] as? String {
                // Only process if segment type is "text"
                if segmentType == "text" {
                    if let processor = processorFactory.getProcessor(for: segmentType) {
                        do {
                            let segmentView = try processor.processSegment(segment: segment)
                            contentContainer.addArrangedSubview(segmentView)
                        } catch {
                            print("Error processing template: \(error.localizedDescription)")
                        }
                    }
                } else {
                    print("Skipping segment of type '\(segmentType)' - only 'text' segments are currently supported")
                }
            }
        }
        
        contentContainer.layoutIfNeeded()
    }
    
    // Creates a default template if no template is provided in the JSON.
    // - Parameter data: JSON data.
    // - Returns: Default template as an array.
    private func createDefaultTemplate(from data: [String: Any]) -> [[String: Any]] {
        var template: [[String: Any]] = []
        
        if let title = data["title"] as? String {
            template.append([
                "type": "text",
                "content": title,
                "attributes": [
                    "size": "lg",
                    "color": "#FFFFFF",
                    "weight": "bold",
                    "alignment": "left"
                ]
            ])
        }
        
        if let subtitle = data["subtitle"] as? String {
            template.append([
                "type": "text",
                "content": subtitle,
                "attributes": [
                    "size": "md",
                    "color": "#CCCCCC",
                    "style": "italic",
                    "alignment": "left"
                ]
            ])
        }
        
        return template
    }
}
