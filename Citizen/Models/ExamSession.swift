//
//  ExamSession.swift
//  Citizen
//
//  Created by GE-Developer
//

import Foundation

// MARK: - ExamSession
struct ExamSession: Identifiable, Hashable {
    var sections: [ExamSection]
    
    var questionTotal: Int {
        sections.reduce(0) { $0 + $1.totalCount }
    }
    
    var correctTotal: Int {
        sections.reduce(0) { $0 + $1.correctCount }
    }
    
    var isPassed: Bool {
        sections.allSatisfy(\.isPassed)
    }
    
    let id = UUID()
    let mode: ExamMode
    
    init?(mode: ExamMode, catalog: QuestionCatalog) {
        let ordered = catalog.categories.sorted { $0.index < $1.index }
        
        let chosen: [Category]
        
        switch mode {
        case .full:
            chosen = ordered
        case .single(let categoryID):
            guard let category = ordered.first(where: { $0.id == categoryID }) else {
                return nil
            }
            chosen = [category]
        }
        
        let built = chosen.compactMap(ExamSection.init)
        guard !built.isEmpty, built.count == chosen.count else { return nil }
        
        self.mode = mode
        sections = built
    }
}

// MARK: - ExamMode
enum ExamMode: Hashable {
    case full
    case single(categoryID: String)
}

// MARK: - ExamSection
struct ExamSection: Identifiable, Hashable {
    var items: [ExamSectionItem]
    var isFinished = false
    
    var totalCount: Int {
        items.count
    }
    
    var requiredCorrect: Int {
        ExamConfig.requiredCorrect(of: items.count)
    }
    
    var correctCount: Int {
        items.count { $0.isCorrect }
    }
    
    var answeredCount: Int {
        items.count { $0.isAnswered }
    }
    
    var isPassed: Bool {
        correctCount >= requiredCorrect
    }
    
    var wrongAnsweredQuestionIDs: [String] {
        items
            .filter { $0.isAnswered && !$0.isCorrect }
            .map(\.id)
    }
    
    var id: String {
        categoryID
    }
    
    let categoryID: String
    let categoryName: String
    
    init?(category: Category) {
        let pool = category.topics.flatMap(\.questions)
        guard !pool.isEmpty else { return nil }
        
        let sampled = pool
            .shuffled()
            .prefix(ExamConfig.sampleCount(available: pool.count))
        
        categoryID = category.id
        categoryName = category.name
        items = sampled.map(ExamSectionItem.init)
    }
}

// MARK: - ExamSectionItem
struct ExamSectionItem: Identifiable, Hashable {
    var chosenAnswerID: Answer.ID?
    
    var isAnswered: Bool {
        chosenAnswerID != nil
    }
    
    var chosenAnswer: Answer? {
        shuffledAnswers.first { $0.id == chosenAnswerID }
    }
    
    var isCorrect: Bool {
        chosenAnswer?.isCorrect ?? false
    }
    
    var id: String {
        question.id
    }
    
    let question: Question
    let shuffledAnswers: [Answer]
    
    init(question: Question) {
        var copy = question
        copy.status = .unanswered
        copy.isInMistakePool = false
        
        self.question = copy
        shuffledAnswers = copy.answers.shuffled()
    }
}
