//
//  ActivationDetail.swift
//  sourcesync-sdk-ui-ios
//
import UIKit

// A view representing activation details with a customizable template.
public class ActivationDetail: UIView {
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
    
    // Sets up the view with provided template and close action.
    private func initializeView(template: [[String: Any]], onClose: @escaping () -> Void) {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = UIColor.black.withAlphaComponent(0.8)
        
        // Create and configure header
        let header = ActivationHeader(onClose: onClose)
        
        // Configure scroll view
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.alwaysBounceVertical = true
        
        // Configure content container
        contentContainer.axis = .vertical
        contentContainer.spacing = 8
        contentContainer.translatesAutoresizingMaskIntoConstraints = false
        
        // Embed content container inside scroll view
        scrollView.addSubview(contentContainer)
        
        // Main stack to hold header and scrollable content
        let mainStack = UIStackView(arrangedSubviews: [header, scrollView])
        mainStack.axis = .vertical
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(mainStack)
        
        NSLayoutConstraint.activate([
            mainStack.leadingAnchor.constraint(equalTo: leadingAnchor),
            mainStack.trailingAnchor.constraint(equalTo: trailingAnchor),
            mainStack.topAnchor.constraint(equalTo: topAnchor),
            mainStack.bottomAnchor.constraint(equalTo: bottomAnchor),
            
//            scrollView.widthAnchor.constraint(equalTo: mainStack.widthAnchor),
//            contentContainer.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
//            contentContainer.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
//            contentContainer.topAnchor.constraint(equalTo: scrollView.topAnchor),
//            contentContainer.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
//            contentContainer.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
        
        // Add constraints for the content container inside the scroll view
        NSLayoutConstraint.activate([
            contentContainer.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentContainer.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentContainer.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentContainer.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            
            // Ensure the content container's width matches the scroll view's width
            contentContainer.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
        
        let label = UILabel()
        label.text = "This is a label"
        label.translatesAutoresizingMaskIntoConstraints = false
        contentContainer.addArrangedSubview(label)

        let button = UIButton(type: .system)
        button.setTitle("Click Me", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        contentContainer.addArrangedSubview(button)
        
        
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
    }
}
