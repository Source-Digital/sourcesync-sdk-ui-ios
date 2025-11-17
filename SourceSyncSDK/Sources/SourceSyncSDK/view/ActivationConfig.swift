//
//  Created by ayman badawy on 25/09/2025.
//

import UIKit
import DivKit
import DivKitExtensions

/**
 * Configuration builder for Unified Activation views
 *
 * This class provides a centralized configuration system for managing activation-related UI components
 * using the DivKit framework. It handles various user interaction events and positioning options
 * for activation views throughout the application.
 */
public class ActivationConfig {
    // DivKit components used for rendering the activation UI
    let divKitComponents: DivKitComponents
    
    // Handler called when the preview element is clicked/tapped
    let onPreviewClickHandler: (() -> Void)?
    
    // Handler called when user clicks outside the activation view
    let onOutsideClickHandler: (() -> Void)?
    
    // Handler called when the details view is closed
    let onDetailsCloseHandler: (() -> Void)?
    
    // Handler called when a URL action is triggered
    let onUrlActionHandler: (() -> Void)?
    
    // Positioning configuration for the activation view
    let activationPosition: ActivationPosition?
    
    // Flag to enable/disable visual error indicators in the UI
    let visualErrorsEnabled: Bool
    
    /**
     * Private initializer - use Builder pattern to create instances
     *
     * - Parameters:
     *   - divKitComponents: Pre-configured DivKit components
     *   - onPreviewClickHandler: Optional preview click handler
     *   - onOutsideClickHandler: Optional outside click handler
     *   - onDetailsCloseHandler: Optional details close handler
     *   - onUrlActionHandler: Optional URL action handler
     *   - activationPosition: Optional positioning configuration
     *   - visualErrorsEnabled: Whether to show visual error indicators
     */
    private init(
        divKitComponents: DivKitComponents,
        onPreviewClickHandler: (() -> Void)?,
        onOutsideClickHandler: (() -> Void)?,
        onDetailsCloseHandler: (() -> Void)?,
        onUrlActionHandler: (() -> Void)?,
        activationPosition: ActivationPosition?,
        visualErrorsEnabled: Bool
    ) {
        self.divKitComponents = divKitComponents
        self.onPreviewClickHandler = onPreviewClickHandler
        self.onOutsideClickHandler = onOutsideClickHandler
        self.onDetailsCloseHandler = onDetailsCloseHandler
        self.onUrlActionHandler = onUrlActionHandler
        self.activationPosition = activationPosition
        self.visualErrorsEnabled = visualErrorsEnabled
    }
    
    /**
     * Builder class for creating ActivationConfig instances
     *
     * Uses the Builder pattern to provide a fluent API for configuring activation views.
     * This approach makes it easy to set optional parameters and ensures immutability
     * of the final ActivationConfig object.
     */
    public class Builder {
        // Internal flag for enabling visual error indicators (default: true)
        private var visualErrorsEnabled = true
        
        // Internal storage for preview click handler
        private var onPreviewClickHandler: (() -> Void)?
        
        // Internal storage for URL action handler
        private var onUrlActionHandler: (() -> Void)?
        
        // Internal storage for details close handler
        private var onDetailsCloseHandler: (() -> Void)?
        
        // Internal storage for outside click handler
        private var onOutsideClickHandler: (() -> Void)?
        
        // Internal storage for activation position configuration
        private var activationPosition: ActivationPosition?
        
        /**
         * Initialize a new Builder instance with default values
         */
        public init() {
            // Builder initialized with default values
        }
        
        /**
         * Set the handler for preview click events
         *
         * - Parameter handler: Closure to execute when preview is clicked
         * - Returns: Self for method chaining
         */
        @discardableResult
        public func setPreviewClickHandler(_ handler: @escaping () -> Void) -> Builder {
            self.onPreviewClickHandler = handler
            return self
        }
        
        /**
         * Set the handler for URL action events
         *
         * - Parameter handler: Closure to execute when URL actions are triggered
         * - Returns: Self for method chaining
         */
        @discardableResult
        public func setUrlActionHandler(_ handler: @escaping () -> Void) -> Builder {
            self.onUrlActionHandler = handler
            return self
        }
        
        /**
         * Set the handler for outside click events
         *
         * - Parameter handler: Closure to execute when user clicks outside the activation view
         * - Returns: Self for method chaining
         */
        @discardableResult
        public func setOutsideClickHandler(_ handler: @escaping () -> Void) -> Builder {
            self.onOutsideClickHandler = handler
            return self
        }
        
        /**
         * Set the handler for details close events
         *
         * - Parameter handler: Closure to execute when details view is closed
         * - Returns: Self for method chaining
         */
        @discardableResult
        public func setDetailsCloseHandler(_ handler: @escaping () -> Void) -> Builder {
            self.onDetailsCloseHandler = handler
            return self
        }
        
        /**
         * Configure whether visual error indicators should be displayed
         *
         * - Parameter enabled: True to show visual errors, false to hide them
         * - Returns: Self for method chaining
         */
        @discardableResult
        public func setVisualErrorsEnabled(_ enabled: Bool) -> Builder {
            self.visualErrorsEnabled = enabled
            return self
        }
        
        /**
         * Set the positioning configuration for the activation view
         *
         * - Parameter activationPosition: Position configuration object
         * - Returns: Self for method chaining
         */
        @discardableResult
        public func setActivationPosition(_ activationPosition: ActivationPosition) -> Builder {
            self.activationPosition = activationPosition
            return self
        }
        
        /**
         * Build the final ActivationConfig instance
         *
         * This method creates the necessary DivKit components and URL handlers,
         * then constructs the immutable ActivationConfig object.
         *
         * - Returns: Configured ActivationConfig instance ready for use
         */
        public func build() -> ActivationConfig {
            // Get screen bounds for potential layout calculations
            let _ = UIScreen.main.bounds.size
            
            // Create custom URL handler with configured callbacks
            let urlHandler = CustomUrlHandler(
                onCloseAction: self.onDetailsCloseHandler,
                onExternalUrlAction: { [weak self] url in
                    // Execute URL action handler when external URLs are opened
                    self?.onUrlActionHandler?()
                },
                onCustomSchemeAction: { [weak self] url in
                    // Execute URL action handler when custom scheme URLs are handled
                    self?.onUrlActionHandler?()
                }
            )
            
            // Create DivKit components with the custom URL handler
            let divKitComponents = DivKitComponents(urlHandler: urlHandler)
            
            // Return the configured ActivationConfig instance
            return ActivationConfig(
                divKitComponents: divKitComponents,
                onPreviewClickHandler: onPreviewClickHandler,
                onOutsideClickHandler: onOutsideClickHandler,
                onDetailsCloseHandler: onDetailsCloseHandler,
                onUrlActionHandler: onUrlActionHandler,
                activationPosition: activationPosition,
                visualErrorsEnabled: visualErrorsEnabled
            )
        }
    }
}

/**
 * Enumeration defining possible alignment positions for UI elements
 *
 * This enum provides standard alignment options that can be used throughout
 * the application for consistent positioning of activation views and other components.
 */
public enum Alignment {
    // Align to top-left corner
    case topLeading
    
    // Align to top-right corner
    case topTrailing
    
    // Align to bottom-left corner
    case bottomLeading
    
    // Align to bottom-right corner
    case bottomTrailing
    
    // Align to center of the container
    case center
}
