//
//  TopicPhase.swift
//  Citizen
//
//  Created by GE-Developer
//

enum TopicPhase {
    case notStarted
    case inProgress
    case workingOnMistakes
    case completed
    
    @MainActor
    var statusLabel: String? {
        switch self {
        case .notStarted:
            nil
        case .inProgress:
            L10n("TopicPhase.Status.inProgress")
        case .workingOnMistakes:
            L10n("TopicPhase.Status.workingOnMistakes")
        case .completed:
            L10n("TopicPhase.Status.completed")
        }
    }
    
    @MainActor
    func primaryActionTitle(mistakesCount: Int) -> String? {
        switch self {
        case .notStarted:
            nil
        case .inProgress:
            L10n("ContinueAction.title")
        case .workingOnMistakes:
            L10n("\(mistakesCount) TopicPhase.Action.workingOnMistakes")
        case .completed:
            L10n("TopicPhase.Action.completed")
        }
    }
    
    func pillText(answered: Int, total: Int, wrong: Int) -> String? {
        switch self {
        case .notStarted:
            nil
        case .inProgress:
            "\(answered)/\(total)"
        case .workingOnMistakes:
            "\(wrong)"
        case .completed:
            nil
        }
    }
}
