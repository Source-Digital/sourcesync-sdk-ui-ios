//
//  TextSegmentProcessor.swift
//  sourcesync-sdk-ui-ios
//

import UIKit

class TextSegmentProcessor: SegmentProcessor {
    private static let TAG = "TextSegmentProcessor"
    
    init() {}
    
    func processSegment(segment: [String: Any]) throws -> UIView {
        // Extract content from the segment
        let content = segment["content"] as! String
        
        // Create a UILabel
        let textView = UILabel()
        let attributedString = NSMutableAttributedString(string: content)
        
        // Apply attributes if available
        if let attributesJson = segment["attributes"] as? [String: Any] {
            let attributes = try SegmentAttributes.fromJson(json: attributesJson)
            
            // Apply text styling attributes
            applyTextAttributes(attributedString: attributedString,
                               attributes: attributes,
                               range: NSRange(location: 0, length: content.count))
            
            // Apply alignment if specified
            if let alignment = attributes.alignment {
                textView.textAlignment = LayoutUtils.alignmentToTextAlignment(alignment: alignment)
            } else {
                textView.textAlignment = .center
            }
            
            // Configure layout parameters
            configureLayoutParams(textView: textView, attributes: attributes)
            
            // Add padding similar to Android implementation
            textView.layoutMargins = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        }
        
        textView.attributedText = attributedString
        textView.numberOfLines = 0 // Allow multiline text
        textView.translatesAutoresizingMaskIntoConstraints = false
        
        return textView
    }
    
    func getSegmentType() -> String {
        return "text"
    }
    
    // Helper function to apply text attributes
    private func applyTextAttributes(attributedString: NSMutableAttributedString,
                                    attributes: SegmentAttributes,
                                    range: NSRange) {
        if attributes == nil { return }
        
        // Create base font
        var font = UIFont.systemFont(ofSize: UIFont.systemFontSize)
        
        // Apply font size
        if let fontSize = attributes.fontSize {
            let dpSize = LayoutUtils.fontSizeToDP(fontSize: fontSize)
            font = UIFont.systemFont(ofSize: CGFloat(dpSize))
        }
        
        // Apply text color
        if let colorHex = attributes.color {
            do {
                if let color = UIColor(hex: colorHex) {
                    attributedString.addAttribute(.foregroundColor, value: color, range: range)
                } else {
                    print("\(TextSegmentProcessor.TAG): Invalid color format: \(colorHex)")
                }
            } catch {
                print("\(TextSegmentProcessor.TAG): Error parsing color: \(error)")
            }
        }
        
        // Apply text style (bold)
        if attributes.weight == "bold" {
            if let boldFont = applyBoldToFont(font) {
                attributedString.addAttribute(.font, value: boldFont, range: range)
            }
        } else {
            attributedString.addAttribute(.font, value: font, range: range)
        }
        
        // Apply text style (italic)
        if attributes.style == "italic" {
            if let italicFont = applyItalicToFont(font) {
                attributedString.addAttribute(.font, value: italicFont, range: range)
            }
        }
        
        // Apply underline
        if attributes.underline == true {
            attributedString.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: range)
        }
    }
    
    // Helper method to create apply bold to a font
    private func applyBoldToFont(_ font: UIFont) -> UIFont? {
        let descriptor = font.fontDescriptor.withSymbolicTraits(.traitBold)
        if let descriptor = descriptor {
            return UIFont(descriptor: descriptor, size: font.pointSize)
        }
        return nil
    }
    
    // Helper method to create apply italic to a font
    private func applyItalicToFont(_ font: UIFont) -> UIFont? {
        let descriptor = font.fontDescriptor.withSymbolicTraits(.traitItalic)
        if let descriptor = descriptor {
            return UIFont(descriptor: descriptor, size: font.pointSize)
        }
        return nil
    }
    
    // Helper method to configure layout parameters based on attributes
    private func configureLayoutParams(textView: UILabel, attributes: SegmentAttributes) {
        textView.translatesAutoresizingMaskIntoConstraints = false
        
        // Handle width if specified as percentage
        if let width = attributes.width, LayoutUtils.isValidPercentage(width) {
            do {
                let weight = try LayoutUtils.percentageToDecimal(width)
                // Width constraint will be set when view is added to superview
                if let superview = textView.superview {
                    let constraint = textView.widthAnchor.constraint(
                        equalTo: superview.widthAnchor,
                        multiplier: weight
                    )
                    constraint.priority = .defaultHigh
                    constraint.isActive = true
                }
            } catch {
                print("\(TextSegmentProcessor.TAG): Error parsing width percentage: \(error)")
            }
        } else {
            // Default to full width (equivalent to MATCH_PARENT)
            if let superview = textView.superview {
                let constraint = textView.widthAnchor.constraint(equalTo: superview.widthAnchor)
                constraint.priority = .defaultHigh
                constraint.isActive = true
            }
        }
    }
}

// Extension for LayoutUtils
extension LayoutUtils {
    static func alignmentToTextAlignment(alignment: String) -> NSTextAlignment {
        switch alignment.lowercased() {
        case "left":
            return .left
        case "right":
            return .right
        case "center":
            return .center
        case "justified":
            return .justified
        default:
            return .center
        }
    }
}
