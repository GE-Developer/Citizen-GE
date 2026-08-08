//
//  AppIcon.swift
//  Citizen
//
//  Created by GE-Developer
//

enum AppIcon: CaseIterable, Identifiable {
    case georgianBlack
    case georgianWhite
    case fresh
    case gold
    
    var id: String {
        appIconID ?? "GeorgianBlack"
    }
    
    var appIconID: String? {
        switch self {
        case .georgianBlack:
            return nil
        case .georgianWhite:
            return "GeorgianWhite"
        case .fresh:
            return "Fresh"
        case .gold:
            return "Gold"
        }
    }
    
    var title: String {
        switch self {
        case .georgianBlack:
            return "Georgian Black"
        case .georgianWhite:
            return "Georgian White"
        case .fresh:
            return "Fresh"
        case .gold:
            return "Gold"
        }
    }
    
    static var premiumIcons: [AppIcon] {
        allCases.filter { $0 != .georgianBlack }
    }
}
