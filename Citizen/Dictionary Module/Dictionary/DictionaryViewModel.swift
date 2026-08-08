//
//  DictionaryViewModel.swift
//  Citizen
//
//  Created by GE-Developer
//

import Foundation

@MainActor
@Observable
final class DictionaryViewModel {
    var selectedFilter: Filter = .all
    var selectedSort: SortOrder = .recent
    var searchText = ""
    var selectedOccurrenceWord: SavedWord?
    var showAlphabet = false
    
    var availableFilters: [Filter] {
        [.all] + dictionary.partsOfSpeech.map(Filter.named)
    }
    
    var displayedWords: [SavedWord] {
        let filtered = words.filter { matchesFilter($0) && matchesSearch($0) }
        switch selectedSort {
        case .recent:
            return filtered
        case .alphabetical:
            return filtered.sorted {
                $0.entry.word.localizedStandardCompare($1.entry.word) == .orderedAscending
            }
        }
    }
    
    var isEmpty: Bool {
        words.isEmpty
    }
    
    var wordsCountText: String {
        "\(words.count)"
    }
    
    var voiceActingOn: Bool {
        VoiceActingManager.shared.isVoiceActingOn
    }
    
    var title: String {
        L10n("Dictionary.title")
    }
    
    var alphabetTitle: String {
        L10n("Alphabet.title")
    }
    
    var alphabetSubtitle: String {
        L10n("\(33) Dictionary.Alphabet.lettersCount")
    }
    
    var wordsSavedSuffix: String {
        L10n("\(words.count) Dictionary.wordsCountSuffix")
    }
    
    var searchPlaceholder: String {
        L10n("Dictionary.searchPlaceholder")
    }
    
    var savedAsLabel: String {
        L10n("Dictionary.savedAsLabel")
    }

    var removeActionTitle: String {
        L10n("Dictionary.removeActionTitle")
    }
    
    var noResultsText: String {
        L10n("Dictionary.noResultsText")
    }
    
    var emptyTitle: String {
        L10n("Dictionary.emptyTitle")
    }
    
    var emptyMessage: String {
        L10n("Dictionary.emptyMessage")
    }
    
    private(set) var isLoading = true
    
    private var words: [SavedWord] = []
    private var occurrenceCounts: [String: Int] = [:]
    
    let alphabetIconLetter = "ა"
    
    private let store = SavedWordsStore.shared
    private let dictionary = WordsDictionary.shared
    private let occurrences = WordOccurrenceIndex.shared
    private let hapticsManager = HapticsManager.shared
    
    func load() async {
        isLoading = true
        words = fetchSavedWords()
        await occurrences.prewarm()
        occurrenceCounts = countOccurrences(for: words)
        resetFilterIfUnavailable()
        isLoading = false
    }
    
    func remove(_ word: SavedWord) {
        hapticsManager.impact(style: .rigid)
        store.remove(word.keys)
        words.removeAll { $0.id == word.id }
    }
    
    func openAlphabet() {
        hapticsManager.impact()
        showAlphabet = true
    }
    
    func showOccurrences(_ word: SavedWord) {
        hapticsManager.impact()
        selectedOccurrenceWord = word
    }
    
    func clearSearchText() {
        searchText = ""
    }
    
    func occurrenceCount(for word: SavedWord) -> Int {
        occurrenceCounts[word.id] ?? 0
    }
    
    func transliteration(_ value: String) -> String {
        "[\(value)]"
    }
    
    private func fetchSavedWords() -> [SavedWord] {
        var entries: [String: WordEntry] = [:]
        var keysByWord: [String: [String]] = [:]
        var order: [String] = []

        for key in store.fetchAll() {
            guard var entry = dictionary.entry(for: key) else { continue }
            entry.isSaved = true
            if entries[entry.word] == nil {
                entries[entry.word] = entry
                order.append(entry.word)
            }
            keysByWord[entry.word, default: []].append(key)
        }

        return order.compactMap { word in
            entries[word].map { SavedWord(entry: $0, keys: keysByWord[word] ?? []) }
        }
    }

    private func countOccurrences(for words: [SavedWord]) -> [String: Int] {
        Dictionary(
            words.map { word in
                (word.id, Set(word.keys.flatMap { occurrences.questions(for: $0).map(\.id) }).count)
            },
            uniquingKeysWith: { first, _ in first }
        )
    }
    
    private func resetFilterIfUnavailable() {
        if !availableFilters.contains(selectedFilter) {
            selectedFilter = .all
        }
    }
    
    private func matchesFilter(_ word: SavedWord) -> Bool {
        switch selectedFilter {
        case .all:            return true
        case .named(let pos): return word.entry.partOfSpeech == pos
        }
    }

    private func matchesSearch(_ word: SavedWord) -> Bool {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return true }
        return word.searchableText.localizedCaseInsensitiveContains(query)
    }
}
