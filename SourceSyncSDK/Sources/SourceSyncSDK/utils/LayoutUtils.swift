//
//  LayoutUtils.swift
//  sourcesync-sdk-ui-ios
//

import UIKit

class LayoutUtils {
    private static let percentagePattern = try! NSRegularExpression(pattern: "^(\\d+(?:\\.\\d+)?)%$", options: [])
    
    // Converts an alignment string to NSTextAlignment.
    // - Parameter alignment: The alignment string ("left", "right", "center").
    // - Returns: The corresponding NSTextAlignment.
    static func getAlignment(from alignment: String?) -> NSTextAlignment {
        guard let alignment = alignment?.lowercased() else { return .center }
        
        switch alignment {
        case "left":
            return .left
        case "right":
            return .right
        case "center":
            return .center
        default:
            return .center
        }
    }
    
    // Helper method to map alignment string to UIControl content alignment
    static func alignmentToUIControlContentHorizontalAlignment(alignment: String) -> UIControl.ContentHorizontalAlignment {
        switch alignment.lowercased() {
        case "left": return .left
        case "right": return .right
        case "center": return .center
        default: return .center
        }
    }
    
    // Converts DP (Density-independent Pixels) to actual pixels.
    // - Parameter dp: The value in DP.
    // - Returns: The corresponding value in pixels.
    static func dpToPx(_ dp: CGFloat) -> CGFloat {
        return dp * UIScreen.main.scale
    }
    
    // Convert device-independent points to pixels
    static func dpToPx(_ dp: Double) -> Double {
        return dp * Double(UIScreen.main.scale)
    }
    
    // Convert percentage string to pixels
    static func percentageToPx(_ percentage: String, totalDimension: CGFloat) throws -> CGFloat {
        let decimal = try percentageToDecimal(percentage)
        return totalDimension * decimal
    }
    
    // Convert a percentage string to a decimal value (e.g., "50%" -> 0.5)
    static func percentageToDecimal(_ percentageString: String) throws -> CGFloat {
        // First check if the input is a valid percentage
        guard isValidPercentage(percentageString) else {
            throw NSError(domain: "LayoutUtils", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid percentage format: \(percentageString)"])
        }
        
        // Remove the % symbol and convert to decimal
        let trimmedString = percentageString.replacingOccurrences(of: "%", with: "").trimmingCharacters(in: .whitespaces)
        
        // Safely convert to CGFloat with validation
        guard let percentValue = Double(trimmedString) else {
            throw NSError(domain: "LayoutUtils", code: 2, userInfo: [NSLocalizedDescriptionKey: "Could not parse percentage value: \(percentageString)"])
        }
        
        // Convert to decimal and validate range
        let decimalValue = CGFloat(percentValue / 100.0)
        
        // Ensure the value is within valid range to prevent constraint issues
        if decimalValue <= 0 {
            return 0.01 // Return a small positive value
        } else if !decimalValue.isFinite {
            return 0.5 // Return a reasonable default if not finite
        } else if decimalValue > 1.0 {
            return 1.0 // Cap at 100%
        }
        
        return decimalValue
    }
    
    // Check if a string is a valid percentage value
    static func isValidPercentage(_ value: String) -> Bool {
        let pattern = "^\\s*\\d+(\\.\\d+)?\\s*%\\s*$"
        let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive)
        let range = NSRange(location: 0, length: value.utf16.count)
        return regex?.firstMatch(in: value, options: [], range: range) != nil
    }

    // Convert a string alignment to UIStackView.Alignment
    static func getStackViewAlignment(from alignment: String) -> UIStackView.Alignment {
        switch alignment.lowercased() {
        case "left", "leading":
            return .leading
        case "right", "trailing":
            return .trailing
        case "center":
            return .center
        case "fill":
            return .fill
        case "top":
            return .top
        case "bottom":
            return .bottom
        default:
            return .center
        }
    }
    
    // Helper method to convert font size string to DP
    static func fontSizeToDP(fontSize: String) -> Int {
        switch fontSize.lowercased() {
        case "xxs": return 6
        case "xs": return 10
        case "sm": return 14
        case "md": return 16
        case "lg": return 20
        case "xl": return 24
        case "xxl": return 32
        default: return 16
        }
    }
    
    // Helper function to convert spacing values to CGFloat
    static func getSpacingValue(from spacing: String) -> CGFloat {
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
    

    // Converts alignment string to appropriate content mode
    static func alignmentToContentMode(alignment: String) -> UIView.ContentMode {
        switch alignment.lowercased() {
        case "left": return .left
        case "right": return .right
        case "center": return .scaleAspectFit
        default: return .scaleAspectFit
        }
    }
    
    // Converts contentMode string to UIView.ContentMode
    static func contentModeFromString(_ contentMode: String) -> UIView.ContentMode {
        switch contentMode.lowercased() {
        case "scaleaspectfit": return .scaleAspectFit
        case "scaleaspectfill": return .scaleAspectFill
        case "scaletofill": return .scaleToFill
        case "center": return .center
        case "top": return .top
        case "bottom": return .bottom
        case "left": return .left
        case "right": return .right
        case "topleft": return .topLeft
        case "topright": return .topRight
        case "bottomleft": return .bottomLeft
        case "bottomright": return .bottomRight
        default: return .scaleAspectFit
        }
    }
}

