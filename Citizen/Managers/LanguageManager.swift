//
//  LanguageManager.swift
//  Citizen
//
//  Created by GE-Developer
//

import Foundation

@MainActor
@Observable
final class LanguageManager {
    var currentLanguageID: String {
        didSet {
            defaults.set([currentLanguageID], forKey: key)
            cachedBundle = Self.makeBundle(for: currentLanguageID)
        }
    }
    
    var bundle: Bundle? {
        cachedBundle
    }
    
    private var cachedBundle: Bundle?
    
    static let shared = LanguageManager()
    
    private let defaults = UserDefaults.standard
    private let key = AppStorageKey.language.key
    
    private init() {
        let baseAppLanguage = Bundle.main.developmentLocalization ?? Language.english.id
        let baseUserLanguage = Bundle.main.preferredLocalizations.first
        
        currentLanguageID = baseUserLanguage ?? baseAppLanguage
        cachedBundle = Self.makeBundle(for: currentLanguageID)
    }
    
    func reset() {
        let baseAppLanguage = Bundle.main.developmentLocalization ?? Language.english.id
        let baseUserLanguage = Bundle.main.preferredLocalizations.first
        
        currentLanguageID = baseUserLanguage ?? baseAppLanguage
    }
    
    private static func makeBundle(for languageID: String) -> Bundle? {
        guard let path = Bundle.main.path(
            forResource: languageID,
            ofType: "lproj"
        ) else {
            return .main
        }
        return Bundle(path: path)
    }
}
