//
//  Extensions.swift
//  MobileDemo
//
//  Created by ayman badawy on 22/03/2025.
//

import UIKit

extension UIImageView {
    func loadGif(name: String) {
        DispatchQueue.global().async {
            let image = UIImage.gif(name: name)
            DispatchQueue.main.async {
                self.image = image
            }
        }
    }
}

extension UIImage {
    class func gif(name: String) -> UIImage? {
        // Check if gif exists in main bundle
        guard let bundleURL = Bundle.main.url(forResource: name, withExtension: "gif") else {
            print("GIF not found: \(name)")
            return nil
        }
        
        // Load the data from the file
        guard let imageData = try? Data(contentsOf: bundleURL) else {
            return nil
        }
        
        // Create source from data
        guard let source = CGImageSourceCreateWithData(imageData as CFData, nil) else {
            return nil
        }
        
        // Get count of frames in gif
        let count = CGImageSourceGetCount(source)
        
        // Create UIImage array to store frames
        var images = [UIImage]()
        var duration: TimeInterval = 0
        
        // Extract each frame
        for i in 0..<count {
            guard let image = CGImageSourceCreateImageAtIndex(source, i, nil) else {
                continue
            }
            
            // Get frame duration
            if let properties = CGImageSourceCopyPropertiesAtIndex(source, i, nil) as? [String: Any],
               let gifInfo = properties[kCGImagePropertyGIFDictionary as String] as? [String: Any],
               let frameDuration = gifInfo[kCGImagePropertyGIFDelayTime as String] as? Double {
                duration += frameDuration
            }
            
            images.append(UIImage(cgImage: image))
        }
        
        // No frames found
        if images.isEmpty {
            return nil
        }
        
        // Create animated image with collected frames
        let animatedImage = UIImage.animatedImage(with: images, duration: duration)
        return animatedImage
    }
}
