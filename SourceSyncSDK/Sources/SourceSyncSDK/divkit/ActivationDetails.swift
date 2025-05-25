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
    /// Tag for logging purposes
    private static let TAG = "ActivationDetails"
    
    /// The DivKit components used to render the template
    lazy var divKitComponents = makeDivKitComponents()
    
    /// The DivKit view that renders the template
    lazy var divView = DivView(divKitComponents: divKitComponents)
    
    /// The parent view controller, used for handling actions like showing alerts or navigation
    private weak var parentViewController: UIViewController?
    
    // Closure to execute when the details view is closed via the close action
    private var onCloseHandler: (() -> Void)?
    /**
     * Creates an ActivationDetails view with the specified template data.
     *
     * @param detailsData The JSON data containing the DivKit template for the details view.
     * @param parentViewController The parent view controller, used for handling actions.
     * @param onClose Closure to execute when the close action is triggered.
     *
     * The template data should follow DivKit's JSON format and will be rendered by the DivKit engine.
     */
    init(detailsData: Data, parentViewController: UIViewController?, onClose: @escaping () -> Void) {
        super.init(frame: .zero)
        self.parentViewController = parentViewController
        self.onCloseHandler = onClose
        
        addSubview(divView)
        
        // Setup proper constraints for divView
        divView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            divView.topAnchor.constraint(equalTo: topAnchor),
            divView.bottomAnchor.constraint(equalTo: bottomAnchor),
            divView.leadingAnchor.constraint(equalTo: leadingAnchor),
            divView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
        
        Task {
            await configureDivView(detailsData: detailsData)
        }
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
        await divView.setSource(
            .init(kind: .data(detailsData), cardId: "div_detail"),
            debugParams: DebugParams(isDebugInfoEnabled: false)
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
        
        let customBlockFactory = SampleDivCustomBlockFactory()
        // Create a custom action handler that will handle the close action
        let urlHandler = ActivationCloseActionHandler(onCloseAction: {[weak self] in self?.onCloseHandler?()})
        
        // Create a proper component with all required parameters
        return DivKitComponents(
            divCustomBlockFactory: customBlockFactory,
            urlHandler: urlHandler
        )
    }
}


/**
 * ActivationCloseActionHandler
 *
 * A custom DivKit URL handler that specifically handles the close action from the activation details view.
 * This handler looks for a specific URL scheme ('div-action://close') and executes the close handler
 * when that URL is encountered.
 */
class ActivationCloseActionHandler: DivUrlHandler{
    var onCloseAction: (() -> Void)?
    
    init(onCloseAction: @escaping () -> Void){
        self.onCloseAction = onCloseAction
    }
    
    func handle(_ url: URL, info _: DivActionInfo, sender _: AnyObject?) {
        if url.absoluteString.hasPrefix("div-action://close"){
            onCloseAction?()
        }
    }
}
