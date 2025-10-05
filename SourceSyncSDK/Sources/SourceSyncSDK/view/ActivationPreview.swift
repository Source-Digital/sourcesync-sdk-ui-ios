//
//  ActivationPreview.swift
//  
//
//  Created by ayman badawy on 25/09/2025.
//
import UIKit
import DivKit
import DivKitExtensions

/**
 * Standalone preview component for activations
 */
public class ActivationPreview: UIView {
    
    private static let TAG = "ActivationPreview"
    
    private var divView: DivView?
    private var config: ActivationConfig?
    private var layoutConstraints: [NSLayoutConstraint] = []
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    // MARK: - Factory Methods
    
    /**
     * Factory method to create preview from JSON
     */
    public static func createFromJson(
        context: UIViewController,
        previewJson: [String: Any],
        config: ActivationConfig?
    ) -> ActivationPreview {
        let preview = ActivationPreview()
        preview.setConfig(config)
        preview.setDataFromJson(previewJson)
        return preview
    }
    
    /**
     * Factory method to create preview with Data
     */
    public static func createFromData(
        context: UIViewController,
        previewData: Data,
        config: ActivationConfig?
    ) -> ActivationPreview {
        let preview = ActivationPreview()
        preview.setConfig(config)
        preview.setData(previewData)
        return preview
    }
        
    public func setConfig(_ config: ActivationConfig?) {
        self.config = config
    }
    
    public func setData(_ previewData: Data) {
        guard let config = config else {
            fatalError("Config must be set before data")
        }
        initializeView(previewData: previewData, config: config)
    }
    
    public func setDataFromJson(_ jsonObject: [String: Any]) {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: jsonObject, options: [])
            setData(jsonData)
        } catch {
            print("\(ActivationPreview.TAG): Error parsing JSON data: \(error)")
        }
    }
        
    private func initializeView(previewData: Data, config: ActivationConfig) {
        cleanup()
        
        // Add tap gesture for preview click
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(previewTapped))
        addGestureRecognizer(tapGesture)
        isUserInteractionEnabled = true
        
        // Create DivView
        divView = DivView(divKitComponents: config.divKitComponents)
        
        guard let divView = divView else { return }
        
        addSubview(divView)
        divView.translatesAutoresizingMaskIntoConstraints = false
        
        // Setup constraints
        layoutConstraints = [
            divView.topAnchor.constraint(equalTo: topAnchor),
            divView.leadingAnchor.constraint(equalTo: leadingAnchor),
            divView.bottomAnchor.constraint(equalTo: bottomAnchor),
            divView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ]
        NSLayoutConstraint.activate(layoutConstraints)
        
        // Set DivKit data
        Task {
            await divView.setSource(
                .init(kind: .data(previewData), cardId: "SourceSync-ActivationPreview"),
                debugParams: DebugParams(isDebugInfoEnabled: config.visualErrorsEnabled)
            )
        }
    }
    
    @objc private func previewTapped() {
        config?.onPreviewClickHandler?()
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
