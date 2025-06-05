//
//  ActivationView.swift
//  sourcesync-sdk-ui-ios
//
import UIKit

/**
 * ActivationView
 *
 * A container view that manages the activation flow, handling both preview and detail states.
 * This view serves as the main public interface for the activation system, coordinating
 * between the preview and detail views and managing user interactions.
 *
 * The ActivationView handles the lifecycle of activation UI components, including showing
 * the initial preview, transitioning to the detailed view when the user interacts with the
 * preview, and hiding the detail view when the user dismisses it.
 */
public class ActivationView: UIView {
    
    /// Tag for logging purposes
    private static let TAG = "SDK:ActivationView"
    
    /// The view that displays the activation preview
    private var previewView: ActivationPreview?
    
    /// The view that displays the activation details
    private var detailsView: ActivationDetails?
    
    /// Handler for when the preview is clicked
    private var onPreviewClickHandler: (() -> Void)?
    
    /// Parent view controller for showing alerts or handling navigation
    private weak var parentViewController: UIViewController?
    
    /**
     * Creates an ActivationView with a reference to the parent view controller.
     *
     * @param context The UIViewController that will be used for handling actions such as
     *                showing alerts or navigation. This is weakly referenced to avoid
     *                reference cycles.
     */
    public init(context: UIViewController) {
        self.parentViewController = context
        super.init(frame: .zero)
    }
    
    /**
     * Required initializer for NSCoding, implemented to support Interface Builder.
     */
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    /**
     * Shows the preview view with the given JSON data.
     *
     * @param previewData JSON data containing the DivKit template for the preview.
     * @param onClick Closure to execute when the preview is tapped.
     *
     * This method removes any existing preview or detail views before creating and displaying
     * the new preview. It also attaches a tap gesture recognizer to the preview to handle user
     * interaction.
     */
    public func showPreview(
        previewData: Data,
        onClick: @escaping () -> Void
    ) {
        // Remove previous preview view and detail view if they exist
        previewView?.removeFromSuperview()
        detailsView?.removeFromSuperview()
        detailsView = nil
        
        self.onPreviewClickHandler = onClick
        
        previewView = ActivationPreview(previewData: previewData)
        
        if let previewView = previewView {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(previewTapped))
            previewView.addGestureRecognizer(tapGesture)
            previewView.isUserInteractionEnabled = true
            
            previewView.translatesAutoresizingMaskIntoConstraints = false
            addSubview(previewView)
            
            // Setup constraints
            NSLayoutConstraint.activate([
                previewView.topAnchor.constraint(equalTo: topAnchor),
                previewView.bottomAnchor.constraint(equalTo: bottomAnchor),
                previewView.leadingAnchor.constraint(equalTo: leadingAnchor),
                previewView.trailingAnchor.constraint(equalTo: trailingAnchor)
            ])
        }
    }
    
    /**
     * Shows the detail view with the given JSON data.
     *
     * @param detailsData JSON data containing the DivKit template for the details.
     * @param onClose Closure to execute when the detail view is closed.
     *
     * This method hides the preview view (rather than removing it) and displays the detail view.
     * It creates a new ActivationDetails view with the provided JSON data and adds it to the view
     * hierarchy with appropriate constraints.
     */
    public func showDetail(detailsData: Data, onClose: @escaping ()->Void) {
        // Hide the preview instead of removing it
        previewView?.isHidden = true
        
        // Remove any existing detail view
        detailsView?.removeFromSuperview()
        
        // Create and configure the detail view
        detailsView = ActivationDetails(detailsData: detailsData, parentViewController: parentViewController, onClose: onClose)
        
        if let detailsView = detailsView {
            detailsView.translatesAutoresizingMaskIntoConstraints = false
            addSubview(detailsView)
            
            // Setup constraints
            NSLayoutConstraint.activate([
                detailsView.topAnchor.constraint(equalTo: topAnchor),
                detailsView.bottomAnchor.constraint(equalTo: bottomAnchor),
                detailsView.leadingAnchor.constraint(equalTo: leadingAnchor),
                detailsView.trailingAnchor.constraint(equalTo: trailingAnchor)
            ])
        }
    }
    
    /**
     * Hides the detail view and restores the preview view.
     *
     * This method removes the detail view from the view hierarchy and shows the preview view
     * again. It's typically called when the user dismisses the detail view.
     */
    public func hideDetail() {
        if let detailsView = detailsView {
            detailsView.removeFromSuperview()
            self.detailsView = nil
        }
        
        // Show the preview again
        previewView?.isHidden = true
    }
    
    /**
     * Handles tap events on the preview view.
     *
     * This method is called when the user taps on the preview view. It executes the
     * onPreviewClickHandler closure if one has been set.
     */
    @objc private func previewTapped() {
        if let handler = onPreviewClickHandler {
            handler()
        }
    }
}
