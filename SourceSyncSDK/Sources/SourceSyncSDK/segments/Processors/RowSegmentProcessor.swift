//
//  RowSegmentProcessor.swift
//  sourcesync-sdk-ui-ios
//

import UIKit

class RowSegmentProcessor: SegmentProcessor {
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
        
        // Create a horizontal stack view for the row
        let rowLayout = UIStackView()
        rowLayout.axis = .horizontal
        rowLayout.distribution = .fill
        rowLayout.translatesAutoresizingMaskIntoConstraints = false
        
        // Set row alignment if specified
        if let alignment = attributes.alignment {
            rowLayout.alignment = getStackAlignment(from: alignment)
        } else {
            rowLayout.alignment = .center
        }
        
        // Apply spacing between children if specified
        if let spacingValue = attributes.spacing {
            rowLayout.spacing = getSpacingValue(from: spacingValue)
        } else {
            rowLayout.spacing = 8 // Default spacing
        }
        
        // Process children
        if let children = segment["children"] as? [[String: Any]] {
            for childSegment in children {
                guard let childType = childSegment["type"] as? String else { continue }
                
                if let processor = processorFactory.getProcessor(for: childType) {
                    do {
                        // Process the child segment
                        let childView = try processor.processSegment(segment: childSegment)
                        childView.translatesAutoresizingMaskIntoConstraints = false
                        
                        // Add the child to the row layout
                        rowLayout.addArrangedSubview(childView)
                        
                        // Handle child's width if specified
                        if let childAttributes = childSegment["attributes"] as? [String: Any],
                           let childAttrs = try? SegmentAttributes.fromJson(json: childAttributes),
                           let childWidth = childAttrs.width,
                           LayoutUtils.isValidPercentage(childWidth) {
                            
                            let weightDecimal = try LayoutUtils.percentageToDecimal(childWidth)
                            // Apply width constraint based on percentage
                            childView.widthAnchor.constraint(equalTo: rowLayout.widthAnchor, multiplier: weightDecimal).isActive = true
                        }
                    } catch {
                        print("Error processing child segment of type: \(childType), error: \(error)")
                    }
                } else {
                    print("No processor found for child segment type: \(childType)")
                }
            }
        }
        
        return rowLayout
    }
    
    func getSegmentType() -> String {
        return "row"
    }
    
    // Helper function to map alignment to UIStackView.Alignment
    private func getStackAlignment(from alignment: String) -> UIStackView.Alignment {
        switch alignment.lowercased() {
        case "top":
            return .top
        case "bottom":
            return .bottom
        case "left", "leading":
            return .leading
        case "right", "trailing":
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
