//
//  WordOccurrenceIndex.swift
//  Citizen
//
//  Created by GE-Developer
//

import Foundation

@MainActor
final class WordOccurrenceIndex {
    private var index: [String: [Question]]?
    private var buildTask: Task<[String: [Question]], Never>?
    private var generation = 0
    
    static let shared = WordOccurrenceIndex()
    
    private let repository = QuizRepository.shared
    private let dictionary = WordsDictionary.shared
    
    private init() {}
    
    func prewarm() async {
        if index != nil { return }
        
        if buildTask == nil {
            let questions = repository.catalog.categories
                .flatMap(\.topics)
                .flatMap(\.questions)
            let dictKeys = dictionary.keysSnapshot
            let maxWindow = dictionary.maxPhraseWordCount
            
            buildTask = Task.detached(priority: .userInitiated) {
                Self.build(
                    questions: questions,
                    dictKeys: dictKeys,
                    maxWindow: maxWindow
                )
            }
        }
        
        guard let task = buildTask else { return }
        
        let startedGeneration = generation
        let built = await task.value
        
        guard startedGeneration == generation else { return }
        
        index = built
        buildTask = nil
    }
    
    func questions(for key: String) -> [Question] {
        (index ?? [:])[WordsDictionary.normalize(key)] ?? []
    }
    
    func count(for key: String) -> Int {
        questions(for: key).count
    }
    
    func reload() {
        index = nil
        buildTask?.cancel()
        buildTask = nil
        generation += 1
    }
    
    private nonisolated static func build(questions: [Question], dictKeys: Set<String>, maxWindow: Int) -> [String: [Question]] {
        var result: [String: [Question]] = [:]
        var seen: [String: Set<String>] = [:]
        
        for question in questions {
            let fields = [question.question, question.additionalText].compactMap { $0 }
            + question.answers.map(\.text)
            
            var keysInQuestion: Set<String> = []
            for field in fields {
                collectKeys(
                    from: field,
                    dictKeys: dictKeys,
                    maxWindow: maxWindow,
                    into: &keysInQuestion
                )
            }
            
            for key in keysInQuestion where seen[key, default: []].insert(question.id).inserted {
                result[key, default: []].append(question)
            }
        }
        
        return result
    }
    
    private nonisolated static func collectKeys(from text: String, dictKeys: Set<String>, maxWindow: Int, into keys: inout Set<String>) {
        
        var tokens: [String] = []
        
        text.enumerateSubstrings(in: text.startIndex..<text.endIndex, options: .byWords) { word, _, _, _ in
            guard let word else { return }
            
            let norm = WordsDictionary.normalize(word)
            if !norm.isEmpty {
                tokens.append(norm)
            }
        }
        
        for i in tokens.indices {
            if dictKeys.contains(tokens[i]) {
                keys.insert(tokens[i])
            }
            
            guard maxWindow > 1 else { continue }
            
            var phrase = tokens[i]
            var n = 2
            
            while n <= maxWindow, i + n - 1 < tokens.count {
                phrase += " " + tokens[i + n - 1]
                
                if dictKeys.contains(phrase) {
                    keys.insert(phrase)
                }
                
                n += 1
            }
        }
    }
}
