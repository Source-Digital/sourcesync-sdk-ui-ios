//
//  Extensions.swift
//  sourcesync-sdk-ui-ios
//


import UIKit

// UIColor extension to handle hex color conversion
extension UIColor {
    convenience init?(hex: String) {
        var hexSanitized = hex.replacingOccurrences(of: "#", with: "")
        if hexSanitized.count == 6 {
            hexSanitized = "FF" + hexSanitized // Add default alpha
        }
        
        if hexSanitized.count == 8, let hexValue = Int(hexSanitized, radix: 16) {
            let red = CGFloat((hexValue >> 24) & 0xFF) / 255.0
            let green = CGFloat((hexValue >> 16) & 0xFF) / 255.0
            let blue = CGFloat((hexValue >> 8) & 0xFF) / 255.0
            let alpha = CGFloat(hexValue & 0xFF) / 255.0
            self.init(red: red, green: green, blue: blue, alpha: alpha)
        } else {
            return nil
        }
    }
}
