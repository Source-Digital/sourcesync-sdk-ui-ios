//
//  CustomUrlHandler.swift
//  Pods
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
 */
class CustomUrlHandler: DivUrlHandler {
    var onCloseAction: (() -> Void)?
    var onExternalUrlAction: ((URL) -> Void)?
    var onCustomSchemeAction: ((URL) -> Void)?
    
    init(
        onCloseAction: @escaping () -> Void,
        onExternalUrlAction: ((URL) -> Void)? = nil,
        onCustomSchemeAction: ((URL) -> Void)? = nil
    ) {
        self.onCloseAction = onCloseAction
        self.onExternalUrlAction = onExternalUrlAction
        self.onCustomSchemeAction = onCustomSchemeAction
    }
    
    func handle(_ url: URL, info: DivActionInfo, sender: AnyObject?) {
        let urlString = url.absoluteString.lowercased()
        
        // Handle close action
        if urlString.hasPrefix("div-action://close") {
            handleCloseAction()
            return
        }
        
        // Handle external URLs (http/https)
        if urlString.hasPrefix("http://") || urlString.hasPrefix("https://") {
            handleExternalUrl(url)
            return
        }
        
        // Handle custom schemes
        if url.scheme != nil && !urlString.hasPrefix("http") {
            handleCustomScheme(url)
            return
        }
        
        // Fallback: log unhandled URLs for debugging
        print("⚠️ Unhandled URL: \(url.absoluteString)")
    }
    
    // MARK: - Private Action Handlers
    
    private func handleCloseAction() {
        print("🔄 Executing close action")
        DispatchQueue.main.async { [weak self] in
            self?.onCloseAction?()
        }
    }
    
    private func handleExternalUrl(_ url: URL) {
        print("🌐 Opening external URL: \(url.absoluteString)")
        
        DispatchQueue.main.async {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:]) { success in
                    if !success {
                        print("❌ Failed to open URL: \(url.absoluteString)")
                    }
                }
            } else {
                print("❌ Cannot open URL: \(url.absoluteString)")
            }
        }
    }
    
    private func handleCustomScheme(_ url: URL) {
        print("🔗 Handling custom scheme: \(url.absoluteString)")
        
        guard let scheme = url.scheme else {
            print("❌ No scheme found for URL: \(url.absoluteString)")
            return
        }
        
        // Handle common custom schemes
        switch scheme.lowercased() {
        case "mailto":
            handleMailtoUrl(url)
        case "tel", "sms":
            handleTelephoneUrl(url)
        case "div-action":
            handleDivAction(url)
        default:
            attemptSystemOpen(url)
            
        }
    }
    
    private func handleMailtoUrl(_ url: URL) {
        DispatchQueue.main.async {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:])
            } else {
                print("❌ Mail app not available")
            }
        }
    }
    
    private func handleTelephoneUrl(_ url: URL) {
        DispatchQueue.main.async {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:])
            } else {
                print("❌ Phone/SMS not available")
            }
        }
    }
    
    private func handleDivAction(_ url: URL) {
        let path = url.path.lowercased()
        let host = url.host?.lowercased()
        
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
    
    private func handleRefreshAction() {
        print("🔄 Refresh action triggered")
        // Add refresh logic here
    }
    
    private func handleBackAction() {
        print("⬅️ Back action triggered")
        // Add back navigation logic here
    }
    
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
