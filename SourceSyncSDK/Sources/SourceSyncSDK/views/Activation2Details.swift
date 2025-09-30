//
//  Activation2Details.swift
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
public class Activation2Details: UIView {
    
    private static let TAG = "Activation2Details"
    
    private var divView: DivView?
    private var config: ActivationConfig?
    private var layoutConstraints: [NSLayoutConstraint] = []
    private var touchOutsideView: UIView?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupOutsideClickOverlay()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupOutsideClickOverlay()
    }
    
    // MARK: - Factory Methods
    
    /**
     * Factory method to create details from JSON
     */
    public static func createFromJson(
        context: UIViewController,
        detailsJson: [String: Any],
        config: ActivationConfig
    ) -> Activation2Details {
        let details = Activation2Details()
        details.setConfig(config)
        details.setDataFromJson(detailsJson)
        return details
    }
    
    /**
     * Factory method to create details with Data
     */
    public static func createFromData(
        context: UIViewController,
        detailsData: Data,
        config: ActivationConfig
    ) -> Activation2Details {
        let details = Activation2Details()
        details.setConfig(config)
        details.setData(detailsData)
        return details
    }
    
    // MARK: - Configuration
    
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
            print("\(Activation2Details.TAG): Error parsing JSON data: \(error)")
        }
    }
    
    // MARK: - Private Methods
    
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
                .init(kind: .data(detailsData), cardId: "SourceSync-Activation2Details"),
                debugParams: DebugParams(isDebugInfoEnabled: config.visualErrorsEnabled)
            )
        }
    }
    
    private func setupConstraintsForPosition(divView: DivView, config: ActivationConfig) -> [NSLayoutConstraint] {
        switch config.activationPosition.alignment {
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
    
    private func setupOutsideClickOverlay() {
        // This will be called when the view is added to a parent
        DispatchQueue.main.async { [weak self] in
            self?.addOutsideClickDetection()
        }
    }
    
    private func addOutsideClickDetection() {
        guard let parentView = superview else { return }
        
        touchOutsideView = UIView(frame: parentView.bounds)
        touchOutsideView?.backgroundColor = UIColor.clear
        touchOutsideView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleOutsideTap(_:)))
        touchOutsideView?.addGestureRecognizer(tapGesture)
        
        parentView.insertSubview(touchOutsideView!, belowSubview: self)
    }
    
    @objc private func handleOutsideTap(_ gesture: UITapGestureRecognizer) {
        let touchPoint = gesture.location(in: self)
        
        // Check if touch is outside our bounds
        if !bounds.contains(touchPoint) {
            // Check if this touch would interfere with video controls
            if !isVideoControlArea(point: touchPoint) {
                config?.onOutsideClickHandler?()
            }
        }
    }
    
    private func isVideoControlArea(point: CGPoint) -> Bool {
        // Define video control areas (bottom area typically)
        let controlHeight: CGFloat = 100
        let parentHeight = superview?.bounds.height ?? bounds.height
        let bottomControlArea = parentHeight - controlHeight
        
        // If touch is in control area, let it pass through
        return point.y > bottomControlArea
    }
    
    public func cleanup() {
        NSLayoutConstraint.deactivate(layoutConstraints)
        layoutConstraints.removeAll()
        
        divView?.removeFromSuperview()
        divView = nil
        
        touchOutsideView?.removeFromSuperview()
        touchOutsideView = nil
        
        gestureRecognizers?.forEach { removeGestureRecognizer($0) }
    }
    
    deinit {
        cleanup()
    }
}
