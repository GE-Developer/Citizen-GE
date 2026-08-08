//
//  AlphabetLetter.swift
//  Citizen
//
//  Created by GE-Developer
//

struct AlphabetLetter: Decodable, Identifiable, Hashable {
    let id: Int
    let character: String
    let transliteration: String
    let letterAudio: String
    let exampleImage: String
    let exampleWord: String
    let exampleWordTransliteration: String
    let exampleAudio: String
}
