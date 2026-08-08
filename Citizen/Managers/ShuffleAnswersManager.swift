//
//  ShuffleAnswersManager.swift
//  Citizen
//
//  Created by GE-Developer
//

import Foundation

@MainActor
final class ShuffleAnswersManager {
    var isShuffleAnswersOn: Bool {
        didSet { defaults.set(isShuffleAnswersOn, forKey: key) }
    }
    
    static let shared = ShuffleAnswersManager()
    
    private let defaults = UserDefaults.standard
    private let key = AppStorageKey.shuffleAnswers.key
    
    private init() {
        isShuffleAnswersOn = defaults.object(forKey: key) as? Bool ?? false
    }
    
    func reset() {
        isShuffleAnswersOn = false
    }
}
