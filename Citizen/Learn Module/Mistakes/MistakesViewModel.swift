//
//  MistakesViewModel.swift
//  Citizen
//
//  Created by GE-Developer
//

import Foundation

@MainActor
@Observable
final class MistakesViewModel {
    var selectedQuestion: Question?
    var selectedFilter: Filter = .all
    var showPractice = false
    
    var visibleRows: [OccurrenceRow] {
        rows.filtered(by: selectedFilter)
    }
    
    var availableFilters: [Filter] {
        rows.categoryFilters
    }
    
    var isEmpty: Bool {
        rows.isEmpty
    }
    
    var questionsCountText: String {
        "\(rows.count)"
    }
    
    var questionsCountSuffix: String {
        L10n("\(rows.count) Saved.questionCountSuffix")
    }
    
    var practiceFilterDetail: String {
        selectedFilter.title
    }
    
    var practiceHeaderTitle: String {
        selectedFilter == .all ? title : "\(title) - \(selectedFilter.title)"
    }
    
    private(set) var rows: [OccurrenceRow] = []
    private(set) var practiceQuestions: [Question] = []
    
    let title = L10n("Main.Mistakes.title")
    let practiceTitle = L10n("Saved.Practice.title")
    let emptyTitle = L10n("Mistakes.Empty.title")
    let emptyMessage = L10n("Mistakes.Empty.message")
    
    private let practiceBatchSize = 10
    private let repository = QuizRepository.shared
    private let haptics = HapticsManager.shared
    private let shuffleQuestionsManager = ShuffleQuestionsManager.shared
    
    init() {
        refresh()
    }
    
    func refresh() {
        rows = repository.catalog.mistakePoolQuestions
            .map { repository.occurrenceRow(for: $0) }
        
        if !availableFilters.contains(selectedFilter) {
            selectedFilter = .all
        }
    }
    
    func select(_ row: OccurrenceRow) {
        haptics.impact()
        selectedQuestion = row.question
    }
    
    func canPractice(isPremium: Bool) -> Bool {
        practiceBatchCount(isPremium: isPremium) > 0
    }
    
    func practiceSubtitle(isPremium: Bool) -> String? {
        let count = practiceBatchCount(isPremium: isPremium)
        return count == 0 ? nil : L10n("\(count) Mistakes.Practice.subtitle")
    }
    
    func practicePressed(isPremium: Bool) {
        haptics.impact()
        
        let eligible = visibleRows
            .filter { isPremium || !$0.isPremium }
            .map(\.question)
        
        guard !eligible.isEmpty else { return }
        
        let ordered = shuffleQuestionsManager.isShuffleQuestionsOn
        ? eligible.shuffled()
        : eligible
        
        practiceQuestions = Array(ordered.prefix(practiceBatchSize))
        showPractice = true
    }
    
    private func practiceBatchCount(isPremium: Bool) -> Int {
        let eligible = visibleRows.filter { isPremium || !$0.isPremium }.count
        return min(eligible, practiceBatchSize)
    }
}
