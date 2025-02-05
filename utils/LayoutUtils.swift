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
    
    
    // Converts an alignment string to UIStackView.Alignment.
    // - Parameter alignment: The alignment string ("left", "right", "center").
    // - Returns: The corresponding NSTextAlignment.
    static func getStackViewAlignment(from alignment: String?) -> UIStackView.Alignment {
        guard let alignment = alignment?.lowercased() else { return .center }
        
        switch alignment {
        case "left":
            return .leading
        case "right":
            return .trailing
        case "center":
            return .center
        default:
            return .center
        }
    }
    
    // Converts DP (Density-independent Pixels) to actual pixels.
    // - Parameter dp: The value in DP.
    // - Returns: The corresponding value in pixels.
    static func dpToPx(_ dp: CGFloat) -> CGFloat {
        return dp * UIScreen.main.scale
    }
    
    //Checks if a string is a valid percentage (e.g., "50%").
    // - Parameter value: The string to validate.
    // - Returns: True if the string is a valid percentage, false otherwise.
    static func isValidPercentage(_ value: String) -> Bool {
        let range = NSRange(location: 0, length: value.utf16.count)
        return percentagePattern.firstMatch(in: value, options: [], range: range) != nil
    }
    
    // Converts a percentage string to a decimal value.
    // - Parameter percentage: The percentage string (e.g., "50%").
    // - Throws: An error if the percentage format is invalid.
    // - Returns: The decimal representation of the percentage.
    static func percentageToDecimal(_ percentage: String) throws -> CGFloat {
        guard isValidPercentage(percentage) else {
            throw NSError(domain: "Invalid percentage value", code: 0, userInfo: nil)
        }
        
        let matches = percentagePattern.matches(in: percentage, options: [], range: NSRange(location: 0, length: percentage.utf16.count))
        guard let match = matches.first, let range = Range(match.range(at: 1), in: percentage) else {
            throw NSError(domain: "Invalid percentage format", code: 0, userInfo: nil)
        }
        
        return CGFloat((Float(percentage[range]) ?? 0) / 100.0)
    }
    
    // Converts a percentage string to pixels based on a total dimension.
    // - Parameters:
    //   - percentage: The percentage string (e.g., "50%").
    //   - totalDimension: The total dimension in pixels.
    // - Throws: An error if the percentage format is invalid.
    // - Returns: The calculated pixel value.
    static func percentageToPx(_ percentage: String, totalDimension: CGFloat) throws -> CGFloat {
        let decimal = try percentageToDecimal(percentage)
        return totalDimension * decimal
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
}

