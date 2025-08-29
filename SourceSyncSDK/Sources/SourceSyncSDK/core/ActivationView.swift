//
//  ActivationView.swift
//  sourcesync-sdk-ui-ios
//

#if os(iOS)
    // iOS-specific code
    import UIKit
#elseif os(tvOS)
    // tvOS-specific code
    import TVUIKit
#endif

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
    
    public init(context: UIViewController) {
        // Get screen dimensions
        let screenBounds = UIScreen.main.bounds
        self.screenWidth = screenBounds.width
        self.screenHeight = screenBounds.height
        
        super.init(frame: .zero)
        
        print("\(Self.TAG): Screen dimensions: \(screenWidth)x\(screenHeight)")
        setupOutsideClickOverlay()
    }
    
    required init?(coder: NSCoder) {
        // Get screen dimensions
        let screenBounds = UIScreen.main.bounds
        self.screenWidth = screenBounds.width
        self.screenHeight = screenBounds.height
        
        super.init(coder: coder)
        setupOutsideClickOverlay()
    }
    
    private func setupOutsideClickOverlay() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self,
                  let parentView = self.superview else { return }
            
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.parentTapped(_:)))
            tapGesture.cancelsTouchesInView = false
            tapGesture.delegate = self
            parentView.addGestureRecognizer(tapGesture)
        }
    }
    
    @objc private func parentTapped(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: gesture.view)
        
        // Check if touch is outside our bounds
        if !frame.contains(location) {
            // Check if this touch would hit video controls (bottom area)
            if !isVideoControlArea(location: location, in: gesture.view!) {
                print("\(Self.TAG): Valid outside click detected")
                if detailView != nil {
                    onDetailsOutsideClicked?()
                    hideDetails()
                }
            }
        }
    }
    
    private func isVideoControlArea(location: CGPoint, in parentView: UIView) -> Bool {
        // Define video control areas (bottom area typically)
        let controlHeight: CGFloat = 100 // points
        let bottomControlArea = parentView.bounds.height - controlHeight
        
        // If touch is in control area, let it pass through
        return location.y > bottomControlArea
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
        widthPercentage: CGFloat = 1.0,
        heightPercentage: CGFloat = 1.0,
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
            }
        )
        
        if let detailView = detailView {
            addSubviewWithPercentageLayout(
                view: detailView,
                widthPercentage: widthPercentage,
                heightPercentage: heightPercentage
            )
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
