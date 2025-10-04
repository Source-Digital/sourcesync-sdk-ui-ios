//
//  DemoViewController.swift
//  MobileDemo

import SourceSyncSDK
import AVFoundation
import UIKit

/**
 * DemoViewController
 *
 * A demonstration view controller that showcases the usage of the new Activation System.
 * This controller demonstrates how to use ActivationPreview, ActivationDetails, and ActivationConfig
 * with proper configuration and lifecycle management.
 */
class DemoViewController: UIViewController {
    
    private var activation2Preview: Activation2Preview?
    private var activation2Details: Activation2Details?
    private var activationConfig: ActivationConfig?
    
    private let TAG = "DemoViewController"
    
    // Store data for reuse
    private var previewData: Data?
    private var detailsData: Data?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupActivationSystem()
    }
    
    private func setupActivationSystem() {
        // Load template data from files
        guard let previewUrl = Bundle.main.url(forResource: "div_preview", withExtension: "json") else {
            print("\(TAG): Failed to load preview resource 'div_preview.json'")
            return
        }
        
        guard let detailsUrl = Bundle.main.url(forResource: "div_details", withExtension: "json") else {
            print("\(TAG): Failed to load details resource 'div_details.json'")
            return
        }
        
        do {
            previewData = try Data(contentsOf: previewUrl)
            detailsData = try Data(contentsOf: detailsUrl)
        } catch {
            print("\(TAG): Failed to load data from file - \(error.localizedDescription)")
            return
        }
        
        // Create activation configuration using builder pattern
        activationConfig = ActivationConfig.Builder(context: self)
            .setPreviewClickHandler { [weak self] in
                self?.handlePreviewClick()
            }
            .setOutsideClickHandler { [weak self] in
                self?.handleOutsideClick()
            }
            .setDetailsCloseHandler { [weak self] in
                self?.handleDetailsClose()
            }
            .setUrlActionHandler { [weak self] in
                self?.handleUrlAction()
            }
            .setPositionAlignment(.topTrailing)
            .setVisualErrorsEnabled(false) // Set to true for debugging
            .build()
        
        // Show initial preview
        showActivationPreview()
    }
    
    
    private func showActivationPreview() {
        guard let previewData = previewData,
              let config = activationConfig else { return }
        
        // Clean up any existing views
        cleanupActivationViews()
        
        // Create preview using factory method
        activation2Preview = Activation2Preview.createFromData(
            context: self,
            previewData: previewData,
            config: config
        )
        
        guard let preview = activation2Preview else { return }
        
        // Add to view hierarchy
        view.addSubview(preview)
        preview.translatesAutoresizingMaskIntoConstraints = false
        
        // Position in top-right corner with intrinsic sizing
        NSLayoutConstraint.activate([
            preview.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            preview.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            // Let the preview size itself based on content
            preview.widthAnchor.constraint(lessThanOrEqualToConstant: 200),
            preview.heightAnchor.constraint(lessThanOrEqualToConstant: 150)
        ])
        
        print("\(TAG): Activation preview shown")
    }
    
    private func showActivationDetails() {
        guard let detailsData = detailsData,
              let config = activationConfig else { return }
        
        // Clean up existing preview
        cleanupActivationViews()
        
        // Create details using factory method
        activation2Details = Activation2Details.createFromData(
            context: self,
            detailsData: detailsData,
            config: config
        )
        
        guard let details = activation2Details else { return }
        
        // Add to view hierarchy
        view.addSubview(details)
        details.translatesAutoresizingMaskIntoConstraints = false
        
        // Position details view (50% width on right side, full height)
        NSLayoutConstraint.activate([
            details.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            details.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            details.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            details.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5)
        ])
        
        print("\(TAG): Activation details shown")
    }
    
    private func cleanupActivationViews() {
        // Clean up preview
        activation2Preview?.cleanup()
        activation2Preview?.removeFromSuperview()
        activation2Preview = nil
        
        // Clean up details
        activation2Details?.cleanup()
        activation2Details?.removeFromSuperview()
        activation2Details = nil
    }
    
    private func handlePreviewClick() {
        print("\(TAG): Preview clicked - showing details")
        showActivationDetails()
    }
    
    private func handleOutsideClick() {
        print("\(TAG): Outside click detected - hiding details")
        hideActivationDetails()
    }
    
    private func handleDetailsClose() {
        print("\(TAG): Details close button clicked")
        hideActivationDetails()
    }
    
    private func handleUrlAction() {
        print("\(TAG): URL action triggered")
        // Handle any URL-based actions from the DivKit templates
        // This could include opening external links, triggering app actions, etc.
    }
    
    private func hideActivationDetails() {
        // Remove details and restore preview
        activation2Details?.cleanup()
        activation2Details?.removeFromSuperview()
        activation2Details = nil
        
        // Show preview again
        showActivationPreview()
    }
    
    deinit {
        print("\(TAG): DemoViewController deallocating")
        cleanupActivationViews()
    }
}
