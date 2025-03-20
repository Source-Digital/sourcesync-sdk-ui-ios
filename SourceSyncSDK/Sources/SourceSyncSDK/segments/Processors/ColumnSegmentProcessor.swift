//
//  ColumnSegmentProcessor.swift
//  sourcesync-sdk-ui-ios
//

import UIKit

class ColumnSegmentProcessor: SegmentProcessor {
    private let processorFactory: SegmentProcessorFactory
    private let parentContainer: UIView
    
    init(processorFactory: SegmentProcessorFactory, parentContainer: UIView) {
        self.processorFactory = processorFactory
        self.parentContainer = parentContainer
    }
    
    func processSegment(segment: [String: Any]) throws -> UIView {
        guard let attributesJson = segment["attributes"] as? [String: Any] else {
            return UIView()
        }
        
        let attributes = try SegmentAttributes.fromJson(json: attributesJson)
        
        // Create a vertical stack view to hold the column items
        let columnLayout = UIStackView()
        columnLayout.axis = .vertical
        columnLayout.distribution = .fill
        columnLayout.translatesAutoresizingMaskIntoConstraints = false
        
        // Set column alignment
        if let alignment = attributes.alignment {
            columnLayout.alignment = getStackViewAlignment(from: alignment)
        } else {
            columnLayout.alignment = .center
        }
        
        // Apply spacing between children
        if let spacingValue = attributes.spacing {
            // Convert spacing values like "xs", "sm", "md" to points
            columnLayout.spacing = getSpacingValue(from: spacingValue)
        } else {
            columnLayout.spacing = 4 // Default spacing
        }
        
        // Process children elements (if any)
        if let children = segment["children"] as? [[String: Any]] {
            for childSegment in children {
                guard let childType = childSegment["type"] as? String else { continue }
                
                if let processor = processorFactory.getProcessor(for: childType) {
                    do {
                        // Process the child segment
                        let childView = try processor.processSegment(segment: childSegment)
                        childView.translatesAutoresizingMaskIntoConstraints = false
                        
                        // Add the child to the column layout as an arranged subview
                        columnLayout.addArrangedSubview(childView)
                        
                        // Handle child-specific constraints if needed
                        if childType == "text" {
                            // Text views should stretch horizontally to fill the column
                            childView.widthAnchor.constraint(equalTo: columnLayout.widthAnchor).isActive = true
                        }
                    } catch {
                        print("Error processing child segment of type: \(childType), error: \(error)")
                    }
                } else {
                    print("No processor found for child segment type: \(childType)")
                }
            }
        }
        
        return columnLayout
    }
    
    func getSegmentType() -> String {
        return "column"
    }
    
    // Helper function to convert alignment string to UIStackView.Alignment
    private func getStackViewAlignment(from alignment: String) -> UIStackView.Alignment {
        switch alignment.lowercased() {
        case "left":
            return .leading
        case "right":
            return .trailing
        case "center":
            return .center
        case "fill":
            return .fill
        default:
            return .center
        }
    }
    
    // Helper function to convert spacing values to CGFloat
    private func getSpacingValue(from spacing: String) -> CGFloat {
        switch spacing.lowercased() {
        case "none":
            return 0
        case "xs":
            return 4
        case "sm":
            return 8
        case "md":
            return 12
        case "lg":
            return 16
        case "xl":
            return 24
        default:
            // Try to parse as a numeric value
            if let numericValue = NumberFormatter().number(from: spacing) {
                return CGFloat(truncating: numericValue)
            }
            return 8 // Default spacing
        }
    }
}
