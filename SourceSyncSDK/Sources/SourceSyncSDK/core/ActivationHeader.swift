//
//  ActivationHeader.swift
//  sourcesync-sdk-ui-ios
//

import UIKit

// A view representing an activation header with a close button.
class ActivationHeader: UIView {
    
    private var onClose: (() -> Void)?
    
    // Constructor used when creating view from code
    init(onClose: @escaping () -> Void) {
        super.init(frame: .zero)
        self.onClose = onClose
        initializeView()
    }
    
    // Required initializer for loading from storyboard/xib
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initializeView()
    }
    
    // Sets up the view with a close button
    private func initializeView() {
        // Make sure this view doesn't use any unnecessary space
        translatesAutoresizingMaskIntoConstraints = false
        
        // Create close button with improved styling
        let closeButton = UIButton(type: .system)
        
        // Use background thread to load image
        DispatchQueue.global(qos: .userInitiated).async {
            // This is done in background
            let closeImage = UIImage(systemName: "xmark") ?? UIImage(named: "ic_close")
            
            DispatchQueue.main.async {
                closeButton.setImage(closeImage, for: .normal)
                
                // Set content insets (padding) for the image
                // Convert 2dp to points based on device scale factor
                let padding = 10.0
//                closeButton.contentEdgeInsets = UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding)
                
                // Ensure the button size adjusts to accommodate the padding
//                closeButton.sizeToFit()
            }
        }
        
        closeButton.tintColor = .white // White X for better contrast
        
        // Create semi-transparent dark gray background
        closeButton.backgroundColor = UIColor(red: 38/255, green: 38/255, blue: 38/255, alpha: 191/255)
        
        // Apply rounded corners
        closeButton.layer.cornerRadius = 6
        closeButton.layer.borderWidth = 1
        closeButton.layer.borderColor = UIColor.white.withAlphaComponent(76/255).cgColor // Subtle white border
        
        // Add shadow for better visibility
        closeButton.layer.shadowColor = UIColor.black.cgColor
        closeButton.layer.shadowOffset = CGSize(width: 0, height: 1)
        closeButton.layer.shadowRadius = 2
        closeButton.layer.shadowOpacity = 0.3
        
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        
        addSubview(closeButton)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        
        // Add constraints to position the button
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: topAnchor),
            closeButton.leadingAnchor.constraint(equalTo: leadingAnchor),
            closeButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            closeButton.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        // Set our own size to wrap content
        setContentHuggingPriority(.defaultHigh, for: .horizontal)
        setContentHuggingPriority(.defaultHigh, for: .vertical)
        setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
    }
    
    // Setter for onClose callback
    func setOnCloseListener(onClose: @escaping () -> Void) {
        self.onClose = onClose
    }
    
    // Called when the close button is tapped
    @objc private func closeButtonTapped() {
        onClose?()
    }
}
