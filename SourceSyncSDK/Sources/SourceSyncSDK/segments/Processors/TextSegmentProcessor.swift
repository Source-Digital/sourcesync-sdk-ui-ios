//
//  TextSegmentProcessor.swift
//  sourcesync-sdk-ui-ios
//

import UIKit

class TextSegmentProcessor: SegmentProcessor {
    let tag = "TextSegmentProcessor"
    
    // Define platform-specific default font size
    #if os(iOS)
    private let defaultFontSize = UIFont.systemFontSize
    #elseif os(tvOS)
    private let defaultFontSize: CGFloat = 17.0 // Default size for tvOS
    #endif
    
    init() {}
    
    func processSegment(segment: [String: Any]) throws -> UIView {
        // Extract content from the segment
        let content = segment["content"] as! String
        
        // Create a UILabel
        let label = UILabel()
        let attributedString = NSMutableAttributedString(string: content)
        
        
        // Apply attributes if available
        if let attributesJson = segment["attributes"] as? [String: Any] {
            let attributes =  try SegmentAttributes.fromJson(json: attributesJson)
            
            applyTextAttributes(attributedString: attributedString, attributes: attributes, range: NSRange(location: 0, length: content.count))
            
            // Apply alignment if specified
            if let alignment = attributes.alignment {
                label.textAlignment = alignmentToNSTextAlignment(alignment: alignment)
            } else {
                label.textAlignment = .center
            }
            
            // Handle width if specified as a percentage
            if let width = attributes.width, LayoutUtils.isValidPercentage(width){
                let weight = try LayoutUtils.percentageToDecimal(width)
                label.translatesAutoresizingMaskIntoConstraints = false
                label.widthAnchor.constraint(equalTo: label.superview!.widthAnchor, multiplier: weight).isActive = true
            }
            
        }
        
        label.attributedText = attributedString
        label.numberOfLines = 0 // Allow multiline text
        
        return label
    }
    
    func getSegmentType() -> String {
        return "text"
    }
    
    // Helper function to apply text attributes
    private func applyTextAttributes(attributedString: NSMutableAttributedString, attributes: SegmentAttributes, range: NSRange) {
        // Apply font size
        if let fontSize = attributes.fontSize {
            let dpSize = LayoutUtils.fontSizeToDP(fontSize: fontSize)
            attributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: CGFloat(dpSize)), range: range)
        }
        
        // Apply text color
        if let colorHex = attributes.color, let color = UIColor(hex: colorHex) {
            attributedString.addAttribute(.foregroundColor, value: color, range: range)
        }
        
        // Apply bold styling
        if let weight = attributes.weight, weight.lowercased() == "bold" {
            attributedString.addAttribute(.font, value: UIFont.boldSystemFont(ofSize: defaultFontSize), range: range)
        }
        
        // Apply italic styling
        if let style = attributes.style, style.lowercased() == "italic" {
            attributedString.addAttribute(.font, value: UIFont.italicSystemFont(ofSize: defaultFontSize), range: range)
        }
        
        // Apply underline
        if let underline = attributes.underline, underline {
            attributedString.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: range)
        }
    }
    
    
    // Helper method to map alignment string to NSTextAlignment
    private func alignmentToNSTextAlignment(alignment: String) -> NSTextAlignment {
        switch alignment.lowercased() {
        case "left": return .left
        case "right": return .right
        case "center": return .center
        case "justified": return .justified
        default: return .center
        }
    }
}
