//
//  ScreenshotManager.swift
//  Citizen
//
//  Created by GE-Developer
//

import Foundation

@MainActor
@Observable
final class ScreenshotManager {
    var isScreenshotProtectionOn: Bool {
        didSet { defaults.set(isScreenshotProtectionOn, forKey: key) }
    }
    
    static let shared = ScreenshotManager()
    
    private let defaults = UserDefaults.standard
    private let key = AppStorageKey.screenshotProtection.key
    
    private init() {
        isScreenshotProtectionOn = defaults.object(forKey: key) as? Bool ?? true
    }
    
    func reset() {
        isScreenshotProtectionOn = true
    }
}
