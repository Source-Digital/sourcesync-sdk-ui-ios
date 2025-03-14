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
        
        mainContainer.axis = .horizontal
        mainContainer.spacing = 8
        mainContainer.translatesAutoresizingMaskIntoConstraints = false
        
        // Configure content container
        contentContainer.axis = .vertical
        contentContainer.spacing = 8
        contentContainer.translatesAutoresizingMaskIntoConstraints = false
        
        // 1. Set different background colors to debug layout issues
//        scrollView.backgroundColor = UIColor.darkGray.withAlphaComponent(0.5) // Semi-transparent to see layout
        mainContainer.backgroundColor = UIColor.darkGray.withAlphaComponent(0.5)
        
        // First add all views to the hierarchy
        mainContainer.addArrangedSubview(contentContainer)
        mainContainer.addArrangedSubview(header)
        addSubview(mainContainer)

        NSLayoutConstraint.activate([
            header.topAnchor.constraint(equalTo: mainContainer.topAnchor),
            header.trailingAnchor.constraint(equalTo: mainContainer.trailingAnchor, constant: -10),
        ])
//
        // Content container starts from top left with minimum size requirements
        NSLayoutConstraint.activate([
            // Position at top left with padding
            contentContainer.topAnchor.constraint(equalTo: mainContainer.topAnchor, constant: 10),
            contentContainer.leadingAnchor.constraint(equalTo: mainContainer.leadingAnchor, constant: 10),
            contentContainer.trailingAnchor.constraint(equalTo: mainContainer.trailingAnchor, constant: -50),
            contentContainer.bottomAnchor.constraint(equalTo: mainContainer.bottomAnchor, constant: -50),

        ])
        

        NSLayoutConstraint.activate([
            mainContainer.topAnchor.constraint(equalTo: topAnchor),
            mainContainer.leadingAnchor.constraint(equalTo: leadingAnchor),
            mainContainer.trailingAnchor.constraint(equalTo: trailingAnchor),
            mainContainer.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            
            // Ensure width is at least 90% of screen width
            contentContainer.widthAnchor.constraint(greaterThanOrEqualTo: widthAnchor, multiplier: 0.9),
            // Ensure height is at least 80% of screen height
            contentContainer.heightAnchor.constraint(greaterThanOrEqualTo: heightAnchor, multiplier: 0.9)
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
