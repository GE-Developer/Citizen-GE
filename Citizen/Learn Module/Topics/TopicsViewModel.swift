//
//  TopicsViewModel.swift
//  Citizen
//
//  Created by GE-Developer
//

import Foundation

@MainActor
final class TopicsViewModel: ObservableObject {
    @Published var chosenTopic: Topic?
    
    var topics: [Topic] {
        category?.topics ?? []
    }
    
    private var category: Category? {
        repository.catalog.categories.first { $0.id == categoryID }
    }
    
    let title = L10n("Topics.title")
    let subtitle: String
    
    private let categoryID: String
    private let repository = QuizRepository.shared
    private let haptics = HapticsManager.shared

    init(category: Category) {
        categoryID = category.id
        subtitle = category.name
    }
    
    func numberFor(_ topic: Topic) -> String {
        String(format: "%02d", topic.index)
    }
    
    func pillText(for topic: Topic) -> String? {
        topic.phase.pillText(
            answered: topic.answeredCount,
            total: topic.totalCount,
            wrong: topic.wrongCount
        )
    }
    
    func choose(_ topic: Topic) {
        haptics.impact()
        chosenTopic = topic
    }
}
