//
//  ActivationDemoViewController.swift
//  MobileDemo

import SourceSyncSDK
import AVFoundation
import UIKit

class ActivationDemoViewController : UIViewController {
    private var activation: ActivationView?
    
    private let TAG = "ActivationDemoViewController"
    
    // Template file names - store just the names of the files without extensions
    private enum TemplateFiles {
        static let previewTemplate1 = "preview_template_1"
        static let detailsTemplate1 = "details_template_1"
        static let previewTemplate2 = "preview_template_2"
        static let detailsTemplate2 = "details_template_2"
        static let previewTemplate3 = "preview_template_3"
        static let detailsTemplate3 = "details_template_3"
        static let previewTemplate4 = "preview_template_4"
        static let detailsTemplate4 = "details_template_4"
        static let previewTemplate5 = "preview_template_5"
        static let detailsTemplate5 = "details_template_5"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupActivation()
    }
    
    private func setupActivation() {
        // Load the template from the file
        guard let previewTemplate = TemplateLoader.loadTemplate(fileName: TemplateFiles.previewTemplate3),
              let detailsTemplate = TemplateLoader.loadTemplate(fileName: TemplateFiles.detailsTemplate3) else {
            print("\(TAG): Failed to load templates")
            return
        }
        
        // Create activation view using the context initializer
        activation = ActivationView(context: self)
        
        // Add to view controller's view
        if let activation = activation {
            activation.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(activation)
            
            NSLayoutConstraint.activate([
                activation.topAnchor.constraint(equalTo: view.topAnchor),
                activation.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                activation.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                activation.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
            
            // Show the preview
            let progressImageView = UIImage.gif(name: "activation_img")
            activation.showPreview(
                previewData: previewTemplate,
                showProgress: true,
                progressDuration: 10,
                progressImage: progressImageView
            ) {
                // When clicked, show activation detail
                activation.showDetail(detailData: detailsTemplate) {
                    activation.hideDetail()
                }
            }
        }
    }
}
