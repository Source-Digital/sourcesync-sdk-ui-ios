//
//  TemplateLoader.swift
//  MobileDemo
//
//  Created by ayman badawy on 20/03/2025.
//

import Foundation
import UIKit

// Helper class to load templates from text files
class TemplateLoader {
    
    // Load a template from a text file in the main bundle
    // - Parameter fileName: Name of the file without extension
    // - Returns: A dictionary representation of the JSON template, or nil if loading fails
    

    
    static func loadTemplate(fileName: String) -> [String: Any]? {
        
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "json") else {
            print("⚠️ Could not find template file: \(fileName).json")
            return nil
        }
    
        
        do {
            let data = try Data(contentsOf: url)
            guard let jsonObject = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                print("⚠️ Could not parse template file as dictionary: \(fileName).json")
                return nil
            }
            return jsonObject
        } catch {
            print("⚠️ Error loading template file \(fileName).json: \(error.localizedDescription)")
            return nil
        }
    }
    

}
