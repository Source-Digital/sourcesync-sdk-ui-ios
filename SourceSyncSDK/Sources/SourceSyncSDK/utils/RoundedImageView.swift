//
//  RoundedImageView.swift
//  SourceSyncSDK
//
//  Created by ayman badawy on 31/03/2025.
//
import UIKit

// Custom view that handles rounded corners for images
class RoundedImageView: UIView {
    var cornerRadius: CGFloat = 0 {
        didSet {
            setNeedsLayout()
        }
    }
    
    let imageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        // Configure image view
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        // Add image view to self
        addSubview(imageView)
        
        // Fill constraints
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        // Make sure we clip to bounds and mask
        clipsToBounds = true
        layer.masksToBounds = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = cornerRadius
    }
    
    // Helper to set image with animation
    func setImage(_ image: UIImage?) {
        imageView.image = image
        
        // Apply mask again after setting image
        layer.masksToBounds = true
        layer.cornerRadius = cornerRadius
    }
}
