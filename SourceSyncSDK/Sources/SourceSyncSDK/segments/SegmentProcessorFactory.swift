//
//  SegmentProcessorFactory.swift
//  sourcesync-sdk-ui-ios
//

import UIKit

// Factory class for managing different types of segment processors.
class SegmentProcessorFactory {
    private var processors: [String: SegmentProcessor] = [:]
    private let parentContainer: UIView
    
    // Initializes the factory with a parent container and registers default processors.
    // - Parameter parentContainer: The parent view that contains the segments.
    init(parentContainer: UIView) {
        self.parentContainer = parentContainer
        registerDefaultProcessors()
    }
    
    // Registers the default set of segment processors.
    private func registerDefaultProcessors() {
        registerProcessor(TextSegmentProcessor())
        registerProcessor(ImageSegmentProcessor(parentContainer: parentContainer))
        registerProcessor(ButtonSegmentProcessor())
        registerProcessor(RowSegmentProcessor(processorFactory: self, parentContainer: parentContainer))
        registerProcessor(ColumnSegmentProcessor(processorFactory: self, parentContainer: parentContainer))
    }
    
    // Registers a custom segment processor.
    // - Parameter processor: The processor instance to be registered.
    func registerProcessor(_ processor: SegmentProcessor) {
        processors[processor.getSegmentType()] = processor
    }
    
    // Retrieves a processor based on the segment type.
    // - Parameter segmentType: The type of segment processor required.
    // - Returns: The corresponding `SegmentProcessor`, or `nil` if not found.
    func getProcessor(for segmentType: String) -> SegmentProcessor? {
        return processors[segmentType]
    }
}

