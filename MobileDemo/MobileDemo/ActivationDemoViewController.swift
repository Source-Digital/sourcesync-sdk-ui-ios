//
//  ActivationDemoViewController.swift
//  MobileDemo

import SourceSyncSDK
import AVFoundation
import UIKit

/**
 * ActivationDemoViewController
 *
 * A demonstration view controller that showcases the usage of the Activation System.
 * This controller manages overlay activation UI components.
 */
class ActivationDemoViewController : UIViewController {
    private var activation: ActivationView?
    
    private let TAG = "ActivationDemoViewController"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupActivation()
    }
    
    private func setupActivation() {
        // Load the template from the file
        

        guard let previewUrl = Bundle.main.url(forResource: "div_preview1", withExtension: "json") else {
            print("\(TAG): Failed to load preview resource 'div_preview1.json'")
            return
        }
        
        guard let detailsUrl = Bundle.main.url(forResource: "div_details1", withExtension: "json") else {
            print("\(TAG): Failed to load details resource 'div_details.json'")
            return
        }
        
        let previewData: Data
        let detailsData: Data
        do {
            previewData = try Data(contentsOf: previewUrl)
            detailsData = try Data(contentsOf: detailsUrl)
        } catch {
            print("\(TAG): Failed to load data from file - \(error.localizedDescription)")
            return
        }
    
        // Create activation view using the context initializer
        activation = ActivationView(context: self)
        
        // Add to view controller's view
        if let activation = activation {
            view.addSubview(activation)
            
            activation.translatesAutoresizingMaskIntoConstraints = false

            NSLayoutConstraint.activate([
                activation.topAnchor.constraint(equalTo: view.topAnchor),
                activation.trailingAnchor.constraint(equalTo: view.trailingAnchor)
            ])
            
            // Show the preview
            activation.showPreview(
                previewData: previewData
            ) {
                // When clicked, show activation detail
                activation.showDetail(
                    detailsData: detailsData,
                    widthPercentage: 0.5,
                    onActionTriggered: {
                        // Handle any action triggered from detail view
                    },
                    onOutsideClicked: {
                        // This is called when user taps outside
                        // The hideDetails() is already called internally in ActivationView
                    },
                    onClose: {
                        // Handle close button if there is one in the detail view
                        activation.hideDetails()
                    }
                )
            }
        }
    }
}
