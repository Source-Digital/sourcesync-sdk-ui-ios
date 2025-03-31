//
//  ActivationPreview.swift
//  sourcesync-sdk-ui-ios
//

import UIKit

// A view representing an activation preview with customizable content.
class ActivationPreview: UIView {
    private static let TAG = "ActivationPreview"
    private var contentContainer: UIStackView!
    private var processorFactory: SegmentProcessorFactory!
    
    // Constructor for programmatic creation
    init(previewData: [String: Any]) {
        super.init(frame: .zero)
        initializeView(previewData: previewData)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initializeView(previewData: [:])
    }
    
    private func initializeView(previewData: [String: Any]) {
        // Set a sensible intrinsic content size
        self.translatesAutoresizingMaskIntoConstraints = false
        
        // Create content container
        contentContainer = UIStackView()
        contentContainer.axis = .vertical
        contentContainer.translatesAutoresizingMaskIntoConstraints = false
        contentContainer.spacing = 8
        
        // Apply background color and opacity
        contentContainer.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 153/255)
        contentContainer.layer.cornerRadius = 8
        
        // Initialize processor factory
        processorFactory = SegmentProcessorFactory(parentContainer: contentContainer)
        
        // Add content container to view
        addSubview(contentContainer)
        
        // Get padding values
        let paddingTop = 10.0 * (UIScreen.main.bounds.width / 375.0) // Scale for device
        let paddingBottom = 10.0 * (UIScreen.main.bounds.width / 375.0)
        let paddingLeft = 16.0 * (UIScreen.main.bounds.width / 375.0)
        let paddingRight = 16.0 * (UIScreen.main.bounds.width / 375.0)
        
        // Apply padding through layout margins
        contentContainer.layoutMargins = UIEdgeInsets(
            top: paddingTop,
            left: paddingLeft,
            bottom: paddingBottom,
            right: paddingRight
        )
        contentContainer.isLayoutMarginsRelativeArrangement = true
        
        // Set layout constraints
        NSLayoutConstraint.activate([
            contentContainer.topAnchor.constraint(equalTo: topAnchor),
            contentContainer.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentContainer.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentContainer.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        setContentCompressionResistancePriority(.required, for: .horizontal)
        setContentCompressionResistancePriority(.required, for: .vertical)
        
        // Process template if provided
        if let previewDict = previewData as? [String: Any],
           let template = previewDict["template"] as? [[String: Any]] {
            processTemplate(template)
        }
    }
    
    private func processTemplate(_ template: [[String: Any]]) {
        for segment in template {
            if let segmentType = segment["type"] as? String {
                if let processor = processorFactory.getProcessor(for: segmentType) {
                    do {
                        let segmentView = try processor.processSegment(segment: segment)
                        contentContainer.addArrangedSubview(segmentView)
                    } catch {
                        print("\(ActivationPreview.TAG): Error processing template segments: \(error)")
                    }
                } else {
                    print("\(ActivationPreview.TAG): No processor found for segment type: \(segmentType)")
                }
            }
        }
        
        // After all segments are added, set a reasonable size
        invalidateIntrinsicContentSize()
    }
    
    override var intrinsicContentSize: CGSize {
        return contentContainer.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
    }
}
