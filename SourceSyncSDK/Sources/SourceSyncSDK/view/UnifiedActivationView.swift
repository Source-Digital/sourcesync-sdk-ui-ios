//
//  UnifiedActivationView.swift
//
//
//  Created by ayman badawy on 10/11/2025.
//

import UIKit
import DivKit
import DivKitExtensions

/**
 * Unified activation view that can display both preview and detail modes
 * Replaces separate ActivationPreview and ActivationDetails components
 */
public class UnifiedActivationView: UIView {
    
    private static let TAG = "UnifiedActivationView"
    
    private var divView: DivView?
    private var config: ActivationConfig?
    private var layoutConstraints: [NSLayoutConstraint] = []
    
    // Video control area configuration
    private let videoControlHeightPoints: CGFloat = 100
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    /**
     * Creates UnifiedActivationView from DivData with configuration
     * @param divData DivData for rendering
     * @param config ActivationConfig with handlers and positioning
     * @return Configured UnifiedActivationView instance
     */
    public static func createFromDivData(
        divData: Data,
        config: ActivationConfig
    ) -> UnifiedActivationView {
        let UnifiedActivationView = UnifiedActivationView()
        UnifiedActivationView.setConfig(config)
        UnifiedActivationView.setViewData(divData)
        return UnifiedActivationView
    }
    
    /**
     * Creates UnifiedActivationView from JSON with configuration
     * @param json Dictionary containing view data
     * @param config ActivationConfig with handlers and positioning
     * @return Configured UnifiedActivationView instance
     */
    public static func createFromJson(
        json: [String: Any],
        config: ActivationConfig
    ) -> UnifiedActivationView {
        let unifiedActivationView = UnifiedActivationView()
        unifiedActivationView.setConfig(config)
        unifiedActivationView.setViewDataFromJson(json)
        return unifiedActivationView
    }
    
    /**
     * Sets configuration for activation view behavior and appearance
     * @param config ActivationConfig containing handlers and positioning
     */
    public func setConfig(_ config: ActivationConfig) {
        self.config = config
    }
    
    /**
     * Displays the view with Data
     * @param viewData Data to render
     */
    public func setViewData(_ viewData: Data) {
        guard let config = config else {
            assertionFailure("Config must be set before data")
            return
        }
        initializeView(viewData: viewData, config: config)
    }
    
    /**
     * Displays the view with JSON data
     * @param jsonObject Dictionary containing activation data
     */
    public func setViewDataFromJson(_ jsonObject: [String: Any]) {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: jsonObject, options: [])
            setViewData(jsonData)
        } catch {
            print("\(Self.TAG): Error parsing JSON data: \(error)")
        }
    }
    
    /**
     * Initializes view components with data and configuration
     * @param viewData Data for rendering
     * @param config View configuration settings
     */
    private func initializeView(viewData: Data, config: ActivationConfig) {
        cleanup()
        
        setupDivView(viewData: viewData, config: config)
        setupClickHandlers(config: config)
        setupLayoutConstraints(config: config)
    }
    
    /**
     * Creates and configures DivView with data
     * @param viewData Data to set on the view
     * @param config Configuration containing div settings
     */
    private func setupDivView(viewData: Data, config: ActivationConfig) {
        // Create DivView
        divView = DivView(divKitComponents: config.divKitComponents)
    
        guard let divView = divView else { return }
        
        addSubview(divView)
        divView.translatesAutoresizingMaskIntoConstraints = false
        
        // Set DivKit data asynchronously
        Task { @MainActor in
            await divView.setSource(
                .init(kind: .data(viewData), cardId: "SourceSync-UnifiedActivationView"),
                debugParams: DebugParams(isDebugInfoEnabled: config.visualErrorsEnabled)
            )
        }
    }
    
    /**
     * Configures click handlers from config
     * @param config Configuration containing click handlers
     */
    private func setupClickHandlers(config: ActivationConfig) {
        // Add tap gesture for preview click
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        addGestureRecognizer(tapGesture)
        isUserInteractionEnabled = true
    }
    
    /**
     * Sets up layout constraints based on configuration
     * @param config Configuration containing position settings
     */
    private func setupLayoutConstraints(config: ActivationConfig) {
        guard let divView = divView else { return }
        
        layoutConstraints = createConstraintsForPosition(divView: divView, config: config)
        NSLayoutConstraint.activate(layoutConstraints)
    }
    
    /**
     * Creates layout constraints based on activation position
     * @param divView DivView to constrain
     * @param config Configuration with positioning info
     * @return Array of layout constraints
     */
    private func createConstraintsForPosition(divView: DivView, config: ActivationConfig) -> [NSLayoutConstraint] {
        guard let alignment = config.activationPosition?.alignment else {
            // Default full-screen constraints
            return [
                divView.topAnchor.constraint(equalTo: topAnchor),
                divView.leadingAnchor.constraint(equalTo: leadingAnchor),
                divView.bottomAnchor.constraint(equalTo: bottomAnchor),
                divView.trailingAnchor.constraint(equalTo: trailingAnchor)
            ]
        }
        
        switch alignment {
        case .topTrailing:
            return [
                divView.topAnchor.constraint(equalTo: topAnchor),
                divView.trailingAnchor.constraint(equalTo: trailingAnchor),
                divView.bottomAnchor.constraint(equalTo: bottomAnchor),
                divView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.9)
            ]
        case .topLeading:
            return [
                divView.topAnchor.constraint(equalTo: topAnchor),
                divView.leadingAnchor.constraint(equalTo: leadingAnchor),
                divView.bottomAnchor.constraint(equalTo: bottomAnchor),
                divView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.5)
            ]
        case .bottomTrailing:
            return [
                divView.bottomAnchor.constraint(equalTo: bottomAnchor),
                divView.trailingAnchor.constraint(equalTo: trailingAnchor),
                divView.topAnchor.constraint(equalTo: topAnchor),
                divView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.5)
            ]
        case .bottomLeading:
            return [
                divView.bottomAnchor.constraint(equalTo: bottomAnchor),
                divView.leadingAnchor.constraint(equalTo: leadingAnchor),
                divView.topAnchor.constraint(equalTo: topAnchor),
                divView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.5)
            ]
        case .center:
            return [
                divView.centerXAnchor.constraint(equalTo: centerXAnchor),
                divView.centerYAnchor.constraint(equalTo: centerYAnchor),
                divView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.8),
                divView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.8)
            ]
        }
    }
    
    /**
     * Handles tap gestures on the view
     */
    @objc private func viewTapped() {
        config?.onPreviewClickHandler?()
    }
    
    /**
     * Override hitTest to detect outside clicks when enabled
     * Preserves video control functionality by ignoring touches in control areas
     */
    public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hitView = super.hitTest(point, with: event)
        
        guard let divView = divView else {
            return hitView
        }
        
        // Check if the touch point is within the divView
        let pointInDivView = convert(point, to: divView)
        if !divView.bounds.contains(pointInDivView) {
            print("\(Self.TAG): Touch detected outside activation view")
            
            // Don't trigger for video control area
            if !isVideoControlArea(location: point) {
                DispatchQueue.main.async { [weak self] in
                    self?.config?.onOutsideClickHandler?()
                }
            }
            return nil // Consume the touch
        }
        
        return hitView
    }
    
    /**
     * Checks if touch event is within video control area
     * @param location Touch location in view coordinates
     * @return true if touch is in video control area
     */
    private func isVideoControlArea(location: CGPoint) -> Bool {
        // Get the parent view bounds
        guard let parentView = superview else { return false }
        
        let pointInParent = convert(location, to: parentView)
        let bottomControlArea = parentView.bounds.height - videoControlHeightPoints
        return pointInParent.y > bottomControlArea
    }
    
    /**
     * Hides the activation view and cleans up resources
     */
    public func hide() {
        cleanup()
    }
    
    /**
     * Cleans up resources and prevents memory leaks
     */
    public func cleanup() {
        NSLayoutConstraint.deactivate(layoutConstraints)
        layoutConstraints.removeAll()
        
        divView?.removeFromSuperview()
        divView = nil
        
        gestureRecognizers?.forEach { removeGestureRecognizer($0) }
    }
    
    deinit {
        cleanup()
        print("\(Self.TAG): UnifiedActivationView deallocated")
    }
}
