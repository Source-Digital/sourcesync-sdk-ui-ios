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
        
        // Create a main container view
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        // Create a stack view with fixed layout
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = .fill
        
        // Set alignment if specified
        if let alignment = attributes.alignment {
            switch alignment.lowercased() {
            case "top":
                stackView.alignment = .top
            case "bottom":
                stackView.alignment = .bottom
            case "center":
                stackView.alignment = .center
            case "fill":
                stackView.alignment = .fill
            case "leading", "left":
                stackView.alignment = .leading
            case "trailing", "right":
                stackView.alignment = .trailing
            default:
                stackView.alignment = .center
            }
        } else {
            stackView.alignment = .center
        }
        
        // Get spacing value
        var spacing: CGFloat = 8 // Default spacing
        if let spacingValue = attributes.spacing {
            spacing = getSpacingValue(from: spacingValue)
        }
        
        // We'll use fixed spacing for safety
        stackView.spacing = spacing
        
        // Add stack view to container
        containerView.addSubview(stackView)
        
        // Pin stack view to container edges
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: containerView.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor)
        ])
        
        // Process children
        if let children = segment["children"] as? [[String: Any]] {
            // First, count how many children have explicit percentages and total those up
            var explicitPercentageTotal: CGFloat = 0
            var childrenWithExplicitPercentage = 0
            
            for childSegment in children {
                if let childAttributes = childSegment["attributes"] as? [String: Any],
                   let childAttrs = try? SegmentAttributes.fromJson(json: childAttributes),
                   let childWidth = childAttrs.width,
                   LayoutUtils.isValidPercentage(childWidth) {
                    
                    let percentage = try LayoutUtils.percentageToDecimal(childWidth)
                    if percentage > 0 {
                        explicitPercentageTotal += percentage
                        childrenWithExplicitPercentage += 1
                    }
                }
            }
            
            let totalChildren = children.count
            let childrenWithoutPercentage = totalChildren - childrenWithExplicitPercentage
            
            // If total percentage is close to or exceeds 1.0, adjust to be safe
            var adjustmentFactor: CGFloat = 1.0
            if explicitPercentageTotal > 0.9 && childrenWithoutPercentage > 0 {
                // Need to leave room for children without percentages
                adjustmentFactor = 0.9 / explicitPercentageTotal
            } else if explicitPercentageTotal > 0.98 {
                // Tiny adjustment to prevent rounding/calculation issues
                adjustmentFactor = 0.98 / explicitPercentageTotal
            }
            
            // Process each child
            for childSegment in children {
                guard let childType = childSegment["type"] as? String else { continue }
                
                if let processor = processorFactory.getProcessor(for: childType) {
                    do {
                        // Process the child segment
                        let childView = try processor.processSegment(segment: childSegment)
                        childView.translatesAutoresizingMaskIntoConstraints = false
                        
                        // Create a wrapper view to handle width constraints
                        let wrapperView = UIView()
                        wrapperView.translatesAutoresizingMaskIntoConstraints = false
                        wrapperView.addSubview(childView)
                        
                        // Make child fill wrapper
                        NSLayoutConstraint.activate([
                            childView.topAnchor.constraint(equalTo: wrapperView.topAnchor),
                            childView.bottomAnchor.constraint(equalTo: wrapperView.bottomAnchor),
                            childView.leadingAnchor.constraint(equalTo: wrapperView.leadingAnchor),
                            childView.trailingAnchor.constraint(equalTo: wrapperView.trailingAnchor)
                        ])
                        
                        // Add wrapper to stack view
                        stackView.addArrangedSubview(wrapperView)
                        
                        // Set width constraint based on attributes
                        if let childAttributes = childSegment["attributes"] as? [String: Any],
                           let childAttrs = try? SegmentAttributes.fromJson(json: childAttributes),
                           let childWidth = childAttrs.width,
                           LayoutUtils.isValidPercentage(childWidth) {
                            
                            let percentage = try LayoutUtils.percentageToDecimal(childWidth)
                            if percentage > 0 {
                                // Apply adjusted percentage with safety checks
                                let safePercentage = percentage * adjustmentFactor
                                
                                // Verify value is valid to prevent NaN
                                if safePercentage.isFinite && safePercentage > 0 && safePercentage <= 1.0 {
                                    // Use lower priority to prevent conflicts
                                    let constraint = wrapperView.widthAnchor.constraint(
                                        equalTo: stackView.widthAnchor,
                                        multiplier: safePercentage
                                    )
                                    constraint.priority = .defaultHigh - 1
                                    constraint.isActive = true
                                } else {
                                    // Fallback for invalid percentages
                                    let constraint = wrapperView.widthAnchor.constraint(
                                        equalToConstant: 100
                                    )
                                    constraint.priority = .defaultHigh - 2
                                    constraint.isActive = true
                                }
                            }
                        } else if childrenWithoutPercentage > 0 && childrenWithExplicitPercentage > 0 {
                            // For views without explicit percentages, calculate remaining space
                            let remainingPercentage = max(0.01, (1.0 - (explicitPercentageTotal * adjustmentFactor)))
                            let equalShare = remainingPercentage / CGFloat(childrenWithoutPercentage)
                            
                            // Verify value is valid to prevent NaN
                            if equalShare.isFinite && equalShare > 0 {
                                let constraint = wrapperView.widthAnchor.constraint(
                                    equalTo: stackView.widthAnchor,
                                    multiplier: equalShare
                                )
                                constraint.priority = .defaultHigh - 1
                                constraint.isActive = true
                            }
                        }
                        
                    } catch {
                        print("Error processing child segment of type: \(childType), error: \(error)")
                    }
                } else {
                    print("No processor found for child segment type: \(childType)")
                }
            }
        }
        
        return containerView
    }
    
    func getSegmentType() -> String {
        return "row"
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
