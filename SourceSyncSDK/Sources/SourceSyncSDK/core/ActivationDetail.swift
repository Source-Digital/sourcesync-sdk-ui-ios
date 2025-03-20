//
//  ActivationDetail.swift
//  sourcesync-sdk-ui-ios
//
import UIKit

// A view representing activation details with a customizable template.
class ActivationDetail: UIView {
    private let mainContainer = UIStackView()
    private let contentContainer = UIStackView()
    private let scrollView = UIScrollView()
    private let processorFactory: SegmentProcessorFactory
    
    // Initializes the activation detail view with a given template and close action.
    // - Parameters:
    //   - template: JSON array representing the template structure.
    //   - onClose: Closure executed when the close button is pressed.
   public init(template: [[String: Any]], onClose: @escaping () -> Void) {
        self.processorFactory = SegmentProcessorFactory(parentContainer: contentContainer)
        super.init(frame: .zero)
        initializeView(template: template, onClose: onClose)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initializeView(template: [[String: Any]], onClose: @escaping () -> Void) {
        translatesAutoresizingMaskIntoConstraints = false
            
            // Create and configure header
            let header = ActivationHeader(onClose: onClose)
            header.translatesAutoresizingMaskIntoConstraints = false
            
            mainContainer.axis = .vertical // Changed to vertical for better layout
            mainContainer.spacing = 0 // Remove spacing to have precise control
            mainContainer.translatesAutoresizingMaskIntoConstraints = false
            mainContainer.backgroundColor = UIColor.black.withAlphaComponent(0.8) // Consistent background
            
            // Configure content container
            contentContainer.axis = .vertical
            contentContainer.spacing = 8
            contentContainer.translatesAutoresizingMaskIntoConstraints = false
            
            // Add container and header to the view hierarchy
            addSubview(mainContainer)
            mainContainer.addSubview(contentContainer)
            mainContainer.addSubview(header) // Add header directly to main container
            
            // Main container fills the entire view
            NSLayoutConstraint.activate([
                mainContainer.topAnchor.constraint(equalTo: topAnchor),
                mainContainer.leadingAnchor.constraint(equalTo: leadingAnchor),
                mainContainer.trailingAnchor.constraint(equalTo: trailingAnchor),
                mainContainer.bottomAnchor.constraint(equalTo: bottomAnchor)
            ])
            
            // Position header at top right with 10pt margin
            NSLayoutConstraint.activate([
                header.topAnchor.constraint(equalTo: mainContainer.topAnchor, constant: 10),
                header.trailingAnchor.constraint(equalTo: mainContainer.trailingAnchor, constant: -10),
                header.widthAnchor.constraint(equalToConstant: 44), // Give it enough space
                header.heightAnchor.constraint(equalToConstant: 44)
            ])
            
            // Content container takes up most of the space with proper margins
            NSLayoutConstraint.activate([
                contentContainer.topAnchor.constraint(equalTo: mainContainer.topAnchor, constant: 16),
                contentContainer.leadingAnchor.constraint(equalTo: mainContainer.leadingAnchor, constant: 16),
                contentContainer.trailingAnchor.constraint(equalTo: mainContainer.trailingAnchor, constant: -16),
                contentContainer.bottomAnchor.constraint(equalTo: mainContainer.bottomAnchor, constant: -16),
                
                // Ensure minimum dimensions
                contentContainer.widthAnchor.constraint(greaterThanOrEqualTo: mainContainer.widthAnchor, multiplier: 0.9),
                contentContainer.heightAnchor.constraint(greaterThanOrEqualTo: mainContainer.heightAnchor, multiplier: 0.9)
            ])
            
        
        // Process and render template
        processTemplate(template)
    }
    
    // Processes the given template and adds corresponding views.
    private func processTemplate(_ template: [[String: Any]]) {
        for segment in template {
            if let segmentType = segment["type"] as? String,
               let processor = processorFactory.getProcessor(for: segmentType) {
                do {
                    let segmentView = try processor.processSegment(segment: segment)
                    contentContainer.addArrangedSubview(segmentView)
                } catch {
                    print("Error processing template: \(error.localizedDescription)")
                }
                
            }
        }
        // Force layout update
        contentContainer.layoutIfNeeded()
//        scrollView.layoutIfNeeded()
    }
}
