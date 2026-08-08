//
//  ThemeManager.swift
//  Citizen
//
//  Created by GE-Developer
//

import SwiftUI

@MainActor
@Observable
final class ThemeManager {
    var isDarkMode: Bool {
        didSet { defaults.set(isDarkMode, forKey: key) }
    }
    
    var theme: ColorScheme {
        isDarkMode ? .dark : .light
    }
    
    static let shared = ThemeManager()
    
    private let defaults = UserDefaults.standard
    private let key = AppStorageKey.theme.key
    
    private init() {
        isDarkMode = defaults.object(forKey: key) as? Bool ?? true
    }
    
    func reset() {
        isDarkMode = true
    }
}
