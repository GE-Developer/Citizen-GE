//
//  AccentColorManager.swift
//  Citizen
//
//  Created by GE-Developer
//

import Foundation

@MainActor
@Observable
final class AccentColorManager {
    var currentColor: AccentColor {
        didSet {
            defaults.set(currentColor.id, forKey: key)
        }
    }
    
    static let shared = AccentColorManager()
    
    private let defaults = UserDefaults.standard
    private let key = AppStorageKey.accentColor.key
    
    private init() {
        let savedValue = defaults.string(forKey: key)
        currentColor = AccentColor(rawValue: savedValue ?? "") ?? .georgian
    }
    
    func reset() {
        currentColor = .georgian
    }
}
