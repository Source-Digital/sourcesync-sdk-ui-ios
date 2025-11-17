//  Created by ayman badawy on 25/09/2025.
//
/**
 * ActivationPosition
 *
 * A configuration structure that defines the positioning and sizing parameters
 * for activation views within the application interface.
 *
 * This struct encapsulates screen dimensions and alignment preferences to enable
 * precise positioning of activation components across different device sizes and
 * orientations. It provides a standardized way to handle layout calculations
 * and ensures consistent positioning behavior throughout the application.
 *
 */
public struct ActivationPosition {
    
    // The total width of the target screen in points
    // Used for calculating horizontal positioning and layout constraints
    // Should typically be set to UIScreen.main.bounds.width or the containing view's width
    let screenWidth: CGFloat
    
    // The total height of the target screen in points
    // Used for calculating vertical positioning and layout constraints
    // Should typically be set to UIScreen.main.bounds.height or the containing view's height
    let screenHeight: CGFloat
    
    // The desired alignment/positioning strategy for the activation view
    // Determines how the activation component should be positioned relative to the screen bounds
    // Works in conjunction with screen dimensions to calculate final placement
    let alignment: Alignment
    
    /**
     * Initialize an ActivationPosition with screen dimensions and alignment
     *
     * Creates a new position configuration that can be used to determine where
     * activation views should be placed on screen. The screen dimensions are used
     * for layout calculations while the alignment determines the positioning strategy.
     *
     * - Parameters:
     *   - screenWidth: The width of the target screen or container view in points.
     *                  Must be greater than 0 for proper layout calculations.
     *   - screenHeight: The height of the target screen or container view in points.
     *                   Must be greater than 0 for proper layout calculations.
     *   - alignment: The positioning strategy from the Alignment enum.
     *                Determines where the activation view will be placed relative to the screen bounds.
     */
    public init(screenWidth: CGFloat, screenHeight: CGFloat, alignment: Alignment) {
        self.screenWidth = screenWidth
        self.screenHeight = screenHeight
        self.alignment = alignment
    }
}
