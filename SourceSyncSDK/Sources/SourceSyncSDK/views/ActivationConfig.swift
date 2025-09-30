//
//  ActivationConfig.swift
//  
//
//  Created by ayman badawy on 25/09/2025.
//

import UIKit
import DivKit
import DivKitExtensions

/**
 * Configuration builder for Activation views
 */
public class ActivationConfig {
    let divKitComponents: DivKitComponents
    let onPreviewClickHandler: (() -> Void)?
    let onOutsideClickHandler: (() -> Void)?
    let onDetailsCloseHandler: (() -> Void)?
    let onUrlActionHandler: (() -> Void)?
    let activationPosition: ActivationPosition
    let visualErrorsEnabled: Bool
    
    private init(
        divKitComponents: DivKitComponents,
        onPreviewClickHandler: (() -> Void)?,
        onOutsideClickHandler: (() -> Void)?,
        onDetailsCloseHandler: (() -> Void)?,
        onUrlActionHandler: (() -> Void)?,
        activationPosition: ActivationPosition,
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
    
    public class Builder {
        private let context: UIViewController
        private var visualErrorsEnabled = true
        private var onPreviewClickHandler: (() -> Void)?
        private var onUrlActionHandler: (() -> Void)?
        private var onDetailsCloseHandler: (() -> Void)?
        private var onOutsideClickHandler: (() -> Void)?
        private var positionAlignment: Alignment?
        
        public init(context: UIViewController) {
            self.context = context
        }
        
        @discardableResult
        public func setPreviewClickHandler(_ handler: @escaping () -> Void) -> Builder {
            self.onPreviewClickHandler = handler
            return self
        }
        
        @discardableResult
        public func setUrlActionHandler(_ handler: @escaping () -> Void) -> Builder {
            self.onUrlActionHandler = handler
            return self
        }
        
        @discardableResult
        public func setOutsideClickHandler(_ handler: @escaping () -> Void) -> Builder {
            self.onOutsideClickHandler = handler
            return self
        }
        
        @discardableResult
        public func setDetailsCloseHandler(_ handler: @escaping () -> Void) -> Builder {
            self.onDetailsCloseHandler = handler
            return self
        }
        
        @discardableResult
        public func setPositionAlignment(_ alignment: Alignment) -> Builder {
            self.positionAlignment = alignment
            return self
        }
        
        @discardableResult
        public func setVisualErrorsEnabled(_ enabled: Bool) -> Builder {
            self.visualErrorsEnabled = enabled
            return self
        }
        
        public func build() -> ActivationConfig {
            let screenSize = UIScreen.main.bounds.size
            
            // Create URL handler
            let urlHandler = EnhancedDivUrlHandler(
                onCloseAction: { [weak self] in
                    self?.onDetailsCloseHandler?()
                },
                onExternalUrlAction: { [weak self] url in
                    self?.onUrlActionHandler?()
                },
                onCustomSchemeAction: { [weak self] url in
                    self?.onUrlActionHandler?()
                }
            )
            
            // Create DivKit components
            let divKitComponents = DivKitComponents(
                urlHandler: urlHandler
            )
            
            return ActivationConfig(
                divKitComponents: divKitComponents,
                onPreviewClickHandler: onPreviewClickHandler,
                onOutsideClickHandler: onOutsideClickHandler,
                onDetailsCloseHandler: onDetailsCloseHandler,
                onUrlActionHandler: onUrlActionHandler,
                activationPosition: ActivationPosition(
                    screenWidth: screenSize.width,
                    screenHeight: screenSize.height,
                    alignment: positionAlignment ?? .topTrailing
                ),
                visualErrorsEnabled: visualErrorsEnabled
            )
        }
    }
}

// MARK: - Supporting Types

public enum Alignment {
    case topLeading, topTrailing, bottomLeading, bottomTrailing, center
}
