//
//  Created by ayman badawy on 04/09/2025.
//

import DivKit
import DivKitExtensions

/**
 * Custom implementation of DivReporter for handling DivKit errors and actions
 *
 * This class provides a customized error reporting mechanism for DivKit components,
 * allowing the application to intercept and handle DivKit errors through a delegate pattern.
 * It suppresses the default error UI display and provides custom error handling logic.
 */
class CustomDivReporter: DivReporter {
    
    /// Weak reference to the error delegate to prevent retain cycles
    /// This delegate will receive all DivKit errors for custom handling
    weak var errorDelegate: DivKitErrorDelegate?
    
    /**
     * Report errors that occur within DivKit components
     *
     * This method is called by DivKit when errors occur during card rendering or processing.
     * It logs the error to console and forwards it to the error delegate for custom handling.
     *
     * - Parameters:
     *   - cardId: Unique identifier of the DivCard where the error occurred
     *   - error: The DivError instance containing error details
     */
    func reportError(cardId: DivCardID, error: any DivError) {
        // Log error to console for debugging purposes
        print("Custom Div Reporter Error: \(error)")
        
        // Forward error to delegate for custom handling
        errorDelegate?.handleDivKitError(error, cardId: cardId)
    }
    
    /**
     * Report actions performed within DivKit components
     *
     * This method is called when user actions occur within DivKit cards.
     * Currently implemented as a no-op but can be extended for action tracking,
     * analytics, or custom action handling.
     *
     * - Parameters:
     *   - cardId: Unique identifier of the DivCard where the action occurred
     *   - info: Information about the action that was performed
     */
    func reportAction(cardId: DivCardID, info: DivActionInfo) {
        // Currently no custom action handling implemented
        // This can be extended to track user interactions or trigger custom behaviors
    }
    
    /**
     * Determines whether DivKit should display its default error UI
     *
     * Override the default behavior to prevent DivKit from showing error dialogs
     * or visual error indicators. This allows the application to handle errors
     * through the custom delegate pattern instead.
     *
     * - Returns: false to suppress default error UI display
     */
    func shouldDisplayError() -> Bool {
        // Prevent DivKit from showing default error UI
        // All error handling is done through the errorDelegate
        return false
    }
}

/**
 * Protocol for handling DivKit errors through delegation
 *
 * Classes conforming to this protocol can receive and handle DivKit errors
 * in a custom way, allowing for application-specific error handling, logging,
 * or user notification strategies.
 */
protocol DivKitErrorDelegate: AnyObject {
    
    /**
     * Handle a DivKit error that occurred during card processing
     *
     * This method will be called whenever a DivKit error occurs, allowing
     * the implementing class to decide how to handle the error (log it,
     * show user-friendly messages, retry operations, etc.)
     *
     * - Parameters:
     *   - error: The DivError that occurred, containing error details and context
     *   - cardId: The unique identifier of the DivCard where the error occurred
     */
    func handleDivKitError(_ error: any DivError, cardId: DivCardID)
}
