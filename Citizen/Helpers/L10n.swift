//
//  L10n.swift
//  Citizen
//
//  Created by GE-Developer
//

import Foundation

@MainActor
public func L10n(_ key: String.LocalizationValue) -> String {
    String(localized: key, bundle: LanguageManager.shared.bundle)
}
