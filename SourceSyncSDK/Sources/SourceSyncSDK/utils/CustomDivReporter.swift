//
//  CustomDivReporter.swift
//  Pods
//
//  Created by ayman badawy on 04/09/2025.
//
import DivKit
import DivKitExtensions

class CustomDivReporter: DivReporter {
    
    weak var errorDelegate: DivKitErrorDelegate?
    
    func reportError(cardId: DivCardID, error: any DivError) {
        print("Custom Div Reporter Error: \(error)")
        errorDelegate?.handleDivKitError(error, cardId: cardId)
    }
    
    func reportAction(cardId: DivCardID, info: DivActionInfo) {
        
    }
    
    // Override any method that would show error UI
    func shouldDisplayError() -> Bool {
        return false // Prevent display
    }
}

protocol DivKitErrorDelegate: AnyObject {
    func handleDivKitError(_ error: any DivError, cardId: DivCardID)
}
