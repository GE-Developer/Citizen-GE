//
//  Array + Ext.swift
//  Citizen
//
//  Created by GE-Developer
//

import Foundation

// MARK: - RichTextSegment
extension Array where Element == RichTextSegment {
    @MainActor
    func mergingDictionaryPhrases() -> [RichTextSegment] {
        let maxWindow = WordsDictionary.shared.maxPhraseWordCount
        
        guard maxWindow > 1 else { return self }
        
        var result: [RichTextSegment] = []
        var i = 0
        while i < count {
            guard case .word = self[i] else {
                result.append(self[i])
                i += 1
                continue
            }
            
            var window = 1
            
            while window < maxWindow,
                  i + window < count,
                  case .word = self[i + window] {
                window += 1
            }
            
            var merged = false
            var n = window
            
            while n >= 2 {
                let candidate = (0..<n)
                    .map { plainText(of: self[i + $0]) }
                    .joined(separator: " ")
                if WordsDictionary.shared.contains(candidate) {
                    var phrase = AttributedString()
                    for k in 0..<n {
                        if case .word(let attr) = self[i + k] { phrase.append(attr) }
                    }
                    result.append(.word(phrase))
                    i += n
                    merged = true
                    break
                }
                n -= 1
            }
            
            if !merged {
                result.append(self[i])
                i += 1
            }
        }
        return result
    }
    
    private func plainText(of segment: RichTextSegment) -> String {
        guard case .word(let attr) = segment else { return "" }
        return attr.plainToken
    }
}

// MARK: - OccurrenceRow
extension Array where Element == OccurrenceRow {
    var categoryFilters: [Filter] {
        var seen = Set<String>()
        var categories: [String] = []
        
        for row in self {
            let category = row.categoryName
            
            guard !category.isEmpty else { continue }
            guard seen.insert(category).inserted else { continue }
            
            categories.append(category)
        }
        
        return [.all] + categories.map(Filter.named)
    }
    
    func filtered(by filter: Filter) -> [OccurrenceRow] {
        switch filter {
        case .all:
            return self
        case .named(let category):
            return self.filter { $0.categoryName == category }
        }
    }
}
