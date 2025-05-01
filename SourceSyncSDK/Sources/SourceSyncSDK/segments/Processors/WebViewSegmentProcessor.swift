//
//  WebViewSegmentProcessor.swift
//  SourceSyncSDK
//
//  Created by ayman badawy on 16/04/2025.
//

import UIKit
import WebKit
import ObjectiveC

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
        let configuration = WKWebViewConfiguration()
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
        
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.translatesAutoresizingMaskIntoConstraints = false
        
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
    
    // Static keys for associated objects
    private let widthObservationKey = UnsafeRawPointer(bitPattern: 1)!
    private let heightObservationKey = UnsafeRawPointer(bitPattern: 2)!
    
    private func configureLayoutParams(webView: WKWebView, attributes: SegmentAttributes) {
        // Get screen dimensions for fallback
        let screenSize = UIScreen.main.bounds.size
        
        // Handle width
        if let width = attributes.width, LayoutUtils.isValidPercentage(width) {
            do {
                let percentage = try LayoutUtils.percentageToDecimal(width)
                
                if let superview = webView.superview {
                    if superview is UIStackView {
                        // In a stack view - don't set width constraints
                    } else {
                        // Remove any existing width constraints
                        removeConstraints(from: webView, for: .width)
                        
                        // Create new constraint
                        let constraint = webView.widthAnchor.constraint(
                            equalTo: superview.widthAnchor,
                            multiplier: percentage
                        )
                        constraint.priority = .defaultHigh
                        constraint.isActive = true
                    }
                } else {
                    // Fallback to screen width percentage
                    let constraint = webView.widthAnchor.constraint(
                        equalToConstant: screenSize.width * percentage
                    )
                    constraint.priority = .defaultHigh
                    constraint.isActive = true
                    
                    // Update constraint when added to superview
                    setupSuperviewObserver(for: webView, isWidth: true, percentage: percentage)
                }
            } catch {
                print("\(WebViewSegmentProcessor.TAG): Error parsing width: \(error)")
            }
        } else {
            if let superview = webView.superview {
                if !(superview is UIStackView) {
                    // Remove any existing width constraints
                    removeConstraints(from: webView, for: .width)
                    
                    // Create new constraint
                    let constraint = webView.widthAnchor.constraint(equalTo: superview.widthAnchor)
                    constraint.priority = .defaultHigh
                    constraint.isActive = true
                }
            } else {
                let constraint = webView.widthAnchor.constraint(equalToConstant: screenSize.width)
                constraint.priority = .defaultHigh
                constraint.isActive = true
                setupSuperviewObserver(for: webView, isWidth: true, percentage: 1.0)
            }
        }
        
        // Handle height
        if let height = attributes.height {
            if LayoutUtils.isValidPercentage(height) {
                do {
                    let percentage = try LayoutUtils.percentageToDecimal(height)
                    
                    if let superview = webView.superview {
                        // Remove any existing height constraints
                        removeConstraints(from: webView, for: .height)
                        
                        // Create new constraint
                        let constraint = webView.heightAnchor.constraint(
                            equalTo: superview.heightAnchor,
                            multiplier: percentage
                        )
                        constraint.priority = .defaultHigh
                        constraint.isActive = true
                    } else {
                        // Fallback to screen height percentage
                        let constraint = webView.heightAnchor.constraint(
                            equalToConstant: screenSize.height * percentage
                        )
                        constraint.priority = .defaultHigh
                        constraint.isActive = true
                        
                        // Update constraint when added to superview
                        setupSuperviewObserver(for: webView, isWidth: false, percentage: percentage)
                    }
                } catch {
                    print("\(WebViewSegmentProcessor.TAG): Error parsing height: \(error)")
                    fallbackHeightConstraint(webView)
                }
            } else if height == "auto" {
                // No constraint for auto height
            } else if let heightValue = Int(height) {
                // Remove any existing height constraints
                removeConstraints(from: webView, for: .height)
                
                let constraint = webView.heightAnchor.constraint(equalToConstant: CGFloat(heightValue))
                constraint.priority = .defaultHigh
                constraint.isActive = true
            } else {
                fallbackHeightConstraint(webView)
            }
        } else {
            fallbackHeightConstraint(webView)
        }
    }
    
    // Helper function for default height constraint
    private func fallbackHeightConstraint(_ view: UIView) {
        // Remove any existing height constraints
        removeConstraints(from: view, for: .height)
        
        // Default height
        let constraint = view.heightAnchor.constraint(equalToConstant: 300)
        constraint.priority = .defaultHigh
        constraint.isActive = true
    }
    
    // Helper to remove existing constraints
    private func removeConstraints(from view: UIView, for attribute: NSLayoutConstraint.Attribute) {
        view.constraints.forEach { constraint in
            if constraint.firstItem === view && constraint.firstAttribute == attribute {
                view.removeConstraint(constraint)
            }
        }
        
        // Also check superview constraints
        if let superview = view.superview {
            superview.constraints.forEach { constraint in
                if (constraint.firstItem === view && constraint.firstAttribute == attribute) ||
                   (constraint.secondItem === view && constraint.secondAttribute == attribute) {
                    superview.removeConstraint(constraint)
                }
            }
        }
    }

    // Helper method to set up observers for superview changes
    private func setupSuperviewObserver(for view: UIView, isWidth: Bool, percentage: CGFloat) {
        let observation = view.observe(\.superview) { [weak self] observed, _ in
            guard let self = self,
                  let superview = observed.superview else { return }
            
            // Skip if parent is a stack view and we're setting width
            if isWidth && superview is UIStackView {
                return
            }
            
            // Remove existing constraints
            self.removeConstraints(from: observed, for: isWidth ? .width : .height)
            
            // Apply new constraint based on parent
            let constraint: NSLayoutConstraint
            if isWidth {
                constraint = observed.widthAnchor.constraint(
                    equalTo: superview.widthAnchor,
                    multiplier: percentage
                )
            } else {
                constraint = observed.heightAnchor.constraint(
                    equalTo: superview.heightAnchor,
                    multiplier: percentage
                )
            }
            
            constraint.priority = .defaultHigh
            constraint.isActive = true
        }
        
        // Store observation to prevent deallocation
        objc_setAssociatedObject(
            view,
            isWidth ? widthObservationKey : heightObservationKey,
            observation,
            .OBJC_ASSOCIATION_RETAIN_NONATOMIC
        )
    }
}
