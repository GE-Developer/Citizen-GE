//
//  Sound.swift
//  Citizen
//
//  Created by GE-Developer
//

enum Sound {
    case devMode
    case errorAlert
    
    var name: String {
        switch self {
        case .devMode: return "Dev_Mode"
        case .errorAlert: return "Error_Alert"
        }
    }
}
