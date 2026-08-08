//
//  MainViewModel.swift
//  Citizen
//
//  Created by GE-Developer
//

import Foundation

enum MainDestination: Hashable {
    case exam
    case leaderboard
    case contacts
    case mistakes
    case refresh
    case saved
    case search
}

@MainActor
final class MainViewModel: ObservableObject {
    @Published var chosenCategory: Category?
    @Published var destination: MainDestination?
    
    var catalog: QuestionCatalog {
        repository.catalog
    }
    
    var greetingKicker: String {
        switch Calendar.current.component(.hour, from: Date()) {
        case 5..<12:
            return L10n("Main.Greeting.morning")
        case 12..<18:
            return L10n("Main.Greeting.afternoon")
        case 18..<23:
            return L10n("Main.Greeting.evening")
        default:
            return L10n("Main.Greeting.night")
        }
    }
    
    var greetingName: String? {
        let nickname = ProfileSync.shared.nickname
        return nickname.isEmpty ? nil : nickname
    }
    
    var grantMessage: String? {
        guard let message = GrantManager.shared.message,
              !message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return nil }
        return message
    }
    
    var allTopicScore: String {
        "\(catalog.completedTopics)/\(catalog.totalTopics)"
    }
    var allQuestionScore: String {
        "\(catalog.correctCount)/\(catalog.totalQuestions)"
    }
    var allMistakeScore: String {
        "\(catalog.mistakePoolCount)"
    }
    
    var scoreValue: String {
        "\(ScoreManager.shared.total)"
    }
    
    var scoreTitle: String {
        L10n("\(ScoreManager.shared.total) Main.Score.suffix")
    }
    
    var examReadinessTitle: String {
        L10n("Main.ExamReadiness.title")
    }
    
    var topicsTitle: String {
        L10n("Main.Topics.title")
    }
    
    var questionsTitle: String {
        L10n("Main.Questions.title")
    }
    
    var toReviewTitle: String {
        L10n("Main.ToReview.title")
    }
    
    var searchTitle: String {
        L10n("Main.Search.title")
    }
    
    var leaderboardTitle: String {
        L10n("Main.Leaderboard.title")
    }
    
    var contactsTitle: String {
        L10n("Main.Contacts.title")
    }
    
    var examTitle: String {
        L10n("Main.Exam.title")
    }
    
    var examSubtitle: String {
        L10n("Main.Exam.subtitle")
    }
    
    var examPreview: String {
        L10n("\(ExamConfig.fullDurationMin) Main.Exam.preview")
    }
    
    var refreshTitle: String {
        L10n("Main.Refresh.title")
    }
    
    var refreshSubtitle: String {
        L10n("Main.Refresh.subtitle")
    }
    
    var refreshPreview: String {
        "\(catalog.correctPoolCount)"
    }
    
    var mistakesTitle: String {
        L10n("Main.Mistakes.title")
    }
    
    var mistakesSubtitle: String {
        L10n("Main.Mistakes.subtitle")
    }
    
    var savedTitle: String {
        L10n("Main.Saved.title")
    }
    
    var savedSubtitle: String {
        L10n("Main.Saved.subtitle")
    }
    
    var savedPreview: String {
        "\(savedQuestions.foldersCount())"
    }
    
    private let repository = QuizRepository.shared
    private let haptics = HapticsManager.shared
    private let savedQuestions = SavedQuestionsStore.shared
    
    func choose(_ category: Category) {
        haptics.impact()
        chosenCategory = category
    }
    
    func numberFor(_ category: Category) -> String {
        String(format: "%02d", category.index)
    }
    
    func titleFor(_ category: Category) -> String {
        category.name
    }
    
    func percentProgressFor(_ category: Category) -> String {
        "\(Int(category.progress * 100))%"
    }
    
    func topicScoreFor(_ category: Category) -> String {
        "\(category.completedTopics)/\(category.totalTopics)"
    }
    
    func examButtonPressed() {
        haptics.impact()
        destination = .exam
    }
    
    func refreshButtonPressed() {
        haptics.impact()
        destination = .refresh
    }
    
    func mistakesButtonPressed() {
        haptics.impact()
        destination = .mistakes
    }
    
    func savedButtonPressed() {
        haptics.impact()
        destination = .saved
    }
    
    func searchButtonPressed() {
        haptics.impact()
        destination = .search
    }
    
    func leaderboardButtonPressed() {
        haptics.impact()
        destination = .leaderboard
    }
    
    func contactsButtonPressed() {
        haptics.impact()
        destination = .contacts
    }
}
