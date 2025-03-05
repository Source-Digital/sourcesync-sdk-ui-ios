//
//  SegmentAttributes.swift
//  sourcesync-sdk-ui-ios
//
import UIKit

// Represents segment attributes that define styles and layouts.
class SegmentAttributes {
    var font: String?
    var fontSize: String?
    var color: String?
    var weight: String?
    var style: String?
    var underline: Bool?
    var backgroundColor: String?
    var textColor: String?
    var spacing: String?
    var width: String?
    var height: String?
    var alignment: String?
    var contentMode: String?
    
    // Parses a JSON dictionary into a `SegmentAttributes` instance.
    // - Parameter json: The JSON dictionary containing attribute data.
    // - Throws: An error if any required values are invalid.
    // - Returns: A configured `SegmentAttributes` instance.
    static func fromJson(json: [String: Any]) throws -> SegmentAttributes {
        let attrs = SegmentAttributes()
        
        attrs.font = json["font"] as? String
        attrs.color = json["color"] as? String
        attrs.weight = json["weight"] as? String
        attrs.style = json["style"] as? String
        attrs.underline = json["underline"] as? Bool
        attrs.backgroundColor = json["backgroundColor"] as? String
        attrs.textColor = json["textColor"] as? String
        attrs.alignment = json["alignment"] as? String
        attrs.contentMode = json["contentMode"] as? String
        
        // Handle size attributes
        if let size = json["size"] {
            if let sizeDict = size as? [String: String],
               let width = sizeDict["width"], let height = sizeDict["height"] {
                guard LayoutUtils.isValidPercentage(width), LayoutUtils.isValidPercentage(height) else {
                    throw NSError(domain: "SegmentAttributes", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid size format"])
                }
                attrs.width = width
                attrs.height = height
            } else if let fontSize = size as? String {
                attrs.fontSize = fontSize.lowercased()
            }
        }
        
        // Handle spacing
        if let spacing = json["spacing"] as? String {
            attrs.spacing = spacing.lowercased()
        }
        
        // Handle direct width/height
        if let width = json["width"] as? String, LayoutUtils.isValidPercentage(width) {
            attrs.width = width
        }
        
        if let height = json["height"] as? String, LayoutUtils.isValidPercentage(height) {
            attrs.height = height
        }
        
        if let fontSize = json["fontSize"] as? String {
            attrs.fontSize = fontSize.lowercased()
        }
        
        return attrs
    }
}

