//
//  ActivationDetail.swift
//  sourcesync-sdk-ui-ios
//
import UIKit

// A view representing activation details with a customizable template.
class ActivationDetail: UIView {
    private static let TAG = "ActivationDetail"
    private var processorFactory: SegmentProcessorFactory!
    private var contentContainer: UIStackView!
    private var scrollView: UIScrollView!
    
    // Constructor for code instantiation (matches Android)
    public init(template: [[String: Any]], onClose: @escaping () -> Void) {
        super.init(frame: .zero)
        initializeView(template: template, onClose: onClose)
    }
    
    // Constructor for Interface Builder/Storyboard (matches Android)
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        // Initialize with empty template and null callback
        // These should be set later with setter methods
        initializeView(template: nil, onClose: nil)
    }
    
    // Setters for template and close listener (matches Android)
    public func setTemplate(_ template: [[String: Any]]) {
        if template.count > 0 {
            processTemplate(template)
        }
    }
    
    public func setOnCloseListener(_ onClose: @escaping () -> Void) {
        // If we already have header views, update their listeners
    }
    
    private func initializeView(template: [[String: Any]]?, onClose: (() -> Void)?) {
        print("\(ActivationDetail.TAG): Initializing ActivationDetail view")
        
        translatesAutoresizingMaskIntoConstraints = false

            // Create main container
            let mainContainer = UIStackView()
            mainContainer.axis = .vertical
            mainContainer.translatesAutoresizingMaskIntoConstraints = false
            mainContainer.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 153/255) // 0.6 alpha (153/255)
            
            // Create ScrollView to wrap contentContainer
            scrollView = UIScrollView()
            scrollView.translatesAutoresizingMaskIntoConstraints = false
            
            // Create content container inside the ScrollView
            contentContainer = UIStackView()
            contentContainer.axis = .vertical
            contentContainer.translatesAutoresizingMaskIntoConstraints = false
            contentContainer.spacing = 5 * (UIScreen.main.bounds.width / 375.0)
            
            // Set padding for content container
            contentContainer.layoutMargins = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
            contentContainer.isLayoutMarginsRelativeArrangement = true
            
            // Add contentContainer to ScrollView
            scrollView.addSubview(contentContainer)
            
            // Create header
            let header = ActivationHeader(onClose: onClose ?? {})
            
            // Initialize processor factory
            processorFactory = SegmentProcessorFactory(parentContainer: contentContainer)
            
            // Add views to the hierarchy
            addSubview(mainContainer)
            
            // Add header to mainContainer
            mainContainer.addSubview(header)
            
            // Header layout - position at top with margins
            let margin = 15.0 // 15dp margin
            header.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                header.topAnchor.constraint(equalTo: mainContainer.topAnchor, constant: margin),
                header.leadingAnchor.constraint(equalTo: mainContainer.leadingAnchor, constant: margin),
                header.widthAnchor.constraint(equalToConstant: 15 * (UIScreen.main.bounds.width / 375.0)), // 45dp
                header.heightAnchor.constraint(equalToConstant: 15 * (UIScreen.main.bounds.width / 375.0))  // 45dp
            ])
            
            // Add the ScrollView to mainContainer
            mainContainer.addSubview(scrollView)
            
            // ScrollView layout - position below header with margins
        let contentMargin = 5.0
            NSLayoutConstraint.activate([
                scrollView.topAnchor.constraint(equalTo: header.bottomAnchor),
                scrollView.leadingAnchor.constraint(equalTo: mainContainer.leadingAnchor, constant: contentMargin),
                scrollView.trailingAnchor.constraint(equalTo: mainContainer.trailingAnchor, constant: -contentMargin),
                scrollView.bottomAnchor.constraint(equalTo: mainContainer.bottomAnchor, constant: -contentMargin)
            ])
            
            // Content container constraints within scroll view
            NSLayoutConstraint.activate([
                contentContainer.topAnchor.constraint(equalTo: scrollView.topAnchor),
                contentContainer.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
                contentContainer.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
                contentContainer.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
                contentContainer.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
            ])
            
            // Main container fills the frame
            NSLayoutConstraint.activate([
                mainContainer.topAnchor.constraint(equalTo: topAnchor),
                mainContainer.leadingAnchor.constraint(equalTo: leadingAnchor),
                mainContainer.trailingAnchor.constraint(equalTo: trailingAnchor),
                mainContainer.bottomAnchor.constraint(equalTo: bottomAnchor)
            ])
            
            // Process template if available
            if let template = template, !template.isEmpty {
                processTemplate(template)
            }
    }
    
    // Override touch handling to match Android behavior
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Consume all touch events to prevent them from propagating
        super.touchesBegan(touches, with: event)
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        // Don't intercept touch events to allow scrolling and clicking of child views
        return super.point(inside: point, with: event)
    }
    
    private func processTemplate(_ template: [[String: Any]]) {
        if template.isEmpty {
            return
        }
        
        for segment in template {
            guard let segmentType = segment["type"] as? String else {
                continue
            }
            
            print("\(ActivationDetail.TAG): Processing segment type: \(segmentType)")
            
            if let processor = processorFactory.getProcessor(for: segmentType) {
                do {
                    let segmentView = try processor.processSegment(segment: segment)
                
                        contentContainer.addArrangedSubview(segmentView)
                        
                        // Set appropriate content hugging and compression resistance
                        segmentView.setContentHuggingPriority(.defaultLow, for: .horizontal)
                        segmentView.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
                        
                        print("\(ActivationDetail.TAG): Successfully added segment view to contentContainer")

                } catch {
                    print("\(ActivationDetail.TAG): Error processing segment of type: \(segmentType): \(error)")
                }
            } else {
                print("\(ActivationDetail.TAG): No processor found for segment type: \(segmentType)")
            }
        }
        
        // Force layout update
        contentContainer.setNeedsLayout()
        contentContainer.layoutIfNeeded()
    }
}
