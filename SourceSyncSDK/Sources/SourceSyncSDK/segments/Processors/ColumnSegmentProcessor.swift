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
        containerView.backgroundColor = .clear
        
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
            
            // Process width attribute - store it directly in the view's layer name for debugging
            if let width = attributes.width {
                containerView.layer.name = "column-\(width)"
                
                if width.hasSuffix("%") {
                    // Just for debugging - you can see this in the view debugger
                    print("\(ColumnSegmentProcessor.TAG): Column width set to \(width)")
                }
            }
        } else {
            // Default alignment and spacing
            stackView.alignment = .fill
            stackView.spacing = 10.0
        }
        
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
