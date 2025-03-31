//
//  ButtonSegmentProcessor.swift
//  sourcesync-sdk-ui-ios
//

import UIKit

class ButtonSegmentProcessor: SegmentProcessor {
    
    let tag = "ButtonSegmentProcessor"
    
    init() {}
    
    
    func processSegment(segment: [String: Any]) throws -> UIView {
        // Get content and attributes from the segment
        
        // Extract content from the segment
        let content = segment["content"] as! String
        
        // Create a button
        let button = UIButton(type: .system)
        button.setTitle(content, for: .normal)
        
        // Apply attributes if available
        if let attributesJson = segment["attributes"] as? [String: Any] {
            let attributes =  try SegmentAttributes.fromJson(json: attributesJson)
            
            if let bgColor = attributes.backgroundColor{
                if let color = UIColor(hex: bgColor) {
                    button.backgroundColor = color
                } else {
                    print("\(tag): Invalid background color format: \(bgColor)")
                }
            }
            
            // Apply text color if specified
            if let textColor = attributes.textColor{
                if let color = UIColor(hex: textColor) {
                    button.setTitleColor(color, for: .normal)
                } else {
                    print("\(tag): Invalid text color format: \(textColor)")
                }
            }
            
            // Apply font size if specified
            if let fontSize = attributes.fontSize{
                let dpSize = LayoutUtils.fontSizeToDP(fontSize: fontSize)
                button.titleLabel?.font = UIFont.systemFont(ofSize: CGFloat(dpSize))
            }
            
            button.translatesAutoresizingMaskIntoConstraints = false

            // Handle width if specified as a percentage
            if let width = attributes.width, LayoutUtils.isValidPercentage(width){
                let weight = try LayoutUtils.percentageToDecimal(width)
                button.widthAnchor.constraint(equalTo: button.superview!.widthAnchor, multiplier: weight).isActive = true
            }
            
            // Apply alignment if specified
            if let alignment = attributes.alignment{
                button.contentHorizontalAlignment = alignmentToUIControlContentHorizontalAlignment(alignment: alignment)
            } else {
                button.contentHorizontalAlignment = .center
            }
            
            // Add padding similar to the Android implementation
            button.contentEdgeInsets = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
        }
        
        return button
    }
    
    
    func getSegmentType() -> String {
        return "button"
    }
    
    // Helper method to map alignment string to UIControl content alignment
    private func alignmentToUIControlContentHorizontalAlignment(alignment: String) -> UIControl.ContentHorizontalAlignment {
        switch alignment.lowercased() {
        case "left": return .left
        case "right": return .right
        case "center": return .center
        default: return .center
        }
    }
}
