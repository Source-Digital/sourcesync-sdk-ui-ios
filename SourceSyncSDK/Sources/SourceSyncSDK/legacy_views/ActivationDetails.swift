//
//  ActivationDetails.swift
//
//
//  Created by ayman badawy on 25/09/2025.
//
import UIKit
import DivKit
import DivKitExtensions

/**
 * Standalone details component for activations
 */
public class ActivationDetails: UIView {
    
    private static let TAG = "ActivationDetails"
    
    private var divView: DivView?
    private var config: ActivationConfig?
    private var layoutConstraints: [NSLayoutConstraint] = []
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    /**
     * Factory method to create details from JSON
     */
    public static func createFromJson(
        detailsJson: [String: Any],
        config: ActivationConfig
    ) -> ActivationDetails {
        let details = ActivationDetails()
        details.setConfig(config)
        details.setDataFromJson(detailsJson)
        return details
    }
    
    /**
     * Factory method to create details with Data
     */
    public static func createFromData(
        detailsData: Data,
        config: ActivationConfig
    ) -> ActivationDetails {
        let details = ActivationDetails()
        details.setConfig(config)
        details.setData(detailsData)
        return details
    }

    
    public func setConfig(_ config: ActivationConfig) {
        self.config = config
    }
    
    public func setData(_ detailsData: Data) {
        guard let config = config else {
            fatalError("Config must be set before data")
        }
        initializeView(detailsData: detailsData, config: config)
    }
    
    public func setDataFromJson(_ jsonObject: [String: Any]) {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: jsonObject, options: [])
            setData(jsonData)
        } catch {
            print("\(ActivationDetails.TAG): Error parsing JSON data: \(error)")
        }
    }
    
    
    private func initializeView(detailsData: Data, config: ActivationConfig) {
        cleanup()
        
        // Create DivView
        divView = DivView(divKitComponents: config.divKitComponents)
        
        guard let divView = divView else { return }
        
        addSubview(divView)
        divView.translatesAutoresizingMaskIntoConstraints = false
        
        // Setup constraints based on position
        layoutConstraints = setupConstraintsForPosition(divView: divView, config: config)
        NSLayoutConstraint.activate(layoutConstraints)
        
        // Set DivKit data
        Task {
            await divView.setSource(
                .init(kind: .data(detailsData), cardId: "SourceSync-ActivationDetails"),
                debugParams: DebugParams(isDebugInfoEnabled: config.visualErrorsEnabled)
            )
        }
    }
    
    private func setupConstraintsForPosition(divView: DivView, config: ActivationConfig) -> [NSLayoutConstraint] {
        switch config.activationPosition?.alignment {
        case .topTrailing:
            return [
                divView.topAnchor.constraint(equalTo: topAnchor),
                divView.trailingAnchor.constraint(equalTo: trailingAnchor),
                divView.bottomAnchor.constraint(equalTo: bottomAnchor),
                divView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.5)
            ]
        case .topLeading:
            return [
                divView.topAnchor.constraint(equalTo: topAnchor),
                divView.leadingAnchor.constraint(equalTo: leadingAnchor),
                divView.bottomAnchor.constraint(equalTo: bottomAnchor),
                divView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.5)
            ]
        case .center:
            return [
                divView.centerXAnchor.constraint(equalTo: centerXAnchor),
                divView.centerYAnchor.constraint(equalTo: centerYAnchor),
                divView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.8),
                divView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.8)
            ]
        default:
            return [
                divView.topAnchor.constraint(equalTo: topAnchor),
                divView.leadingAnchor.constraint(equalTo: leadingAnchor),
                divView.bottomAnchor.constraint(equalTo: bottomAnchor),
                divView.trailingAnchor.constraint(equalTo: trailingAnchor)
            ]
        }
    }
    
    // Override hitTest to detect outside clicks
    public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hitView = super.hitTest(point, with: event)
            
        if let divView = self.divView{
            // Check if the touch point is within the view
            let pointInDetail = convert(point, to: divView)
            if !divView.bounds.contains(pointInDetail) {
                // Touch is outside detail view
                print("\(Self.TAG): Touch detected outside detail view")
                
                // Don't trigger for video control area
                if !isVideoControlArea(location: point) {
                    DispatchQueue.main.async { [weak self] in
                        self?.config?.onOutsideClickHandler?()
                    }
                }
                return nil // Consume the touch
            }
        }

        return hitView
    }
    
    private func isVideoControlArea(location: CGPoint) -> Bool {
        // Define video control areas (bottom area typically)
        let controlHeight: CGFloat = 100 // points
        
        // Get the parent view bounds
        if let parentView = superview {
            let pointInParent = convert(location, to: parentView)
            let bottomControlArea = parentView.bounds.height - controlHeight
            return pointInParent.y > bottomControlArea
        }
        
        return false
    }
    
    public func cleanup() {
        NSLayoutConstraint.deactivate(layoutConstraints)
        layoutConstraints.removeAll()
        
        divView?.removeFromSuperview()
        divView = nil
        
        gestureRecognizers?.forEach { removeGestureRecognizer($0) }
    }
    
    deinit {
        cleanup()
    }
}
