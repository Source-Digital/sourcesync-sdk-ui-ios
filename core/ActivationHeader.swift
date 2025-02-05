//
//  ActivationHeader.swift
//  sourcesync-sdk-ui-ios
//

import SwiftUI

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
        
        // Create close button
        let closeButton = UIButton(type: .system)
        closeButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        closeButton.tintColor = .black
        closeButton.backgroundColor = .clear
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        
        addSubview(closeButton)
        
        // Set constraints
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            closeButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            closeButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            closeButton.widthAnchor.constraint(equalToConstant: 24),
            closeButton.heightAnchor.constraint(equalToConstant: 24)
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

