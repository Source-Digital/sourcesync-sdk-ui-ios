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
        
        // Set column alignment
        if let alignment = attributes.alignment {
            columnLayout.alignment = LayoutUtils.getStackViewAlignment(from: alignment)
        } else {
            columnLayout.alignment = .center
        }
        
        // Calculate width and height for the column
        let columnParams = UIStackView()
        if let width = attributes.width {
            if LayoutUtils.isValidPercentage(width) {
                let weight = try LayoutUtils.percentageToDecimal(width)
                columnParams.distribution = .fillEqually
                columnLayout.setCustomSpacing(weight, after: columnLayout.arrangedSubviews.last ?? UIView())
            } else {
                print("Invalid width percentage: \(width). Using default width.")
            }
        }
        
        // Handle height if specified
        if let height = attributes.height {
            if LayoutUtils.isValidPercentage(height) {
                let parentHeight = parentContainer.frame.height
                let newHeight = try LayoutUtils.percentageToPx(height, totalDimension: parentHeight)
                columnLayout.heightAnchor.constraint(equalToConstant: newHeight).isActive = true
            }
        }
        
        
        // Apply spacing between children if specified
        if attributes.spacing != nil {
            let spacingPx = LayoutUtils.dpToPx(8) // Default 8dp spacing
            columnLayout.spacing = CGFloat(spacingPx)
        }
        
        // Process children elements (if any)
        if let children = segment["children"] as? [[String: Any]] {
            for childSegment in children {
                let childType = childSegment["type"] as? String
                if let processor = processorFactory.getProcessor(for: childType!) {
                    do {
                        // Process the child segment and get the child view
                        let childView = try processor.processSegment(segment: childSegment)
                        
                        // Handle child's percentage dimensions if specified
                        let childAttributesJson = (childSegment["attributes"] as? [String: Any])!
                        let childAttrs = try SegmentAttributes.fromJson(json: childAttributesJson)
                        
                        // Use optional binding:
                        if let width = childAttrs.width, LayoutUtils.isValidPercentage(width) {
                            // Assuming childView is a UIView, adjust its layout based on percentage width
                            var childFrame = childView.frame
                            _ = try LayoutUtils.percentageToDecimal(childAttrs.width!)
                            
                            // Set width and weight (iOS doesn't use LinearLayout.LayoutParams like Android)
                            childFrame.size.width = 0 // Zero width will allow weight-based width adjustment
                            // Apply your weight logic or frame size adjustments here based on your layout
                            childView.frame = childFrame
                        }
                        
                        // Add childView to parent layout
                        columnLayout.addSubview(childView)
                        
                    } catch {
                        print("Error processing child segment of type: \(String(describing: childType)), error: \(error)")
                    }
                } else {
                    print("No processor found for child segment type: \(String(describing: childType))")
                }
            }
        }
        
        //        }
        
        return columnLayout
    }
    
    func getSegmentType() -> String {
        return "column"
    }
}
