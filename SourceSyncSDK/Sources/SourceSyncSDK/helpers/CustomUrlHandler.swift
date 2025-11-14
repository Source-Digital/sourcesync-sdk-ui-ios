//
//  Created by ayman badawy on 22/07/2025.
//

import Foundation
import UIKit
import DivKit

/**
 * CustomUrlHandler
 *
 * A comprehensive DivKit URL handler that manages all URL types including:
 * - Close actions (div-action://close)
 * - External URLs (http/https)
 * - Custom scheme URLs
 * - Deep link handling
 *
 * This class implements the DivUrlHandler protocol to provide custom URL routing
 * and handling within DivKit components. It supports various URL schemes and
 * provides callback mechanisms for different types of URL interactions.
 */
class CustomUrlHandler: DivUrlHandler {
    
    /// Callback executed when a close action is triggered
    /// Used to handle UI dismissal or navigation back actions
    var onCloseAction: (() -> Void)?
    
    /// Callback executed when an external URL (http/https) is opened
    /// Receives the URL that was opened for tracking or analytics purposes
    var onExternalUrlAction: ((URL) -> Void)?
    
    /// Callback executed when a custom scheme URL is handled
    /// Receives the custom scheme URL for application-specific processing
    var onCustomSchemeAction: ((URL) -> Void)?
    
    /**
     * Initialize the CustomUrlHandler with optional callback handlers
     *
     * - Parameters:
     *   - onCloseAction: Optional closure called when close actions are triggered
     *   - onExternalUrlAction: Optional closure called when external URLs are opened
     *   - onCustomSchemeAction: Optional closure called when custom scheme URLs are handled
     */
    init(
        onCloseAction: (() -> Void)? = nil,
        onExternalUrlAction: ((URL) -> Void)? = nil,
        onCustomSchemeAction: ((URL) -> Void)? = nil
    ) {
        self.onCloseAction = onCloseAction
        self.onExternalUrlAction = onExternalUrlAction
        self.onCustomSchemeAction = onCustomSchemeAction
    }
    
    /**
     * Main entry point for handling URLs from DivKit components
     *
     * This method is called by DivKit when a URL action is triggered within a card.
     * It analyzes the URL scheme and delegates to appropriate specialized handlers.
     *
     * - Parameters:
     *   - url: The URL to be handled
     *   - info: Additional information about the action context
     *   - sender: The object that triggered the URL action
     */
    func handle(_ url: URL, info: DivActionInfo, sender: AnyObject?) {
        // Convert URL to lowercase for case-insensitive comparison
        let urlString = url.absoluteString.lowercased()
        
        // Handle close action - highest priority for UI dismissal
        if urlString.hasPrefix("div-action://close") {
            handleCloseAction()
            return
        }
        
        // Handle external URLs (http/https) - open in browser or external app
        if urlString.hasPrefix("http://") || urlString.hasPrefix("https://") {
            handleExternalUrl(url)
            return
        }
        
        // Handle custom schemes - app-specific or system schemes
        if url.scheme != nil && !urlString.hasPrefix("http") {
            handleCustomScheme(url)
            return
        }
        
        // Fallback: log unhandled URLs for debugging and future implementation
        print("⚠️ Unhandled URL: \(url.absoluteString)")
    }
    
    /**
     * Handle close action requests
     *
     * Executes the onCloseAction callback on the main thread to ensure
     * UI updates happen on the correct thread. Used for dismissing modals,
     * navigation back actions, or closing overlay views.
     */
    private func handleCloseAction() {
        print("🔄 Executing close action")
        
        // Ensure UI updates happen on main thread
        DispatchQueue.main.async { [weak self] in
            self?.onCloseAction?()
        }
    }
    
    /**
     * Handle external URL requests (http/https)
     *
     * Opens URLs in the default browser or appropriate external application.
     * Includes error handling for URLs that cannot be opened and executes
     * the external URL callback for tracking purposes.
     *
     * - Parameter url: The external URL to open
     */
    private func handleExternalUrl(_ url: URL) {
        print("🌐 Opening external URL: \(url.absoluteString)")
        
        // Execute on main thread for UIApplication.shared access
        DispatchQueue.main.async { [weak self] in
            // Check if the system can handle this URL
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:]) { success in
                    if !success {
                        print("❌ Failed to open URL: \(url.absoluteString)")
                    } else {
                        // Notify callback on successful external URL opening
                        self?.onExternalUrlAction?(url)
                    }
                }
            } else {
                print("❌ Cannot open URL: \(url.absoluteString)")
            }
        }
    }
    
    /**
     * Handle custom scheme URLs
     *
     * Routes different custom URL schemes to appropriate handlers.
     * Supports common schemes like mailto, tel, sms, and custom div-action schemes.
     * Falls back to system handling for unrecognized schemes.
     *
     * - Parameter url: The custom scheme URL to handle
     */
    private func handleCustomScheme(_ url: URL) {
        print("🔗 Handling custom scheme: \(url.absoluteString)")
        
        guard let scheme = url.scheme else {
            print("❌ No scheme found for URL: \(url.absoluteString)")
            return
        }
        
        // Route to specific handlers based on scheme type
        switch scheme.lowercased() {
        case "mailto":
            handleMailtoUrl(url)
        case "tel", "sms":
            handleTelephoneUrl(url)
        case "div-action":
            handleDivAction(url)
        default:
            // Attempt to let the system handle unknown schemes
            attemptSystemOpen(url)
        }
        
        // Notify callback that a custom scheme was processed
        onCustomSchemeAction?(url)
    }
    
    /**
     * Handle mailto URLs for email composition
     *
     * Opens the default mail application with pre-populated email fields
     * based on the mailto URL parameters.
     *
     * - Parameter url: The mailto URL containing email details
     */
    private func handleMailtoUrl(_ url: URL) {
        DispatchQueue.main.async {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:])
            } else {
                print("❌ Mail app not available")
            }
        }
    }
    
    /**
     * Handle telephone and SMS URLs
     *
     * Opens the phone app for tel: schemes or Messages app for sms: schemes
     * to initiate calls or text messages with the specified number.
     *
     * - Parameter url: The tel: or sms: URL containing the phone number
     */
    private func handleTelephoneUrl(_ url: URL) {
        DispatchQueue.main.async {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:])
            } else {
                print("❌ Phone/SMS not available")
            }
        }
    }
    
    /**
     * Handle custom div-action scheme URLs
     *
     * Processes application-specific actions defined with the div-action:// scheme.
     * Supports actions like close, refresh, and back navigation.
     * Can be extended to support additional custom actions.
     *
     * - Parameter url: The div-action URL containing the action to perform
     */
    private func handleDivAction(_ url: URL) {
        let path = url.path.lowercased()
        let host = url.host?.lowercased()
        
        // Combine host and path to determine the specific action
        switch "\(host ?? "")\(path)" {
        case "close", "/close":
            handleCloseAction()
        case "refresh", "/refresh":
            handleRefreshAction()
        case "back", "/back":
            handleBackAction()
        default:
            print("⚠️ Unknown div-action: \(url.absoluteString)")
        }
    }
    
    /**
     * Handle refresh action requests
     *
     * Placeholder for implementing refresh functionality such as
     * reloading data, refreshing the current view, or updating content.
     * Should be implemented based on specific application requirements.
     */
    private func handleRefreshAction() {
        print("🔄 Refresh action triggered")
        // TODO: Add refresh logic here based on application needs
        // Examples: reload data, refresh UI, trigger data sync
    }
    
    /**
     * Handle back navigation requests
     *
     * Placeholder for implementing back navigation functionality.
     * Should be implemented to handle navigation stack management
     * based on the application's navigation architecture.
     */
    private func handleBackAction() {
        print("⬅️ Back action triggered")
        // TODO: Add back navigation logic here
        // Examples: pop view controller, dismiss modal, navigate to previous screen
    }
    
    /**
     * Attempt to open URL with system default handler
     *
     * Last resort handler for custom schemes that aren't explicitly handled.
     * Lets the iOS system attempt to find an appropriate app to handle the URL.
     *
     * - Parameter url: The URL to attempt opening with system handlers
     */
    private func attemptSystemOpen(_ url: URL) {
        DispatchQueue.main.async {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:]) { success in
                    if !success {
                        print("❌ Failed to open custom scheme: \(url.absoluteString)")
                    }
                }
            } else {
                print("❌ Cannot handle custom scheme: \(url.absoluteString)")
            }
        }
    }
}
