//
//  Gradient + Ext.swift
//  Citizen
//
//  Created by GE-Developer
//

import SwiftUI

extension Gradient {
    @MainActor
    static var accent: LinearGradient {
        AccentColorManager.shared.currentColor.gradient
    }
    
    static let gray = LinearGradient(
        colors: [.citizen.grayLight, .citizen.grayDark],
        startPoint: .leading,
        endPoint: .trailing
    )
    
    static let secondaryText = LinearGradient(
        colors: [.citizen.secondaryText],
        startPoint: .leading,
        endPoint: .trailing
    )
    
    static let gold = LinearGradient(
        colors: [.citizen.goldLight, .citizen.goldDark],
        startPoint: .leading,
        endPoint: .trailing
    )
    
    static let green = LinearGradient(
        colors: [.citizen.greenLight, .citizen.greenDark],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let yellow = LinearGradient(
        colors: [.citizen.yellowLight, .citizen.yellowDark],
        startPoint: .leading,
        endPoint: .trailing
    )
    
    static let red = LinearGradient(
        colors: [.citizen.redLight, .citizen.redDark],
        startPoint: .leading,
        endPoint: .trailing
    )
    
    static let neutral = LinearGradient(
        colors: [.citizen.groupBackground],
        startPoint: .leading,
        endPoint: .trailing
    )
}
