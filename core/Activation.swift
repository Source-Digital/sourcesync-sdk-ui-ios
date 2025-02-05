//
//  Activation.swift
//  sourcesync-sdk-ui-ios
//
import UIKit

// A view representing an activation component with preview and detail views.
class Activation: UIView {
    
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
        previewView = ActivationPreview(data: previewData)
        previewView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(previewTapped)))
        addSubview(previewView!)
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
}
