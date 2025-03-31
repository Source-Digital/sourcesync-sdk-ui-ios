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
    
    // Shows the preview view with given data.
    
    // - Parameters:
    //   - previewData: JSON data for preview.
    //   - onClick: Closure to execute on click.
    public func showPreview(previewData: [String: Any], onClick: @escaping () -> Void) {
        if let previewView = previewView {
            previewView.removeFromSuperview()
        }

        self.onPreviewClickHandler = onClick
        // Create the preview view
        previewView = ActivationPreview(data: previewData)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(previewTapped))
        previewView?.addGestureRecognizer(tapGesture)
        previewView?.isUserInteractionEnabled = true
                
        if let previewView = previewView {
            addSubview(previewView)
        }
    }
    
    @objc private func previewTapped() {
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
        previewView?.isHidden = true
        
        if let template = detailData["template"] as? [[String: Any]] {
            detailView = ActivationDetail(template: template, onClose: onClose)
            // Guard against nil before adding as subview
            if let detailView = detailView {
                addSubview(detailView)
            }
        }
    }
    
    // Hides the detail view and restores preview.
    public func hideDetail() {
        detailView?.removeFromSuperview()
        detailView = nil
        previewView?.isHidden = false
    }
}
