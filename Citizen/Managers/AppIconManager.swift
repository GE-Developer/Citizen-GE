//
//  AppIconManager.swift
//  Citizen
//
//  Created by GE-Developer
//

import UIKit

@MainActor
final class AppIconManager {
    static private var supportsAlternateIcons: Bool {
        UIApplication.shared.supportsAlternateIcons
    }
    
    static func currentIcon() -> AppIcon {
        let currentName = UIApplication.shared.alternateIconName
        return AppIcon.allCases.first { $0.appIconID == currentName } ?? .georgianBlack
    }
    
    static func setIcon(_ icon: AppIcon) async throws {
        guard supportsAlternateIcons else { return }
        try await UIApplication.shared.setAlternateIconName(icon.appIconID)
    }
    
    static func reset() async throws {
        try await setIcon(.georgianBlack)
    }
}
