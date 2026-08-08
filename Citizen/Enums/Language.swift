//
//  Language.swift
//  Citizen
//
//  Created by GE-Developer
//

enum Language: String, CaseIterable, Identifiable {
    case english = "en"
    case georgian = "ka"
    case russian = "ru"
    
    static let rtlLanguages: Set<String> = ["ar", "he", "fa", "ur"]
    
    var id: String { rawValue }
    
    var localizedName: String {
        switch self {
        case .english: return "English"
        case .georgian: return "ქართული"
        case .russian: return "Русский"
        }
    }
    
    var englishName: String {
        switch self {
        case .english: return "English"
        case .georgian: return "Georgian"
        case .russian: return "Russian"
        }
    }
}
