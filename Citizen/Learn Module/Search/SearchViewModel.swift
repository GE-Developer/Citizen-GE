//
//  SearchViewModel.swift
//  Citizen
//
//  Created by GE-Developer
//

import Foundation

// MARK: - SearchEntry
private struct SearchEntry {
    let row: OccurrenceRow
    let haystack: String
}

@MainActor
@Observable
final class SearchViewModel {
    var searchText = ""
    var selectedFilter: Filter = .all
    var selectedQuestion: Question?
    
    var visibleRows: [OccurrenceRow] {
        guard !trimmedQuery.isEmpty else { return [] }
        
        return entries
            .filter { $0.haystack.localizedCaseInsensitiveContains(trimmedQuery) }
            .map(\.row)
            .filtered(by: selectedFilter)
    }
    
    var showNoResults: Bool {
        !trimmedQuery.isEmpty && visibleRows.isEmpty
    }
    
    var showPlaceholder: Bool {
        trimmedQuery.isEmpty
    }
    
    var questionsCountText: String {
        "\(visibleRows.count)"
    }
    
    var questionsCountSuffix: String {
        L10n("\(visibleRows.count) Saved.questionCountSuffix")
    }
    
    private(set) var availableFilters: [Filter] = [.all]
    
    private var entries: [SearchEntry] = []
    
    private var trimmedQuery: String {
        searchText.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    let title = L10n("Main.Search.title")
    let searchPlaceholder = L10n("Dictionary.searchPlaceholder")
    let noResultsText = L10n("Dictionary.noResultsText")
    let emptyTitle = L10n("Search.emptyTitle")
    let emptyMessage = L10n("Search.emptyMessage")
    
    private let repository = QuizRepository.shared
    private let haptics = HapticsManager.shared
    
    func load() {
        guard entries.isEmpty else { return }
        
        let rows = repository.catalog.categories
            .flatMap(\.topics)
            .flatMap(\.questions)
            .map { repository.occurrenceRow(for: $0) }
        
        entries = rows.map { row in
            SearchEntry(
                row: row,
                haystack: repository.searchHaystack(forID: row.id)
            )
        }
        
        availableFilters = rows.categoryFilters
    }
    
    func select(_ row: OccurrenceRow) {
        haptics.impact()
        selectedQuestion = row.question
    }
    
    func clearSearchText() {
        searchText = ""
    }
}
