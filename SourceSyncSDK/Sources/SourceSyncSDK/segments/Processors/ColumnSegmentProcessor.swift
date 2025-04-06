//
//  ColumnSegmentProcessor.swift
//  sourcesync-sdk-ui-ios
//

import UIKit

class ColumnSegmentProcessor: SegmentProcessor {
    private let processorFactory: SegmentProcessorFactory
    private let parentContainer: UIView
    private static let TAG = "ColumnSegmentProcessor"
    
    init(processorFactory: SegmentProcessorFactory, parentContainer: UIView) {
        self.processorFactory = processorFactory
        self.parentContainer = parentContainer
    }
    
    func processSegment(segment: [String: Any]) throws -> UIView {
        // Create a column container view
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = .clear // Changed from green to clear
        
        // Create a vertical stack view to hold items
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = .clear
        
        // Add stack view to container
        containerView.addSubview(stackView)
        
        // Pin stack view to container edges
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: containerView.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor)
        ])
        
        // Parse attributes if available
        if let attributesJson = segment["attributes"] as? [String: Any] {
            let attributes = try SegmentAttributes.fromJson(json: attributesJson)
            
            // Set column alignment
            if let alignment = attributes.alignment {
                stackView.alignment = LayoutUtils.getStackViewAlignment(from: alignment)
            } else {
                stackView.alignment = .fill
            }
            
            // Apply spacing between children
            if let spacingValue = attributes.spacing {
                stackView.spacing = LayoutUtils.getSpacingValue(from: spacingValue)
            } else {
                stackView.spacing = 10.0
            }
            
            // Process width attribute - apply the width constraint
            if let width = attributes.width {
                containerView.layer.name = "column-\(width)" // Keep this for debugging
                
                if width.hasSuffix("%") {
                    if let percentStr = width.components(separatedBy: "%").first,
                       let percent = Double(percentStr) {
                        // Get screen width in landscape orientation
                        let screenWidth = max(UIScreen.main.bounds.width, UIScreen.main.bounds.height)
                        
                        // Calculate actual width based on percentage of screen width
                        let widthValue = screenWidth * CGFloat(percent / 100.0)
                        
                        // Create width constraint with required priority
                        let widthConstraint = containerView.widthAnchor.constraint(equalToConstant: widthValue)
                        widthConstraint.priority = .required
                        widthConstraint.isActive = true
                        
                        print("\(ColumnSegmentProcessor.TAG): Column width set to \(width) = \(widthValue) points")
                    }
                } else if let widthValue = Int(width) {
                    // Handle absolute width in points
                    let constraint = containerView.widthAnchor.constraint(equalToConstant: CGFloat(widthValue))
                    constraint.priority = .required
                    constraint.isActive = true
                    
                    print("\(ColumnSegmentProcessor.TAG): Column width set to \(widthValue) points")
                }
            }
        } else {
            // Default alignment and spacing
            stackView.alignment = .fill
            stackView.spacing = 10.0
        }
        
        // Set content hugging and compression resistance priorities
        containerView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        containerView.setContentHuggingPriority(.defaultHigh, for: .vertical)
        containerView.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        containerView.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        
        // Process children elements
        if let children = segment["children"] as? [[String: Any]] {
            for childSegment in children {
                guard let childType = childSegment["type"] as? String else { continue }
                
                if let processor = processorFactory.getProcessor(for: childType) {
                    do {
                        // Process the child segment
                        let childView = try processor.processSegment(segment: childSegment)
                        
                        // Handle text views specifically to ensure they fill width
                        if childType == "text" {
                            childView.setContentHuggingPriority(.defaultLow, for: .horizontal)
                            childView.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
                        }
                        
                        // Add the child to the stack view
                        stackView.addArrangedSubview(childView)
                    } catch {
                        print("\(ColumnSegmentProcessor.TAG): Error processing child: \(error)")
                    }
                } else {
                    print("\(ColumnSegmentProcessor.TAG): No processor found for type: \(childType)")
                }
            }
        }
        
        return containerView
    }
    
    func getSegmentType() -> String {
        return "column"
    }
}
