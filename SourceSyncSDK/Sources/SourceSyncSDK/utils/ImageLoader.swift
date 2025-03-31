//
//  ImageLoader.swift
//  SourceSyncSDK
//
//  Created by ayman badawy on 21/03/2025.
//

import UIKit

class ImageLoader {
    func loadImage(urlString: String, imageView: UIImageView, preserveAspectRatio: Bool = false) {
        guard let url = URL(string: urlString) else {
            print("Invalid image URL: \(urlString)")
            return
        }
        
        let imageViewRef = WeakRef(value: imageView)
        let containerRef = WeakRef(value: imageView.superview)
        let preserveRatio = preserveAspectRatio
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error loading image: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    imageViewRef.value?.backgroundColor = .gray
                }
                return
            }
            
            guard let data = data, let image = UIImage(data: data) else {
                print("Failed to create image from data for URL: \(urlString)")
                DispatchQueue.main.async {
                    imageViewRef.value?.backgroundColor = .gray
                }
                return
            }
            
            DispatchQueue.main.async {
                imageViewRef.value?.image = image
                imageViewRef.value?.backgroundColor = .clear
                
                // Apply aspect ratio if needed and if image size is valid
                if preserveRatio,
                   let container = containerRef.value,
                   image.size.width > 0 {
                    
                    // Calculate aspect ratio
                    let aspectRatio = image.size.height / image.size.width
                    
                    // Set aspect ratio constraint with lower priority
                    let aspectConstraint = container.heightAnchor.constraint(
                        equalTo: container.widthAnchor,
                        multiplier: aspectRatio
                    )
                    aspectConstraint.priority = .defaultHigh - 1
                    aspectConstraint.isActive = true
                    
                    // Request layout update
                    container.superview?.setNeedsLayout()
                }
            }
        }.resume()
    }
}
