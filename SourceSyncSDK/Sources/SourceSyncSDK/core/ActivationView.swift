//
//  ActivationView.swift
//  sourcesync-sdk-ui-ios
//

// iOS-specific code
import UIKit
import DivKit

public class ActivationView: UIView {
    
    private static let TAG = "SDK:ActivationView"
    
    private var onDetailsCloseClicked: (() -> Void)?
    private var previewView: ActivationPreview?
    private var detailView: ActivationDetails?
    private var onPreviewClickHandler: (() -> Void)?
    private var onDetailsActionTriggered: (() -> Void)?
    private var onDetailsOutsideClicked: (() -> Void)?
    
    // Screen dimensions
    private let screenWidth: CGFloat
    private let screenHeight: CGFloat
    
    // Store preview data for restoration
    private var currentPreviewData: Data?
    private var currentPreviewWidthPercentage: CGFloat = 0
    private var currentPreviewHeightPercentage: CGFloat = 0
    private let errorHandler = CustomDivReporter()

    public init(context: UIViewController) {
        // Get screen dimensions
        let screenBounds = UIScreen.main.bounds
        self.screenWidth = screenBounds.width
        self.screenHeight = screenBounds.height
        
        super.init(frame: .zero)
        
        print("\(Self.TAG): Screen dimensions: \(screenWidth)x\(screenHeight)")
        
        // Set error delegate
        self.errorHandler.errorDelegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Override hitTest to detect outside clicks
    public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hitView = super.hitTest(point, with: event)
        
        // If detail view is showing and touch is outside of it
        if let detailView = detailView {
            // Check if the touch point is within the detail view
            let pointInDetail = convert(point, to: detailView)
            if !detailView.bounds.contains(pointInDetail) {
                // Touch is outside detail view
                print("\(Self.TAG): Touch detected outside detail view")
                
                // Don't trigger for video control area
                if !isVideoControlArea(location: point) {
                    DispatchQueue.main.async { [weak self] in
                        self?.onDetailsOutsideClicked?()
                        self?.hideDetails()
                    }
                }
                return nil // Consume the touch
            }
        }
        
        return hitView
    }
    
    private func isVideoControlArea(location: CGPoint) -> Bool {
        // Define video control areas (bottom area typically)
        let controlHeight: CGFloat = 10 // points
        
        // Get the parent view bounds
        if let parentView = superview {
            let pointInParent = convert(location, to: parentView)
            let bottomControlArea = parentView.bounds.height - controlHeight
            return pointInParent.y > bottomControlArea
        }
        
        return false
    }
    
    /**
     * Shows the preview view with given data
     */
    public func showPreview(
        previewData: Data,
        widthPercentage: CGFloat = 0.0,
        heightPercentage: CGFloat = 0.0,
        onClick: @escaping () -> Void
    ) {
        // Clean up existing preview
        if let existingPreview = previewView {
            existingPreview.safeCleanup()
            existingPreview.removeFromSuperview()
        }
        
        self.onPreviewClickHandler = onClick
        self.currentPreviewData = previewData
        self.currentPreviewWidthPercentage = widthPercentage
        self.currentPreviewHeightPercentage = heightPercentage
        
        previewView = ActivationPreview(previewData: previewData)
        
        if let previewView = previewView {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(previewTapped))
            previewView.addGestureRecognizer(tapGesture)
            previewView.isUserInteractionEnabled = true
            
            addSubviewWithPercentageLayout(
                view: previewView,
                widthPercentage: widthPercentage,
                heightPercentage: heightPercentage
            )
        }
    }
    
    /**
     * Convenience method for showPreview without percentage parameters
     */
    public func showPreview(previewData: Data, onClick: @escaping () -> Void) {
        showPreview(previewData: previewData, widthPercentage: 0, heightPercentage: 0, onClick: onClick)
    }
    
    /**
     * Shows the detail view with given data
     */
    public func showDetail(
        detailsData: Data,
        widthPercentage: CGFloat = 0,
        heightPercentage: CGFloat = 0,
        onActionTriggered: @escaping () -> Void,
        onOutsideClicked: @escaping () -> Void,
        onClose: (() -> Void)?
    ) {
        // Clean up existing detail
        if let existingDetail = detailView {
            existingDetail.safeCleanup()
            existingDetail.removeFromSuperview()
        }
        
        self.onDetailsCloseClicked = onClose
        self.onDetailsOutsideClicked = onOutsideClicked
        self.onDetailsActionTriggered = onActionTriggered
        
        detailView = ActivationDetails(
            detailsData: detailsData,
            widthPercentage: widthPercentage,
            onClose: { [weak self] in
                self?.onDetailsCloseClicked?()
            },
            errorHandler: self.errorHandler
        )
        
        if let detailsView = detailView {
            detailsView.translatesAutoresizingMaskIntoConstraints = false
            addSubview(detailsView)
            
            // Setup constraints
            NSLayoutConstraint.activate([
                detailsView.topAnchor.constraint(equalTo: topAnchor),
                detailsView.leadingAnchor.constraint(equalTo: leadingAnchor),
                detailsView.bottomAnchor.constraint(equalTo: bottomAnchor),
                detailsView.trailingAnchor.constraint(equalTo: trailingAnchor)
            ])
        }
    }
    
    /**
     * Convenience method for showDetail without percentage parameters
     */
    public func showDetail(
        detailsData: Data,
        onActionTriggered: @escaping () -> Void,
        onOutsideClicked: @escaping () -> Void,
        onClose: (() -> Void)?
    ) {
        showDetail(
            detailsData: detailsData,
            widthPercentage: 0,
            heightPercentage: 0,
            onActionTriggered: onActionTriggered,
            onOutsideClicked: onOutsideClicked,
            onClose: onClose
        )
    }
    
    /**
     * Hides the detail view and restores preview
     */
    public func hideDetails() {
        cleanupDetails()
        previewView?.isHidden = false
    }
    
    // Clean up detail view
    private func cleanupDetails() {
        if let detail = detailView {
            detail.safeCleanup()
            detail.removeFromSuperview()
        }
        detailView = nil
    }
    
    // Clean up preview view
    private func cleanupPreview() {
        if let preview = previewView {
            preview.safeCleanup()
            preview.removeFromSuperview()
        }
        previewView = nil
    }
    
    /**
     * Safely cleanup all views
     */
    private func safeCleanupAll() {
        // Clean up detail view
        cleanupDetails()
        
        // Clean up preview view
        cleanupPreview()
        
        // Clear handlers
        onDetailsCloseClicked = nil
        onPreviewClickHandler = nil
        onDetailsOutsideClicked = nil
        onDetailsActionTriggered = nil
    }
    
    @objc private func previewTapped() {
        previewView?.isHidden = true
        onPreviewClickHandler?()
    }
    
    private func addSubviewWithPercentageLayout(view: UIView, widthPercentage: CGFloat, heightPercentage: CGFloat) {
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        
        // Calculate dimensions
        let width = widthPercentage > 0 ? screenWidth * widthPercentage : screenWidth
        let height = heightPercentage > 0 ? screenHeight * heightPercentage : screenHeight
        
        if widthPercentage > 0 || heightPercentage > 0 {
            // Use specific dimensions
            NSLayoutConstraint.activate([
                view.centerXAnchor.constraint(equalTo: centerXAnchor),
                view.centerYAnchor.constraint(equalTo: centerYAnchor),
                view.widthAnchor.constraint(equalToConstant: width),
                view.heightAnchor.constraint(equalToConstant: height)
            ])
        } else {
            // Fill parent
            NSLayoutConstraint.activate([
                view.topAnchor.constraint(equalTo: topAnchor),
                view.leadingAnchor.constraint(equalTo: leadingAnchor),
                view.trailingAnchor.constraint(equalTo: trailingAnchor),
                view.bottomAnchor.constraint(equalTo: bottomAnchor)
            ])
        }
    }
    override public func removeFromSuperview() {
        // Clean up parent gesture recognizer
        if let parentView = superview {
            parentView.gestureRecognizers?.forEach { gesture in
                if gesture.delegate === self {
                    parentView.removeGestureRecognizer(gesture)
                }
            }
        }
        
        safeCleanupAll()
        super.removeFromSuperview()
    }
}

// MARK: - UIGestureRecognizerDelegate
extension ActivationView: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        // Allow gesture to be received for outside detection
        return true
    }
}

extension ActivationView: DivKitErrorDelegate {
    func handleDivKitError(_ error: any DivKit.DivError, cardId: DivKit.DivCardID) {
        
        DispatchQueue.main.async { [weak self] in
            self?.removeDebugBlockViews()
        }
    }
    
    private func removeDebugBlockViews() {
        for subview in self.subviews {
            let viewType = String(describing: type(of: subview))
            
            // Check if it's a DebugBlockView
            if viewType.contains("DebugBlockView") ||
               viewType.contains("DivKit.DebugBlockView") {
                subview.removeFromSuperview()
                continue
            }
            
            // Also check recursively in case it's nested
            removeDebugBlockViewsRecursively(from: subview)
        }
    }
    
    private func removeDebugBlockViewsRecursively(from view: UIView) {
        for subview in view.subviews {
            let viewType = String(describing: type(of: subview))
            
            if viewType.contains("DebugBlockView") {
                subview.removeFromSuperview()
            } else {
                // Continue searching in subviews
                removeDebugBlockViewsRecursively(from: subview)
            }
        }
    }
}

// MARK: - Helper extensions for cleanup
extension ActivationPreview {
    func safeCleanup() {
        // Add any cleanup logic specific to ActivationPreview
        removeFromSuperview()
    }
}

extension ActivationDetails {
    func safeCleanup() {
        // Add any cleanup logic specific to ActivationDetails
        removeFromSuperview()
    }
}
