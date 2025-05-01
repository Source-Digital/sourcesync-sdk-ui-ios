//
//  Activation.swift
//  sourcesync-sdk-ui-ios
//
import UIKit

/**
 * A view representing an activation component with preview and detail views.
 */
public class ActivationView: UIView {
    
    private static let TAG = "SDK:ActivationView"
    
    private var previewView: ActivationPreview?
    private var detailView: ActivationDetail?
    private var onPreviewClickHandler: (() -> Void)?
    private var progressManager: CircularProgressManager!
    
    // Animation configuration
    private static let ANIMATION_DURATION: TimeInterval = 1.5 // 1.5 seconds
    private var progressDuration: TimeInterval = 10.0 // 10 seconds
    
    private static let DETAIL_WIDTH_PERCENTAGE: CGFloat = 0.60 // 55% of screen width in landscape
    
    // Default templates
    private var defaultPreviewTemplate: [String: Any]?
    private var defaultDetailTemplate: [String: Any]?
    
    private let handler = DispatchQueue.main
    
    /**
     * Constructor for the ActivationView
     * @param context The UIViewController
     */
    public init(context: UIViewController) {
        super.init(frame: .zero)
        init_()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        init_()
    }
    
    private func init_() {
        // Load default templates
        defaultPreviewTemplate = TemplateStorage.defaultPreviewTemplate
        defaultDetailTemplate = TemplateStorage.defaultDetailTemplate
        
        // Initialize progress manager
        progressManager = CircularProgressManager(self)
        progressManager.setProgressCompleteListener { [weak self] in
            guard let self = self else { return }
            if let previewView = self.previewView {
                previewView.isHidden = true
            }
            if let detailView = self.detailView {
                detailView.isHidden = true
            }
        }
    }
    
    /**
     * Shows the preview view with given data.
     *
     * @param previewData JSON data for preview.
     * @param showProgress Whether to show the progress indicator.
     * @param progressDuration Duration of the progress countdown in milliseconds.
     * @param progressImage Optional image to display in the center of the progress circle.
     * @param onClick Closure to execute on click.
     */
    public func showPreview(
        previewData: [String: Any],
        showProgress: Bool = true,
        progressDuration: TimeInterval,
        progressImage: UIImage? = nil,
        onClick: @escaping () -> Void
    ) {
        if let previewView = previewView {
            previewView.removeFromSuperview()
        }
        
        // Remove existing progress
        progressManager.removeProgressIndicator()
        
        // Update progress duration
        self.progressDuration = progressDuration
        
        self.onPreviewClickHandler = onClick
        
        // Use default template if none provided
        var templateToUse = previewData
        if let template = previewData["template"] as? [[String: Any]], template.isEmpty {
            templateToUse = defaultPreviewTemplate ?? [:]
            progressManager.setupCircularProgress(withImage: progressImage)
        }
        
            previewView = ActivationPreview(previewData: templateToUse)
            
            if let previewView = previewView {
                previewView.alpha = 0 // Start fully transparent
                
                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(previewTapped))
                previewView.addGestureRecognizer(tapGesture)
                previewView.isUserInteractionEnabled = true
                
                previewView.translatesAutoresizingMaskIntoConstraints = false
                addSubview(previewView)
                
                // Set layout parameters
                var topConstraint: NSLayoutConstraint
                var trailingConstraint: NSLayoutConstraint
                
                // Position at the right side, either next to progress or at the edge
                // Set right margin to 10dp equivalent
                let rightMargin: CGFloat = 10 * (UIScreen.main.bounds.width / 375.0)
                
                // Set top margin - default
                let topMargin: CGFloat = 10 * (UIScreen.main.bounds.width / 375.0)
                
                topConstraint = previewView.topAnchor.constraint(equalTo: topAnchor, constant: topMargin)
                trailingConstraint = previewView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -rightMargin)
                
                NSLayoutConstraint.activate([
                    topConstraint,
                    trailingConstraint
                ])
                
                // Adjust position after layout is complete
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    
                    if let progressContainer = self.progressManager.getProgressContainerView() {
                        // Position preview to the left of progress circle
                        // Calculate the preview's right margin to position it to the left of progress
                        let newRightMargin = rightMargin + progressContainer.frame.width
                        
                        // Update the trailing constraint
                        trailingConstraint.constant = -newRightMargin
                        
                        // Center vertically with progress
                        let progressCenterY = progressContainer.frame.origin.y + progressContainer.frame.height / 2
                        let previewHeight = previewView.frame.height
                        let newTopMargin = progressCenterY - previewHeight / 2
                        topConstraint.constant = max(0, newTopMargin)
                        
                        self.layoutIfNeeded()
                        
                        print("\(ActivationView.TAG): Positioned preview to the left of progress: right margin = \(newRightMargin)")
                    } else {
                        // Position at the right edge if no progress
                        print("\(ActivationView.TAG): Positioned preview at right edge, no progress indicator")
                    }
                }
                
                // Fade-in animation
                UIView.animate(withDuration: ActivationView.ANIMATION_DURATION, animations: {
                    previewView.alpha = 1.0
                }, completion: { _ in
                    // Start progress animation if needed
                    if showProgress, self.progressManager.getProgressContainerView() != nil {
                        self.progressManager.startProgressAnimation(self.progressDuration)
                    }
                })
            }

    }
    
    /**
     * Shows the preview with default settings
     * @param previewData The preview template data
     * @param onClick Click listener
     */
    public func showPreview(previewData: [String: Any], onClick: @escaping () -> Void) {
        showPreview(previewData: previewData, showProgress: true, progressDuration: 10, progressImage: nil, onClick: onClick)
    }
    
    /**
     * Shows the detail view with given data.
     *
     * @param detailData JSON data for detail.
     * @param onClose Closure to execute on close.
     */
    public func showDetail(detailData: [String: Any], onClose: @escaping () -> Void) {
        if let detailView = detailView {
            detailView.removeFromSuperview()
        }
        
        // Hide preview with fade-out
        if let previewView = previewView {
            UIView.animate(withDuration: ActivationView.ANIMATION_DURATION, animations: {
                previewView.alpha = 0
            }, completion: { _ in
                previewView.isHidden = true
                self.progressManager.setVisibility(false)
            })
        }
        
        // Use default template if none provided
        var detailsTemplateToUse = detailData
   
            if let template = detailData["template"] as? [[String: Any]], template.isEmpty {
                detailsTemplateToUse = defaultDetailTemplate ?? [:]
            }
       
            guard let templateArray = detailsTemplateToUse["template"] as? [[String: Any]] else {
                print("\(ActivationView.TAG): Error: template is not an array")
                return
            }
            
            detailView = ActivationDetail(template: templateArray, onClose: onClose)
            
            if let detailView = detailView {
                detailView.translatesAutoresizingMaskIntoConstraints = false
                
                // Calculate width based on percentage
                let detailWidth = frame.width * ActivationView.DETAIL_WIDTH_PERCENTAGE
                
                detailView.alpha = 0
                addSubview(detailView)
                
                // Set constraints - position at the right edge, full height
                NSLayoutConstraint.activate([
                    detailView.trailingAnchor.constraint(equalTo: trailingAnchor),
                    detailView.topAnchor.constraint(equalTo: topAnchor),
                    detailView.bottomAnchor.constraint(equalTo: bottomAnchor),
                    detailView.widthAnchor.constraint(equalToConstant: detailWidth)
                ])
                
                // Animate the detail view appearance
                UIView.animate(withDuration: ActivationView.ANIMATION_DURATION) {
                    detailView.alpha = 1.0
                }
            }
    }
    
    /**
     * Hides the detail view and restores preview.
     */
    public func hideDetail() {
        if let detailView = detailView {
            // For immediate removal without animation (matching Android implementation)
            removeView(detailView)
            self.detailView = nil
        }
    }
    
    private func removeView(_ view: UIView) {
        view.removeFromSuperview()
    }
    
    @objc private func previewTapped() {
        if let handler = onPreviewClickHandler {
            handler()
        }
    }
    
    deinit {
        // Clean up resources
        progressManager.removeProgressIndicator()
    }
}
