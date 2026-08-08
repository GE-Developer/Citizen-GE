//
//  StyleViewModel.swift
//  Citizen
//
//  Created by GE-Developer
//

@MainActor
struct StyleViewModel {
    let colorCases = AccentColor.allCases

    let title = L10n("Settings.Customization.Style.title")
    let headerText = L10n("Settings.Customization.Style.headerTitle")

    private let styleManager = AccentColorManager.shared
    private let haptic = HapticsManager.shared

    func changeAccent(to colorCase: AccentColor) {
        haptic.impact(style: .rigid)
        styleManager.currentColor = colorCase
    }

    func isCurrent(_ colorCase: AccentColor) -> Bool {
        styleManager.currentColor == colorCase
    }
}
