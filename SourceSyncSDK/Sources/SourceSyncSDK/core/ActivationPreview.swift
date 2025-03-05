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
        contentContainer.axis = .vertical
        contentContainer.translatesAutoresizingMaskIntoConstraints = false
        addSubview(contentContainer)
        
        NSLayoutConstraint.activate([
            contentContainer.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentContainer.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentContainer.topAnchor.constraint(equalTo: topAnchor),
            contentContainer.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        // Apply background color and opacity
        let opacity = (data["backgroundOpacity"] as? Double) ?? 0.66
        let backgroundColor = UIColor(hex: data["backgroundColor"] as? String ?? "#000000")!.withAlphaComponent(CGFloat(opacity))
        contentContainer.backgroundColor = backgroundColor
        
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
            if let segmentType = segment["type"] as? String,
               let processor = processorFactory.getProcessor(for: segmentType) {
                do {
                    let segmentView = try processor.processSegment(segment: segment)
                    contentContainer.addArrangedSubview(segmentView)
                } catch {
                    print("Error processing template: \(error.localizedDescription)")
                }
            }
        }
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
