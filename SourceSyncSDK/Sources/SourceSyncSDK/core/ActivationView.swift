//
//  Activation.swift
//  sourcesync-sdk-ui-ios
//
import UIKit

// A view representing an activation component with preview and detail views.
class ActivationView: UIView {
    
    private var previewView: ActivationPreview?
    private var detailView: ActivationDetail?
    
    // Shows the preview view with given data.
    
    // - Parameters:
    //   - previewData: JSON data for preview.
    //   - onClick: Closure to execute on click.
    func showPreview(previewData: [String: Any], onClick: @escaping () -> Void) {
        if let previewView = previewView {
            previewView.removeFromSuperview()
        }
        
        // Create the preview view
        previewView = ActivationPreview(data: previewData)
        previewView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(previewTapped)))
        
        if let previewView = previewView {
            addSubview(previewView)
            
            // Configure fixed size based on screen dimensions
            // Assuming landscape orientation
            let screenWidth = UIScreen.main.bounds.width > UIScreen.main.bounds.height ?
                              UIScreen.main.bounds.width : UIScreen.main.bounds.height
            let screenHeight = UIScreen.main.bounds.width > UIScreen.main.bounds.height ?
                               UIScreen.main.bounds.height : UIScreen.main.bounds.width
            
            // Set fixed size (40% of width, 20% of height)
            let previewWidth = screenWidth * 0.4
            let previewHeight = screenHeight * 0.2
            
            // Position in the center of the view
            previewView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                previewView.widthAnchor.constraint(equalToConstant: previewWidth),
                previewView.heightAnchor.constraint(equalToConstant: previewHeight),
                previewView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
                previewView.centerYAnchor.constraint(equalTo: self.centerYAnchor)
            ])
        }
    }
    
    @objc private func previewTapped() {
        // Handle preview tap
    }
    
    // Shows the detail view with given data.
    // - Parameters:
    //   - detailData: JSON data for detail.
    //   - onClose: Closure to execute on close.
    func showDetail(detailData: [String: Any], onClose: @escaping () -> Void) {
        if let detailView = detailView {
            detailView.removeFromSuperview()
        }
        previewView?.isHidden = true
        
        if let template = detailData["template"] as? [[String: Any]] {
            detailView = ActivationDetail(template: template, onClose: onClose)
            addSubview(detailView!)
        }
    }
    
    // Hides the detail view and restores preview.
    func hideDetail() {
        detailView?.removeFromSuperview()
        detailView = nil
        previewView?.isHidden = false
    }
    
    // Handle orientation changes to maintain proper sizing
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Update preview size if orientation changes
        if let previewView = previewView, !previewView.isHidden {
            let screenWidth = UIScreen.main.bounds.width > UIScreen.main.bounds.height ?
                              UIScreen.main.bounds.width : UIScreen.main.bounds.height
            let screenHeight = UIScreen.main.bounds.width > UIScreen.main.bounds.height ?
                               UIScreen.main.bounds.height : UIScreen.main.bounds.width
            
            let previewWidth = screenWidth * 0.4
            let previewHeight = screenHeight * 0.2
            
            // Find and update the constraints
            for constraint in previewView.constraints {
                if constraint.firstAttribute == .width {
                    constraint.constant = previewWidth
                } else if constraint.firstAttribute == .height {
                    constraint.constant = previewHeight
                }
            }
        }
    }
}
