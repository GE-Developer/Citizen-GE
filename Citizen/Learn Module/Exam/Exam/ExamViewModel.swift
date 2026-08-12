//
//  ExamViewModel.swift
//  Citizen
//
//  Created by GE-Developer
//

import Foundation

@MainActor
@Observable
final class ExamViewModel {
    var activeSession: ExamSession?
    var showRules = false
    var showHistory = false
    
    var questionsValue: String {
        "\(ExamConfig.totalQuestions(sections: categories.count))"
    }
    
    var limitValue: String {
        L10n("\(ExamConfig.fullMinutes(sections: categories.count)) Main.Exam.preview")
    }
    
    var thresholdValue: String {
        let sections = categories.count
        let required = ExamConfig.requiredCorrectTotal(sections: sections)
        
        return "\(required)/\(ExamConfig.totalQuestions(sections: sections))"
    }
    
    var sectionsCaption: String {
        let count = ExamConfig.questionsPerSection
        let questions = L10n("\(count) Saved.questionCountSuffix").lowercased()
        let duration = L10n("\(ExamConfig.sectionMinutes) Main.Exam.preview")
        
        return "\(count) \(questions) · \(duration)"
    }
    
    var sectionRows: [ExamSectionSummary] {
        categories.map { category in
            ExamSectionSummary(id: category.id, title: category.name)
        }
    }
    
    private var categories: [Category] {
        repository.catalog.categories.sorted { $0.index < $1.index }
    }
    
    let title = L10n("Main.Exam.title")
    let fullExamTitle = L10n("Exam.FullExam.title")
    let fullExamSubtitle = L10n("Exam.FullExam.subtitle")
    let startButtonTitle = L10n("Exam.FullExam.start")
    let questionsCaption = L10n("Exam.Hero.questions")
    let limitCaption = L10n("Exam.Hero.limit")
    let thresholdCaption = L10n("Exam.Hero.threshold")
    let sectionsTitle = L10n("Exam.Sections.title")
    
    private let repository = QuizRepository.shared
    private let haptics = HapticsManager.shared
    
    init() {}
    
    func rulesButtonPressed() {
        haptics.impact()
        showRules = true
    }
    
    func historyButtonPressed() {
        haptics.impact()
        showHistory = true
    }
    
    func startFullExam() {
        haptics.impact()
        activeSession = ExamSession(mode: .full, catalog: repository.catalog)
    }
    
    func startSectionExam(id: String) {
        haptics.impact()
        activeSession = ExamSession(
            mode: .single(categoryID: id),
            catalog: repository.catalog
        )
    }
}

// MARK: - ExamSectionSummary
struct ExamSectionSummary: Identifiable {
    let id: String
    let title: String
}
