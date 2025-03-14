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
        rowLayout.alignment = .center
        rowLayout.spacing = 8 // Default spacing of 8, can be adjusted
        
        // Set row alignment if specified
        if let alignment = attributes.alignment {
            rowLayout.alignment = getStackAlignment(from: alignment)
        }
        
        // Configure layout parameters for the row
        if let width = attributes.width {
            let parentWidth = parentContainer.frame.width
            let widthPx = try LayoutUtils.percentageToPx(width, totalDimension: parentWidth)
            rowLayout.frame.size.width = widthPx
        } else {
            rowLayout.frame.size.width = parentContainer.frame.width
        }
        
        // Process children
        if let children = segment["children"] as? [[String: Any]] {
            for childSegment in children {
                guard let childType = childSegment["type"] as? String else { continue }
                
                if let processor = processorFactory.getProcessor(for: childType) {
                    let childView = try processor.processSegment(segment: childSegment)
                    // Handle child's percentage width if specified
                    if let childAttributes = childSegment["attributes"] as? [String: Any] {
                        let childAttrs = try SegmentAttributes.fromJson(json: childAttributes)
                        if let childWidth = childAttrs.width, LayoutUtils.isValidPercentage(childWidth) {
                            let weight = try LayoutUtils.percentageToDecimal(childWidth)
                            childView.translatesAutoresizingMaskIntoConstraints = false
                            rowLayout.addArrangedSubview(childView)
                            childView.widthAnchor.constraint(equalTo: rowLayout.widthAnchor, multiplier: weight).isActive = true
                        }
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
        switch alignment {
        case "left":
            return .leading
        case "right":
            return .trailing
        default:
            return .center
        }
    }
}
