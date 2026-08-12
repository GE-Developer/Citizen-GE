//
//  ExamMistakesViewModel.swift
//  Citizen
//
//  Created by GE-Developer
//

import Foundation

@MainActor
@Observable
final class ExamMistakesViewModel {
    var selectedQuestion: Question?

    var isEmpty: Bool {
        rows.isEmpty
    }

    var questionsCountText: String {
        "\(rows.count)"
    }

    var questionsCountSuffix: String {
        L10n("\(rows.count) Saved.questionCountSuffix")
    }

    private(set) var rows: [OccurrenceRow] = []

    let title = L10n("Exam.History.mistakesTitle")
    let subtitle: String
    let emptyTitle = L10n("Exam.History.Empty.title")
    let emptyMessage = L10n("Exam.History.Empty.message")

    private let questionIDs: [String]
    private let repository = QuizRepository.shared
    private let haptics = HapticsManager.shared

    init(route: ExamMistakesRoute) {
        subtitle = route.title
        questionIDs = route.questionIDs
        refresh()
    }

    func refresh() {
        rows = questionIDs
            .compactMap { repository.question(byID: $0) }
            .map { repository.occurrenceRow(for: $0) }
    }

    func select(_ row: OccurrenceRow) {
        haptics.impact()
        selectedQuestion = row.question
    }
}
