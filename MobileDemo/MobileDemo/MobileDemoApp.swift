//
//  MobileDemoApp.swift
//  MobileDemo


import SwiftUI

@main
struct MobileDemoApp: App {
    var body: some Scene {
        WindowGroup {
            ActivationDemoViewControllerWrapper()
        }
    }
    
    struct ActivationDemoViewControllerWrapper: UIViewControllerRepresentable {
        func makeUIViewController(context: Context) -> some UIViewController {
            return ActivationDemoViewController()
        }
        
        func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
            // No updates needed
        }
    }
}
