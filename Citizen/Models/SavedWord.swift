//
//  SavedWord.swift
//  Citizen
//
//  Created by GE-Developer
//

struct SavedWord: Identifiable, Hashable {
    let entry: WordEntry
    let keys: [String]
    
    var id: String {
        entry.word
    }
    
    var savedAsKeys: [String] {
        keys.filter { $0 != entry.word }
    }
    
    var searchableText: String {
        (keys + [entry.word, entry.transliteration, entry.translation].compactMap { $0 })
            .joined(separator: " ")
    }
}
