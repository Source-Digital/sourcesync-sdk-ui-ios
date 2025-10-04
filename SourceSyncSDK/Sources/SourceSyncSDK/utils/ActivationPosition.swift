//
//  ActivationPosition.swift
//  
//
//  Created by ayman badawy on 25/09/2025.
//
public struct ActivationPosition {
    let screenWidth: CGFloat
    let screenHeight: CGFloat
    let alignment: Alignment
    
    public init(screenWidth: CGFloat, screenHeight: CGFloat, alignment: Alignment) {
        self.screenWidth = screenWidth
        self.screenHeight = screenHeight
        self.alignment = alignment
    }
}
