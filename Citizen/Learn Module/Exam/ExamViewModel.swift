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
    struct ExamOption: Identifiable {
        let id: String
        let title: String
        let subtitle: String
    }
    
    var subjects: [ExamOption] {
        repository.catalog.categories.map { category in
            ExamOption(
                id: category.id,
                title: category.name,
                subtitle: L10n("\(ExamConfig.subjectDurationMin) Main.Exam.preview")
            )
        }
    }
    
    var fullExamSubtitle: String {
        let questions = L10n("\(ExamConfig.totalQuestions) Saved.questionCountSuffix")
        let duration = L10n("\(ExamConfig.fullDurationMin) Main.Exam.preview")
        return "\(ExamConfig.totalQuestions) \(questions) · \(duration)"
    }
    
    let title = L10n("Main.Exam.title")
    let fullExamTitle = L10n("Exam.FullExam.title")
    let subjectQuestionsCount = "\(ExamConfig.questionsPerSubject)"
    
    private let repository = QuizRepository.shared
    private let haptics = HapticsManager.shared
    
    init() {}
    
    func startFullExam() {
        haptics.impact()
        // TODO: launch the full exam engine (question sampling, timer, per-category scoring).
    }
    
    func startSubjectExam(id: String) {
        haptics.impact()
        // TODO: launch the single-subject exam for the given category id.
    }
}
