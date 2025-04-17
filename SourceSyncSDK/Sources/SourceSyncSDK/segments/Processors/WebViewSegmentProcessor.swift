//
//  WebViewSegmentProcessor.swift
//  SourceSyncSDK
//
//  Created by ayman badawy on 16/04/2025.
//

import UIKit
import WebKit

class WebViewSegmentProcessor: SegmentProcessor {
    private static let TAG = "WebViewSegmentProcessor"
    
    init() {}
    
    func processSegment(segment: [String: Any]) throws -> UIView {
        // Extract URL from the segment content
        guard let content = segment["content"] as? String else {
            throw NSError(domain: "WebViewSegmentProcessor", code: 1, userInfo: [NSLocalizedDescriptionKey: "Missing or invalid content"])
        }
        
        guard let url = URL(string: content) else {
            throw NSError(domain: "WebViewSegmentProcessor", code: 2, userInfo: [NSLocalizedDescriptionKey: "Invalid URL format"])
        }
        
        // Create a WebView
        let webView = WKWebView()
        webView.translatesAutoresizingMaskIntoConstraints = false
        
        // Configure WebView settings
        let configuration = webView.configuration
        if #available(iOS 14.0, *) {
            // Use the new API for iOS 14 and later
            let webpagePreferences = WKWebpagePreferences()
            webpagePreferences.allowsContentJavaScript = true
            configuration.defaultWebpagePreferences = webpagePreferences
        } else {
            // Fallback for iOS 13 and earlier
            configuration.preferences.javaScriptEnabled = true
        }
        configuration.preferences.javaScriptCanOpenWindowsAutomatically = true
        configuration.allowsInlineMediaPlayback = true
        // Set navigation delegate for page loading events
        
        // Load the URL
        let request = URLRequest(url: url)
        webView.load(request)
        
        // Apply attributes if available
        if let attributesJson = segment["attributes"] as? [String: Any] {
            let attributes = try SegmentAttributes.fromJson(json: attributesJson)
            
            // Configure layout parameters
            configureLayoutParams(webView: webView, attributes: attributes)
        } else {
            // Default height: 300dp equivalent if no attributes
            let heightConstraint = webView.heightAnchor.constraint(equalToConstant: 300)
            heightConstraint.priority = .defaultHigh
            heightConstraint.isActive = true
        }
        
        return webView
    }
    
    func getSegmentType() -> String {
        return "webview"
    }
    
    // Helper method to configure layout parameters based on attributes
    private func configureLayoutParams(webView: WKWebView, attributes: SegmentAttributes) {
        webView.translatesAutoresizingMaskIntoConstraints = false
        
        // Handle width if specified as percentage
        if let width = attributes.width, LayoutUtils.isValidPercentage(width) {
            do {
                let weight = try LayoutUtils.percentageToDecimal(width)
                // Width constraint will be set when view is added to superview
                if let superview = webView.superview {
                    let constraint = webView.widthAnchor.constraint(
                        equalTo: superview.widthAnchor,
                        multiplier: weight
                    )
                    constraint.priority = .defaultHigh
                    constraint.isActive = true
                } else {
                    // Store the constraint for later activation when added to a superview
                    webView.tag = Int(weight * 100) // Store percentage in tag for later use
                    
                    // Add observer for when view is added to superview
                    NotificationCenter.default.addObserver(forName: UIView.didMoveToSuperviewNotification, object: webView, queue: nil) { [weak webView] _ in
                        guard let webView = webView, let superview = webView.superview else { return }
                        
                        let weight = CGFloat(webView.tag) / 100.0
                        let constraint = webView.widthAnchor.constraint(
                            equalTo: superview.widthAnchor,
                            multiplier: weight
                        )
                        constraint.priority = .defaultHigh
                        constraint.isActive = true
                    }
                }
            } catch {
                print("\(WebViewSegmentProcessor.TAG): Error parsing width percentage: \(error)")
            }
        } else {
            // Default to full width (equivalent to MATCH_PARENT)
            if let superview = webView.superview {
                let constraint = webView.widthAnchor.constraint(equalTo: superview.widthAnchor)
                constraint.priority = .defaultHigh
                constraint.isActive = true
            } else {
                // Add observer for when view is added to superview
                NotificationCenter.default.addObserver(forName: UIView.didMoveToSuperviewNotification, object: webView, queue: nil) { [weak webView] _ in
                    guard let webView = webView, let superview = webView.superview else { return }
                    
                    let constraint = webView.widthAnchor.constraint(equalTo: superview.widthAnchor)
                    constraint.priority = .defaultHigh
                    constraint.isActive = true
                }
            }
        }
        
        // Handle height if specified
        if let height = attributes.height {
            if LayoutUtils.isValidPercentage(height) {
                do {
                    let weight = try LayoutUtils.percentageToDecimal(height)
                    // Height constraint will be set when view is added to superview
                    if let superview = webView.superview {
                        let constraint = webView.heightAnchor.constraint(
                            equalTo: superview.heightAnchor,
                            multiplier: weight
                        )
                        constraint.priority = .defaultHigh
                        constraint.isActive = true
                    } else {
                        // Store the constraint for later activation when added to a superview
                        webView.accessibilityHint = String(describing:weight) // Store percentage in accessibilityHint for later use
                        
                        // Add observer for when view is added to superview
                        NotificationCenter.default.addObserver(forName: UIView.didMoveToSuperviewNotification, object: webView, queue: nil) { [weak webView] _ in
                            guard let webView = webView, let superview = webView.superview else { return }
                            
                            if let weightString = webView.accessibilityHint, let weight = Double(weightString) {
                                let constraint = webView.heightAnchor.constraint(
                                    equalTo: superview.heightAnchor,
                                    multiplier: CGFloat(weight)
                                )
                                constraint.priority = .defaultHigh
                                constraint.isActive = true
                            }
                        }
                    }
                } catch {
                    print("\(WebViewSegmentProcessor.TAG): Error parsing height percentage: \(error)")
                    // Default to 300dp equivalent if there's an error
                    let heightConstraint = webView.heightAnchor.constraint(equalToConstant: 300)
                    heightConstraint.priority = .defaultHigh
                    heightConstraint.isActive = true
                }
            } else if height == "auto" {
                // For auto height, let it be determined by content
                // No constraint needed
            } else {
                // Try to parse as a pixel value
                if let heightValue = Int(height) {
                    let heightConstraint = webView.heightAnchor.constraint(equalToConstant: CGFloat(heightValue))
                    heightConstraint.priority = .defaultHigh
                    heightConstraint.isActive = true
                } else {
                    // Default to 300dp equivalent if there's an error
                    let heightConstraint = webView.heightAnchor.constraint(equalToConstant: 300)
                    heightConstraint.priority = .defaultHigh
                    heightConstraint.isActive = true
                }
            }
        } else {
            // Default height: 300dp equivalent if no height specified
            let heightConstraint = webView.heightAnchor.constraint(equalToConstant: 300)
            heightConstraint.priority = .defaultHigh
            heightConstraint.isActive = true
        }
    }
}

extension UIView {
    static let didMoveToSuperviewNotification = Notification.Name("UIViewDidMoveToSuperviewNotification")
    
    func didMoveToSuperview() {
        super.inputView?.didMoveToSuperview()
        NotificationCenter.default.post(name: UIView.didMoveToSuperviewNotification, object: self)
    }
}
