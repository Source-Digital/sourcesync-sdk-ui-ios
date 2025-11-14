
import UIKit
import DivKit
import DivKitExtensions

/**
 * LegacyActivationPreview
 *
 * A UIView that renders the initial preview content for activations using the DivKit templating system.
 * This view takes JSON template data and uses DivKit to render a customizable preview that can be shown
 * to users during media playback or other interactions.
 *
 * The LegacyActivationPreview is typically the first stage of the activation flow, showing a compact
 * representation that can be tapped to reveal more detailed content.
 */
class LegacyActivationPreview: UIView {
    // Tag for logging purposes
    private static let TAG = "LegacyActivationPreview"
    
    // The DivKit components used to render the template
    lazy var divKitComponents = makeDivKitComponents()
    
    // The DivKit view that renders the template
    lazy var divView = DivView(divKitComponents: divKitComponents)
    
    /**
     * Creates an LegacyActivationPreview view with the specified template data.
     *
     * @param previewData The JSON data containing the DivKit template for the preview.
     *
     * The template data should follow DivKit's JSON format and will be rendered by the DivKit engine.
     */

    init(previewData: Data) {
        super.init(frame: .zero)
        addSubview(divView)
        
        // Setup proper constraints for divView
        divView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            divView.topAnchor.constraint(equalTo: topAnchor),
            divView.leadingAnchor.constraint(equalTo: leadingAnchor),
            divView.bottomAnchor.constraint(equalTo: bottomAnchor),
            divView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
        
        Task {
          await configureDivView(previewData: previewData)
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
     * @param previewData The JSON data containing the DivKit template.
     */
    private func configureDivView(previewData: Data) async {
        await divView.setSource(
            .init(kind: .data(previewData), cardId: "div_preview"),
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
        return DivKitComponents(
        )
    }
}
