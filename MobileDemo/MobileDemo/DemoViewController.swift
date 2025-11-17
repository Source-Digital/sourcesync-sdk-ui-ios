import SourceSyncSDK
import AVFoundation
import UIKit

/**
 * DemoViewController
 *
 * A demonstration view controller that showcases the usage of the new Activation System.
 * This controller demonstrates how to use ActivationPreview, ActivationDetails, and ActivationConfig
 * with proper configuration and lifecycle management.
 *
 * The controller manages a two-state activation system:
 * 1. Preview State: Shows a compact activation preview in the top-right corner
 * 2. Details State: Shows a full details view taking up 50% of the screen width
 *
 * Features demonstrated:
 * - Loading DivKit templates from JSON files
 * - Configuring activation handlers using the builder pattern
 * - Managing view lifecycle and memory cleanup
 * - Handling user interactions (clicks, outside touches, URL actions)
 * - Auto Layout integration for responsive positioning
 */
class DemoViewController: UIViewController {
        
    // The currently displayed activation preview view
    // Shown in compact form in the top-right corner of the screen
    private var activationPreview: UnifiedActivationView?
    
    // The currently displayed activation details view
    // Shown as a larger panel taking up 50% of the screen width
    private var activationDetails: UnifiedActivationView?
    
    // Configuration object containing all activation settings and handlers
    // Built using the builder pattern and reused for both preview and details
    private var activationConfig: ActivationConfig?
    
    // Logging tag for consistent debug output identification
    private let TAG = "DemoViewController"
        
    // Cached JSON data for the preview template
    // Loaded once from bundle and reused to avoid file I/O on each display
    private var previewData: Data?
    
    // Cached JSON data for the details template
    // Loaded once from bundle and reused to avoid file I/O on each display
    private var detailsData: Data?
        
    /**
     * Called when the view controller's view is loaded into memory
     *
     * Initiates the activation system setup process, including loading
     * template data and configuring the activation components.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        setupActivationSystem()
    }
        
    /**
     * Initialize the entire activation system
     *
     * This method handles the complete setup process:
     * 1. Loads DivKit template JSON files from the app bundle
     * 2. Creates the activation configuration with all necessary handlers
     * 3. Displays the initial preview state
     *
     * If any step fails, appropriate error logging is performed and setup is aborted.
     */
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
        
        // Cache the template data for reuse throughout the lifecycle
        do {
            previewData = try Data(contentsOf: previewUrl)
            detailsData = try Data(contentsOf: detailsUrl)
        } catch {
            print("\(TAG): Failed to load data from file - \(error.localizedDescription)")
            return
        }
        
        // Create activation configuration using builder pattern
        // This demonstrates the fluent API for setting up all interaction handlers
        activationConfig = ActivationConfig.Builder()
            .setPreviewClickHandler { [weak self] in
                // Transition from preview to details when preview is tapped
                self?.handlePreviewClick()
            }
            .setOutsideClickHandler { [weak self] in
                // Hide details when user taps outside the activation area
                self?.handleOutsideClick()
            }
            .setDetailsCloseHandler { [weak self] in
                // Handle explicit close button actions in details view
                self?.handleDetailsClose()
            }
            .setUrlActionHandler { [weak self] in
                // Handle any URL-based actions triggered from DivKit templates
                self?.handleUrlAction()
            }
            .setActivationPosition(ActivationPosition(
                screenWidth: 0,  // Will be calculated based on container
                screenHeight: 0, // Will be calculated based on container
                alignment: .topTrailing // Position in top-right corner
            ))
            .setVisualErrorsEnabled(false) // Set to true for debugging DivKit issues
            .build()
        
        // Start with the preview state
        showActivationPreview()
    }
        
    /**
     * Display the activation preview in compact form
     *
     * Creates and positions a small preview view in the top-right corner.
     * The preview uses intrinsic content sizing with maximum constraints
     * to ensure it doesn't become too large on any device.
     *
     * Automatically cleans up any existing activation views before displaying.
     */
    private func showActivationPreview() {
        guard let previewData = previewData,
              let config = activationConfig else { return }
        
        // Clean up any existing views to prevent memory leaks and visual conflicts
        cleanupActivationViews()
        
        // Create preview using factory method with cached data
        activationPreview = UnifiedActivationView.createFromDivData(divData: previewData, config: config)
        
        guard let preview = activationPreview else { return }
        
        // Add to view hierarchy and configure Auto Layout
        view.addSubview(preview)
        preview.translatesAutoresizingMaskIntoConstraints = false
        
        // Position in top-right corner with intrinsic sizing
        // Uses safe area to avoid notches and status bars
        NSLayoutConstraint.activate([
            preview.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            preview.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            // Maximum size constraints to prevent oversized previews
            preview.widthAnchor.constraint(lessThanOrEqualToConstant: 750),
            preview.heightAnchor.constraint(lessThanOrEqualToConstant: 150)
        ])
        
        print("\(TAG): Activation preview shown")
    }
    
    /**
     * Display the activation details in expanded form
     *
     * Creates and positions a larger details view that takes up 50% of the screen width
     * on the right side. The details view spans the full height of the safe area.
     *
     * Automatically cleans up the preview view before displaying details.
     */
    private func showActivationDetails() {
        guard let detailsData = detailsData,
              let config = activationConfig else { return }
        
        // Clean up existing preview to transition to details state
        cleanupActivationViews()
        
        // Create details using factory method with cached data
        activationDetails = UnifiedActivationView.createFromDivData(divData: detailsData, config: config)
        
        guard let details = activationDetails else { return }
        
        // Add to view hierarchy and configure Auto Layout
        view.addSubview(details)
        details.translatesAutoresizingMaskIntoConstraints = false
        
        // Position details view (50% width on right side, full height)
        // This creates a sidebar-style details panel
        NSLayoutConstraint.activate([
            details.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            details.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            details.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            details.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5)
        ])
        
        print("\(TAG): Activation details shown")
    }
    
    /**
     * Clean up all activation views and release resources
     *
     * Properly disposes of both preview and details views by:
     * 1. Calling cleanup() to release internal resources
     * 2. Removing from superview to clean up the view hierarchy
     * 3. Setting references to nil to release memory
     *
     * This method ensures no memory leaks occur during state transitions.
     */
    private func cleanupActivationViews() {
        // Clean up preview with proper resource disposal
        activationPreview?.cleanup()
        activationPreview?.removeFromSuperview()
        activationPreview = nil
        
        // Clean up details with proper resource disposal
        activationDetails?.cleanup()
        activationDetails?.removeFromSuperview()
        activationDetails = nil
    }
    
    /**
     * Handle preview click/tap events
     *
     * Called when the user taps on the activation preview.
     * Transitions from preview state to details state to show more information.
     */
    private func handlePreviewClick() {
        print("\(TAG): Preview clicked - showing details")
        showActivationDetails()
    }
    
    /**
     * Handle outside click/tap events
     *
     * Called when the user taps outside the activation area while details are shown.
     * This provides an intuitive way to dismiss the details and return to preview state.
     */
    private func handleOutsideClick() {
        print("\(TAG): Outside click detected - hiding details")
        hideActivationDetails()
    }
    
    /**
     * Handle details close button events
     *
     * Called when the user explicitly clicks a close button within the details view.
     * Provides a clear, explicit way to dismiss the details panel.
     */
    private func handleDetailsClose() {
        print("\(TAG): Details close button clicked")
        hideActivationDetails()
    }
    
    /**
     * Handle URL action events from DivKit templates
     *
     * Called when URL-based actions are triggered from within the DivKit templates.
     * This could include:
     * - Opening external links in Safari
     * - Triggering deep links to other parts of the app
     * - Executing custom app-specific actions
     * - Analytics tracking for user interactions
     */
    private func handleUrlAction() {
        print("\(TAG): URL action triggered")
        // TODO: Implement specific URL action handling based on requirements
        // Examples:
        // - Parse URL and execute app-specific actions
        // - Track analytics events
        // - Navigate to other view controllers
        // - Show additional UI elements
    }
    
    /**
     * Hide the details view and return to preview state
     *
     * Transitions from details state back to preview state by:
     * 1. Cleaning up the details view and its resources
     * 2. Restoring the compact preview in the top-right corner
     *
     * This method maintains the activation system's two-state lifecycle.
     */
    private func hideActivationDetails() {
        // Remove details and properly clean up resources
        activationDetails?.cleanup()
        activationDetails?.removeFromSuperview()
        activationDetails = nil
        
        // Restore the preview state
        showActivationPreview()
    }
    
    // MARK: - Memory Management
    
    /**
     * Clean up resources when the view controller is deallocated
     *
     * Ensures proper cleanup of all activation views and their associated resources
     * to prevent memory leaks. Called automatically by ARC when the view controller
     * is being deallocated.
     */
    deinit {
        print("\(TAG): DemoViewController deallocating")
        cleanupActivationViews()
    }
}
