//
//  RowSegmentProcessor.swift
//  sourcesync-sdk-ui-ios
//

import UIKit

class RowSegmentProcessor: SegmentProcessor {
    private static let TAG = "RowSegmentProcessor"
    private let processorFactory: SegmentProcessorFactory
    
    init(processorFactory: SegmentProcessorFactory, parentContainer: UIView) {
        self.processorFactory = processorFactory
    }
    
    func processSegment(segment: [String: Any]) throws -> UIView {
        // Create a main container view with clear background
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = .clear
        
        // Parse attributes if present
        var attributes: SegmentAttributes?
        var spacing: CGFloat = 8 // Default spacing
        
        if let attributesJson = segment["attributes"] as? [String: Any] {
            attributes = try SegmentAttributes.fromJson(json: attributesJson)
            
            // Get spacing value
            if let spacingValue = attributes?.spacing {
                spacing = LayoutUtils.getSpacingValue(from: spacingValue)
            }
        }
        
        // Process children and collect percentage data
        if let children = segment["children"] as? [[String: Any]] {
            var childViews = [UIView]()
            var childPercentages = [CGFloat]()
            var totalPercentage: CGFloat = 0
            
            // First pass: process children and collect width data
            for childSegment in children {
                guard let childType = childSegment["type"] as? String else { continue }
                
                if let processor = processorFactory.getProcessor(for: childType) {
                    do {
                        // Process the child segment
                        let childView = try processor.processSegment(segment: childSegment)
                        childViews.append(childView)
                        
                        // Extract width percentage if available
                        var percentage: CGFloat = 0
                        if let attributesJson = childSegment["attributes"] as? [String: Any],
                           let widthStr = attributesJson["width"] as? String,
                           widthStr.hasSuffix("%") {
                            
                            if let percentStr = widthStr.components(separatedBy: "%").first,
                               let percentValue = Float(percentStr) {
                                percentage = CGFloat(percentValue / 100.0)
                                totalPercentage += percentage
                            }
                        }
                        
                        childPercentages.append(percentage)
                        
                    } catch {
                        print("\(RowSegmentProcessor.TAG): Error processing child segment: \(error)")
                    }
                }
            }
            
            // Calculate remaining space for views without explicit percentages
            let remainingPercentage = max(0, 1.0 - totalPercentage)
            let viewsWithoutPercentage = childPercentages.filter { $0 == 0 }.count
            let defaultPercentage = viewsWithoutPercentage > 0 ? remainingPercentage / CGFloat(viewsWithoutPercentage) : 0
            
            // Replace zeros with default percentage
            for i in 0..<childPercentages.count {
                if childPercentages[i] == 0 {
                    childPercentages[i] = defaultPercentage
                }
            }
            
            // Debug output
            print("\(RowSegmentProcessor.TAG): Percentages: \(childPercentages)")
            
            // Second pass: layout child views with explicit constraints
            if !childViews.isEmpty {
                // Add all child views to container
                for childView in childViews {
                    containerView.addSubview(childView)
                    childView.translatesAutoresizingMaskIntoConstraints = false
                }
                
                // Create constraints for each child
                var previousView: UIView? = nil
                let totalChildren = childViews.count
                
                for i in 0..<totalChildren {
                    let childView = childViews[i]
                    let percentage = childPercentages[i]
                    
                    // Top and bottom constraints
                    NSLayoutConstraint.activate([
                        childView.topAnchor.constraint(equalTo: containerView.topAnchor),
                        childView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
                    ])
                    
                    // Set width constraint based on percentage
                    let widthConstraint = childView.widthAnchor.constraint(
                        equalTo: containerView.widthAnchor,
                        multiplier: percentage
                    )
                    widthConstraint.priority = .defaultHigh
                    widthConstraint.isActive = true
                    
                    // Left constraint depends on position
                    if let previousView = previousView {
                        // Not the first item, position after previous with spacing
                        NSLayoutConstraint.activate([
                            childView.leadingAnchor.constraint(
                                equalTo: previousView.trailingAnchor,
                                constant: spacing
                            )
                        ])
                    } else {
                        // First item, align to left edge
                        NSLayoutConstraint.activate([
                            childView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor)
                        ])
                    }
                    
                    // If it's the last item, also constrain to right edge
                    if i == totalChildren - 1 {
                        NSLayoutConstraint.activate([
                            childView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor)
                        ])
                    }
                    
                    previousView = childView
                }
            }
        }
        
        return containerView
    }
    
    func getSegmentType() -> String {
        return "row"
    }
}
