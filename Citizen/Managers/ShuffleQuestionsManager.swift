//
//  ShuffleQuestionsManager.swift
//  Citizen
//
//  Created by GE-Developer
//

import Foundation

@MainActor
final class ShuffleQuestionsManager {
    var isShuffleQuestionsOn: Bool {
        didSet { defaults.set(isShuffleQuestionsOn, forKey: key) }
    }
    
    static let shared = ShuffleQuestionsManager()
    
    private let defaults = UserDefaults.standard
    private let key = AppStorageKey.shuffleQuestions.key
    
    private init() {
        isShuffleQuestionsOn = defaults.object(forKey: key) as? Bool ?? true
    }
    
    func reset() {
        isShuffleQuestionsOn = true
    }
}
