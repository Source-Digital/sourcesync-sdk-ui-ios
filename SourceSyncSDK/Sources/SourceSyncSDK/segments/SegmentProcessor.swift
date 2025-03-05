//
//  SegmentProcessor.swift
//  sourcesync-sdk-ui-ios
//


import UIKit

protocol SegmentProcessor {
    // Process a segment JSON object and return an appropriate UIView
    // - Parameter segment: JSON object containing segment data and attributes
    // - Returns: A configured UIView representing the segment
    // - Throws: An error if the segment data is invalid or required fields are missing
    func processSegment(segment: [String: Any]) throws -> UIView
    
    // Get the type of segment this processor handles
    // - Returns: String identifier for the segment type (e.g., "text", "image", "button", "row", "column")
    func getSegmentType() -> String
}
