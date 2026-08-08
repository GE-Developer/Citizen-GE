//
//  AppIconViewModel.swift
//  Citizen
//
//  Created by GE-Developer
//

import Foundation

@MainActor
final class AppIconViewModel: ObservableObject {
    @Published private(set) var currentIcon = AppIconManager.currentIcon()
    
    let title = L10n("Settings.Customization.AppIcon.title")
    let defaultFormTitle = L10n("Settings.Customization.AppIcon.defaultIconTitle")
    let alternativeFormTitle = L10n("Settings.Customization.AppIcon.alternativeIconTitle")
    
    let defaulIcon = AppIcon.georgianBlack
    let alternativeIcons = AppIcon.premiumIcons
    
    private let haptic = HapticsManager.shared
    
    @MainActor
    func selectIcon(_ icon: AppIcon) {
        guard currentIcon != icon else { return }
        let recentIcon = currentIcon
        
        currentIcon = icon
        haptic.impact(style: .rigid)
        
        Task {
            do {
                try await AppIconManager.setIcon(icon)
            } catch {
                currentIcon = recentIcon
            }
        }
    }
    
    func isCurrent(_ icon: AppIcon) -> Bool {
        currentIcon == icon
    }
}
