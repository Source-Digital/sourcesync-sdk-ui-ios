//
//  Activation.swift
//  sourcesync-sdk-ui-ios
//
import UIKit

// A view representing an activation component with preview and detail views.
public class ActivationView: UIView {
    
    private var previewView: ActivationPreview?
    private var detailView: ActivationDetail?
    private var onPreviewClickHandler: (() -> Void)?
    private var progressTimer: Timer?
    
    // Progress indicator components
    private var progressContainerView: UIView?
    private var progressLayer: CAShapeLayer?
    private var centerImageView: UIImageView?
    
    // Animation configuration
    private let animationDuration: TimeInterval = 1
    private var progressDuration: TimeInterval = 10.0
    
    // Constants for positioning
    private let previewHeight: CGFloat = 50.0 // 50dp height
    private let progressTopMargin: CGFloat = 20.0 // Top padding for progress
    private let progressRightMargin: CGFloat = 20.0 // Right padding for progress
    private let previewRightMargin: CGFloat = 10.0 // Margin between preview and progress
    private let detailWidthPercentage: CGFloat = 0.55 // 55% of screen width in landscape
    private let progressSize: CGFloat = 70.0 // Size of circular progress
    private let progressStrokeWidth: CGFloat = 8.0 // Progress stroke width
    
    // Shows the preview view with given data.
    // - Parameters:
    //   - previewData: JSON data for preview.
    //   - onClick: Closure to execute on click.
    //   - showProgress: Whether to show the progress indicator.
    //   - progressDuration: Duration of the progress countdown in seconds.
    //   - progressImage: Optional image to display in the center of the progress circle.
    public func showPreview(
        previewData: [String: Any],
        showProgress: Bool = false,
        progressDuration: TimeInterval = 10.0,
        progressImage: UIImage? = nil,
        onClick: @escaping () -> Void
    ) {
        if let previewView = previewView {
            previewView.removeFromSuperview()
        }
        
        // Cancel any existing timer
        progressTimer?.invalidate()
        progressTimer = nil
        
        // Remove existing progress components
        removeProgressIndicator()
        
        // Update progress duration
        self.progressDuration = progressDuration
        
        self.onPreviewClickHandler = onClick
        
        // First, create and position the progress indicator if requested
        if showProgress {
            setupCircularProgress(withImage: progressImage)
        }
        
        // Create the preview view
        previewView = ActivationPreview(data: previewData)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(previewTapped))
        previewView?.addGestureRecognizer(tapGesture)
        previewView?.isUserInteractionEnabled = true
                
        if let previewView = previewView {
            previewView.alpha = 0.0 // Start fully transparent
            previewView.translatesAutoresizingMaskIntoConstraints = false
            addSubview(previewView)
            
            // Position the preview to the left of the progress indicator
            if let progressContainer = progressContainerView {
                NSLayoutConstraint.activate([
                    previewView.centerYAnchor.constraint(equalTo: progressContainer.centerYAnchor),
                    previewView.trailingAnchor.constraint(equalTo: progressContainer.leadingAnchor, constant: -previewRightMargin),
                    // Set minimum height constraint but allow intrinsic height to take precedence
                    previewView.heightAnchor.constraint(greaterThanOrEqualToConstant: 50.0)

                ])
            } else {
                // If no progress indicator, position at top right
                NSLayoutConstraint.activate([
                    previewView.topAnchor.constraint(equalTo: self.topAnchor, constant: progressTopMargin),
                    previewView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -progressRightMargin),
                    // Set minimum height constraint but allow intrinsic height to take precedence
                    previewView.heightAnchor.constraint(greaterThanOrEqualToConstant: 50.0)

                ])
            }
            
            // Ensure the preview uses its intrinsic content size
            previewView.setContentHuggingPriority(.required, for: .vertical)
            previewView.setContentCompressionResistancePriority(.required, for: .vertical)
            
            // Fade-in animation
            UIView.animate(withDuration: animationDuration) {
                previewView.alpha = 1.0
            } completion: { _ in
                // Start progress animation if needed
                if showProgress {
                    self.startProgressAnimation()
                }
            }
        }
    }
    
    private func setupCircularProgress(withImage image: UIImage?) {
        // Create container for the progress indicator
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(containerView)
        
        // Position the container at the top right with specified margins
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: self.topAnchor, constant: progressTopMargin),
            containerView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -progressRightMargin),
            containerView.widthAnchor.constraint(equalToConstant: progressSize),
            containerView.heightAnchor.constraint(equalToConstant: progressSize)
        ])
        
        // Create the circular path for the progress
        let circularPath = UIBezierPath(
            arcCenter: CGPoint(x: progressSize/2, y: progressSize/2),
            radius: progressSize/2 - progressStrokeWidth/2, // Adjust radius for stroke width
            startAngle: -CGFloat.pi / 2, // Start from top
            endAngle: 2 * CGFloat.pi - CGFloat.pi / 2, // Full circle
            clockwise: true
        )
        
        // Create track layer (background circle)
        let trackLayer = CAShapeLayer()
        trackLayer.path = circularPath.cgPath
        trackLayer.strokeColor = UIColor.lightGray.withAlphaComponent(0.3).cgColor
        trackLayer.lineWidth = progressStrokeWidth
        trackLayer.fillColor = UIColor.clear.cgColor
        trackLayer.lineCap = .round
        containerView.layer.addSublayer(trackLayer)
        
        // Create progress layer
        let progressLayer = CAShapeLayer()
        progressLayer.path = circularPath.cgPath
        progressLayer.strokeColor = UIColor.green.cgColor
        progressLayer.lineWidth = progressStrokeWidth
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.lineCap = .round
        progressLayer.strokeEnd = 1.0 // Start full and animate down
        containerView.layer.addSublayer(progressLayer)
        
        // Add center image if provided
        if let centerImage = image {
            let imageView = UIImageView(image: centerImage)
            imageView.contentMode = .scaleAspectFit
            imageView.translatesAutoresizingMaskIntoConstraints = false
            containerView.addSubview(imageView)
            
            // Position image in center with appropriate size
            NSLayoutConstraint.activate([
                imageView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
                imageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
                imageView.widthAnchor.constraint(equalToConstant: progressSize * 0.8),
                imageView.heightAnchor.constraint(equalToConstant: progressSize * 0.8)
            ])
            
            imageView.image = centerImage
            
            self.centerImageView = imageView
        }
        
        self.progressContainerView = containerView
        self.progressLayer = progressLayer
    }
    
    private func startProgressAnimation() {
        guard let progressLayer = self.progressLayer else { return }
        
        let startTime = Date()
        
        // Reset progress
        progressLayer.strokeEnd = 1.0
        
        // Create a timer that updates every 1/60 second
        progressTimer = Timer.scheduledTimer(withTimeInterval: 1.0/60.0, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }
            
            let elapsedTime = Date().timeIntervalSince(startTime)
            let remainingPercentage = max(0, 1.0 - (elapsedTime / self.progressDuration))
            
            // Update the progress layer
            progressLayer.strokeEnd = CGFloat(remainingPercentage)
            
            // When countdown completes
            if elapsedTime > self.progressDuration {
                timer.invalidate()
                self.progressTimer = nil
                
                // Only hide the preview when time runs out
                UIView.animate(withDuration: 0.01) {
                    self.progressContainerView?.alpha = 0
                    self.previewView?.alpha = 0
                } completion: { _ in
                    self.removeProgressIndicator()
                    self.previewView?.isHidden = true
                }
            }
        }
    }
    
    private func removeProgressIndicator() {
        progressContainerView?.removeFromSuperview()
        progressContainerView = nil
        progressLayer = nil
        centerImageView = nil
    }
    
    @objc private func previewTapped() {
        // Stop the progress timer when preview is tapped
//        progressTimer?.invalidate()
//        progressTimer = nil
//        
//        // Hide only the progress indicator, not the preview
//        UIView.animate(withDuration: 0.3) {
//            self.progressContainerView?.alpha = 0
//        } completion: { _ in
//            self.removeProgressIndicator()
//        }
        
        onPreviewClickHandler?()
    }
    
    // Shows the detail view with given data.
    // - Parameters:
    //   - detailData: JSON data for detail.
    //   - onClose: Closure to execute on close.
    public func showDetail(detailData: [String: Any], onClose: @escaping () -> Void) {
        if let detailView = detailView {
            detailView.removeFromSuperview()
        }
        
        // Hide preview with fade-out
        if let previewView = previewView {
            UIView.animate(withDuration: animationDuration, animations: {
                previewView.alpha = 0.0
            }) { _ in
                previewView.isHidden = true
                self.progressContainerView?.isHidden = true
            }
        }
        
        // Make sure the progress indicator is also hidden
//        removeProgressIndicator()
//        progressTimer?.invalidate()
//        progressTimer = nil
        
        if let template = detailData["template"] as? [[String: Any]] {
            detailView = ActivationDetail(template: template, onClose: onClose)
            
            // Guard against nil before adding as subview
            if let detailView = detailView {
                detailView.translatesAutoresizingMaskIntoConstraints = false
                addSubview(detailView)
                
                // Position the detail view on the right side, full height
                NSLayoutConstraint.activate([
                    detailView.topAnchor.constraint(equalTo: self.topAnchor),
                    detailView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
                    detailView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
                    detailView.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: detailWidthPercentage)
                ])
                
                // Animate the detail view appearance
                detailView.alpha = 0
                UIView.animate(withDuration: animationDuration) {
                    detailView.alpha = 1.0
                }
            }
        }
    }
    
    // Hides the detail view and restores preview.
    public func hideDetail() {
        // Animate detail view disappearance
        if let detailView = self.detailView {
            UIView.animate(withDuration: self.animationDuration, animations: {
                detailView.alpha = 0.0
            }) { _ in
                detailView.removeFromSuperview()
                self.detailView = nil
                
                // Restore preview
                self.previewView?.isHidden = false
                self.progressContainerView?.isHidden = false
                UIView.animate(withDuration: self.animationDuration) {
                    self.previewView?.alpha = 1.0
                }
            }
        }
    }
    
    // Make sure to clean up when the view is removed
    public override func removeFromSuperview() {
        progressTimer?.invalidate()
        progressTimer = nil
        super.removeFromSuperview()
    }
}
