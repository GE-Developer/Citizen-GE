//
//  AccentColor.swift
//  Citizen
//
//  Created by GE-Developer
//

import SwiftUI

enum AccentColor: String, CaseIterable, Identifiable {
    case georgian
    case midnightBlue
    case solarFlare
    case neonLime
    case victoria
    case caramelRoast
    case arcticCyan
    case cosmicPurple
    
    var id: String { rawValue }
    
    var name: String {
        switch self {
        case .georgian: "Georgian"
        case .midnightBlue: "Midnight Blue"
        case .solarFlare: "Solar Flare"
        case .neonLime: "Neon Lime"
        case .victoria: "Victoria"
        case .caramelRoast: "Caramel Roast"
        case .arcticCyan: "Arctic Cyan"
        case .cosmicPurple: "Cosmic Purple"
        }
    }
    
    var color: Color {
        Color("\(name) (Accent)")
    }
    
    var gradient: LinearGradient {
        let colors = self == .georgian
        ? [color, gradientColor]
        : [gradientColor, color]
        return LinearGradient(colors: colors, startPoint: .leading, endPoint: .trailing)
    }
    
    var requiresPremium: Bool {
        self != .georgian
    }
    
    private var gradientColor: Color {
        Color("\(name) (Accent Gradient)")
    }
}
