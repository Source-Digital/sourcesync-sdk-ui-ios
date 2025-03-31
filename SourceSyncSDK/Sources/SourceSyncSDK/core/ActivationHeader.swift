//
//  ActivationHeader.swift
//  sourcesync-sdk-ui-ios
//

import UIKit

// A view representing an activation header with a close button.
class ActivationHeader: UIView {
    
    // Initializes the activation header with a close button.
    // - Parameters:
    //   - onClose: A closure to be executed when the close button is tapped.
    init(onClose: @escaping () -> Void) {
        super.init(frame: .zero)
        initializeView(onClose: onClose)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Sets up the view with a close button.
    // - Parameter onClose: The closure to be executed when the close button is tapped.
    private func initializeView(onClose: @escaping () -> Void) {
        translatesAutoresizingMaskIntoConstraints = false
        
        // Create close button with improved styling
        let closeButton = UIButton(type: .system)
        closeButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        closeButton.tintColor = .white // White X for better contrast
        closeButton.backgroundColor = UIColor(red: 0.15, green: 0.15, blue: 0.15, alpha: 0.75) // Semi-transparent dark gray
        closeButton.layer.cornerRadius = 12 // Rounded corners
        closeButton.layer.borderWidth = 1 // Add border
        closeButton.layer.borderColor = UIColor.white.withAlphaComponent(0.3).cgColor // Subtle white border
        
        // Add shadow for better visibility
        closeButton.layer.shadowColor = UIColor.black.cgColor
        closeButton.layer.shadowOffset = CGSize(width: 0, height: 1)
        closeButton.layer.shadowRadius = 2
        closeButton.layer.shadowOpacity = 0.3
        
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        
        addSubview(closeButton)
        
        // Set constraints with larger touch target
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            closeButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            closeButton.topAnchor.constraint(equalTo: topAnchor),
            closeButton.widthAnchor.constraint(equalToConstant: 28), // Slightly larger
            closeButton.heightAnchor.constraint(equalToConstant: 28)
        ])
        
        // Store onClose action
        self.onClose = onClose
    }
    
    private var onClose: (() -> Void)?
    
    // Called when the close button is tapped.
    @objc private func closeButtonTapped() {
        onClose?()
    }
}
