//
//  WordEntry.swift
//  Citizen
//
//  Created by GE-Developer
//

struct WordEntry: Decodable, Hashable, Identifiable {
    let partOfSpeech: String
    let word: String
    let transliteration: String
    let translation: String?
    
    var key: String = ""
    var isSaved: Bool = false
    
    var id: String {
        key
    }
    
    enum CodingKeys: String, CodingKey {
        case partOfSpeech, word, transliteration, translation
    }
}
