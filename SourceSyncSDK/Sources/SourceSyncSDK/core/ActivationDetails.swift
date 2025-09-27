//
//  ActivationDetail.swift
//  sourcesync-sdk-ui-ios
//

import UIKit
import DivKit
import DivKitExtensions

/**
 * ActivationDetails
 *
 * A UIView that renders interactive detail content for activations using DivKit templating system.
 * This view takes JSON template data and uses DivKit to render rich, interactive content.
 *
 * The ActivationDetails view is typically shown after a user interacts with an activation preview,
 * providing more detailed information or interactive elements.
 *
 **/
class ActivationDetails: UIView {
    // Tag for logging purposes
    private static let TAG = "ActivationDetails"
    var divView: DivView?
//    // The DivKit components used to render the template
//    lazy var divKitComponents = makeDivKitComponents()
//
//    // The DivKit view that renders the template
//    lazy var divView = DivView(divKitComponents: divKitComponents)
    
    // Closure to execute when the details view is closed via the close action
    private var onCloseHandler: (() -> Void)?
    
    private var widthPercentage:CGFloat = 0.5

    private var errorHandler: CustomDivReporter
    /**
     *
     * Creates an ActivationDetails view with the specified template data.
     *
     * @param detailsData The JSON data containing the DivKit template for the details view.
     * @param onClose Closure to execute when the close action is triggered.
     *
     * The template data should follow DivKit's JSON format and will be rendered by the DivKit engine.
     */
    
    init(detailsData: Data, widthPercentage: CGFloat, onClose: @escaping () -> Void, errorHandler: CustomDivReporter) {
        super.init(frame: .zero)
        self.onCloseHandler = onClose
        self.widthPercentage = widthPercentage
        self.errorHandler = errorHandler
        
        let urlHandler = EnhancedDivUrlHandler(
            onCloseAction: {[weak self] in self?.onCloseHandler?()},
            onExternalUrlAction: { url in
                // Optional: Custom handling for external URLs
                // For example, open in in-app browser instead of Safari
                print("Opening external URL: \(url)")
            },
            onCustomSchemeAction: { url in
                // Optional: Handle custom schemes not covered by default implementation
                print("Handling custom scheme: \(url)")
            }
        )
        
        // Create a proper component with all required parameters
        let divKitComponents = DivKitComponents(
            divCustomBlockFactory: nil,
            reporter: errorHandler,
            urlHandler: urlHandler
        )
        
        divView = DivView(divKitComponents: divKitComponents)

        addSubview(divView!)
        
        // Setup proper constraints for divView
        divView!.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            divView!.topAnchor.constraint(equalTo: topAnchor),
            divView!.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            // 50% width on right side
            divView!.trailingAnchor.constraint(equalTo: trailingAnchor),
            divView!.widthAnchor.constraint(equalTo: widthAnchor)
        ])
        
        Task {
            await configureDivView(detailsData: detailsData)
        }
    }
    
    override var intrinsicContentSize: CGSize {
        let screenSize = UIScreen.main.bounds.size
        return CGSize(
            width: screenSize.width * widthPercentage ,  // initially 50% of screen width
            height: screenSize.height     // Full screen height
        )
    }
    
    /**
     * Required initializer for NSCoding, not implemented.
     */
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /**
     * Configures the DivKit view with the provided template data.
     *
     * @param detailsData The JSON data containing the DivKit template.
     */
    private func configureDivView(detailsData: Data) async {
        await divView!.setSource(
            .init(kind: .data(detailsData), cardId: "div_detail"),
            debugParams: DebugParams(isDebugInfoEnabled: true)
        )
    }
    
    /**
     * Creates a configured instance of DivKitComponents.
     *
     * @return A configured DivKitComponents instance for rendering DivKit templates.
     *
     * This method sets up the DivKit components with a custom block factory and other
     * required configurations. It can be extended to include additional configurations
     */
    private func makeDivKitComponents() -> DivKitComponents {
        
        // Create a custom action handler that will handle the close action
        let urlHandler = EnhancedDivUrlHandler(
            onCloseAction: {[weak self] in self?.onCloseHandler?()},
            onExternalUrlAction: { url in
                // Optional: Custom handling for external URLs
                // For example, open in in-app browser instead of Safari
                print("Opening external URL: \(url)")
            },
            onCustomSchemeAction: { url in
                // Optional: Handle custom schemes not covered by default implementation
                print("Handling custom scheme: \(url)")
            }
        )
        
        // Create a proper component with all required parameters
        return DivKitComponents(
            urlHandler: urlHandler
        )
    }
}
